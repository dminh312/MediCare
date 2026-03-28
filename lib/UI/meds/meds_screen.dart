import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicare/UI/meds/add_meds/add_meds_screen.dart';
import 'package:medicare/logic/models/medication_log_model.dart';
import 'package:medicare/logic/models/medication_model.dart';
import 'package:medicare/logic/services/local_medication_service.dart';
import 'package:medicare/logic/viewmodels/medication_log_viewmodel.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

class MedicationViewData {
  final MedicationModel medication;
  final MedicationLog log;

  MedicationViewData({required this.medication, required this.log});
}

class MedsScreen extends StatefulWidget {
  const MedsScreen({super.key});

  @override
  State<MedsScreen> createState() => _MedsScreenState();
}

class _MedsScreenState extends State<MedsScreen> {
  late int _selectedDayIndex;
  final _auth = FirebaseAuth.instance;
  late DateTime _today;

  // StreamController so we can push merged (Firestore + local) data manually.
  final _medsController = StreamController<List<MedicationViewData>>();
  StreamSubscription? _firestoreSubscription;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    _selectedDayIndex = 3; // Center on today
    if (_auth.currentUser != null) {
      _updateMissedMedications().then((_) => _refreshMeds());
    }
  }

  @override
  void dispose() {
    _firestoreSubscription?.cancel();
    _medsController.close();
    super.dispose();
  }

  Future<void> _updateMissedMedications() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final cutoff = DateTime.now().subtract(const Duration(minutes: 15));

    try {
      final logsToUpdate = await FirebaseFirestore.instance
          .collection('medication_logs')
          .where('userId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'upcoming')
          .where('scheduledTime', isLessThan: Timestamp.fromDate(cutoff))
          .get();

      if (logsToUpdate.docs.isNotEmpty) {
        final batch = FirebaseFirestore.instance.batch();
        for (final doc in logsToUpdate.docs) {
          batch.update(doc.reference, {'status': MedicationStatus.missed.name});
        }
        await batch.commit();
      }
    } catch (e) {
      debugPrint("Error updating missed medications: $e");
    }
  }

  DateTime get _selectedDate {
    final now = DateTime.now();
    final baseToday = DateTime(now.year, now.month, now.day);
    return baseToday.add(Duration(days: _selectedDayIndex - 3));
  }

  void _refreshMeds() {
    _updateMissedMedications().then((_) => _loadAndPushMeds());
  }

  Future<void> _loadAndPushMeds() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final startOfDay = _selectedDate;
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // Cancel any previous Firestore listener.
    await _firestoreSubscription?.cancel();

    final localService = LocalMedicationService();

    _firestoreSubscription = FirebaseFirestore.instance
        .collection('medication_logs')
        .where('userId', isEqualTo: user.uid)
        .where('scheduledTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledTime', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots()
        .listen((logSnapshot) async {
      // --- Local data ---
      await localService.updateMissedLocalLogs(user.uid);
      final localLogs = await localService.getLocalLogsForDateRange(user.uid, startOfDay, endOfDay);
      final localMedsList = await localService.getLocalMedications(user.uid);
      final localMedsMap = {for (var med in localMedsList) med.id: med};

      // --- Firestore data ---
      final medicationIds = logSnapshot.docs
          .map((doc) => doc.data()['medicationId'] as String)
          .toSet()
          .toList();

      Map<String, MedicationModel> medicationsMap = {};
      if (medicationIds.isNotEmpty) {
        final medicationSnapshot = await FirebaseFirestore.instance
            .collection('medications')
            .where(FieldPath.documentId, whereIn: medicationIds)
            .get();
        medicationsMap = {for (var doc in medicationSnapshot.docs) doc.id: MedicationModel.fromFirestore(doc)};
      }

      // --- Merge ---
      final viewDataList = <MedicationViewData>[];

      for (final logDoc in logSnapshot.docs) {
        final log = MedicationLog.fromFirestore(logDoc);
        final medication = medicationsMap[log.medicationId];
        if (medication != null) {
          viewDataList.add(MedicationViewData(medication: medication, log: log));
        }
      }

      for (final localLog in localLogs) {
        final medication = localMedsMap[localLog.medicationId];
        if (medication != null) {
          viewDataList.add(MedicationViewData(medication: medication, log: localLog));
        }
      }

      viewDataList.sort((a, b) => a.log.scheduledTime.compareTo(b.log.scheduledTime));

      if (!_medsController.isClosed) {
        _medsController.add(viewDataList);
      }
    }, onError: (e) {
      if (!_medsController.isClosed) {
        _medsController.addError(e);
      }
    });
  }

  Future<void> _deleteMedication(MedicationModel medication) async {
    final medicationLogViewModel = Provider.of<MedicationLogViewModel>(context, listen: false);
    final localService = LocalMedicationService();

    if (medication.id.startsWith('local_')) {
      await localService.deleteMedicationLocally(medication.id);
      await medicationLogViewModel.cancelNotificationsForMedication(medication.id);
      _updateMissedMedications().then((_) => _loadAndPushMeds());
    } else {
      await FirebaseFirestore.instance.collection('medications').doc(medication.id).delete();
      final logSnapshot = await FirebaseFirestore.instance.collection('medication_logs').where('medicationId', isEqualTo: medication.id).get();

      final batch = FirebaseFirestore.instance.batch();
      for (final doc in logSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      await medicationLogViewModel.cancelNotificationsForMedication(medication.id);
    }
  }

  void _editMedication(MedicationModel medication) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMedsScreen(medication: medication)),
    ).then((_) {
       _updateMissedMedications().then((_) => _loadAndPushMeds());
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFff5252);
    final surfaceColor = isDarkMode ? const Color(0xFF2d1f1f) : Colors.white;
    final gradientColors = isDarkMode 
        ? [const Color(0xFF1a1111), const Color(0xFF2d1f1f)] 
        : [const Color(0xFFfffbfb), const Color(0xFFf5eaea)];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('My Medications', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF111714))),
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          shadowColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: primaryColor.withAlpha(isDarkMode ? 51 : 26),
              child: IconButton(
                icon: Icon(Icons.add, color: primaryColor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddMedsScreen()),
                  ).then((_) {
                     _updateMissedMedications().then((_) => _loadAndPushMeds());
                  });
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          const SizedBox(height: 24),
          Expanded(
            child: StreamBuilder<List<MedicationViewData>>(
              stream: _medsController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'Query Error: ${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No medications scheduled for this day.'));
                }
                final meds = snapshot.data!;
                final morningMeds = meds.where((m) => m.medication.time.hour < 12).toList();
                final afternoonMeds = meds.where((m) => m.medication.time.hour >= 12 && m.medication.time.hour < 18).toList();
                final eveningMeds = meds.where((m) => m.medication.time.hour >= 18).toList();

                return ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  children: [
                    if (morningMeds.isNotEmpty) _buildScheduleSection('Morning Schedule', Icons.light_mode, Colors.orange, morningMeds, surfaceColor),
                    if (afternoonMeds.isNotEmpty) _buildScheduleSection('Afternoon Schedule', Icons.sunny, primaryColor, afternoonMeds, surfaceColor),
                    if (eveningMeds.isNotEmpty) _buildScheduleSection('Evening Schedule', Icons.dark_mode, Colors.indigo, eveningMeds, surfaceColor),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDaySelector() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7,
        itemBuilder: (context, index) {
          final day = _today.add(Duration(days: index - 3));
          final isSelected = index == _selectedDayIndex;
          return GestureDetector(
            onTap: () => setState(() {
              _selectedDayIndex = index;
              _loadAndPushMeds();
            }),
            child: Container(
              width: 55,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFff5252) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2d1f1f) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected 
                    ? [BoxShadow(color: const Color(0xFFff5252).withAlpha(100), blurRadius: 12, offset: const Offset(0, 6))] 
                    : [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 8, offset: const Offset(0, 4))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat.E().format(day), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white.withAlpha(230) : Colors.grey)),
                  const SizedBox(height: 4),
                  Text(day.day.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color)),
                  if(isSelected) ...[
                    const SizedBox(height: 4),
                    Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleSection(String title, IconData icon, Color iconColor, List<MedicationViewData> meds, Color surfaceColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(meds.length, (index) {
            return _buildMedicationItem(meds[index], surfaceColor, index);
          }),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(MedicationViewData medViewData, Color surfaceColor, int index) {
    final med = medViewData.medication;
    // SỬA LỖI: Sử dụng log.id làm Key thay vì med.id để tránh trùng lặp
    return Dismissible(
      key: Key(medViewData.log.id),
      background: Container(
        color: Colors.blue,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _deleteMedication(med);
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _editMedication(med);
          return false;
        } else if (direction == DismissDirection.endToStart) {
          return await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Confirm Deletion'),
                content: const Text('Are you sure you want to delete this medication and all its reminders?'),
                actions: <Widget>[
                  TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                  TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
                ],
              );
            },
          ) ?? false;
        }
        return false;
      },
      child: _buildMedicationListItem(medViewData, surfaceColor),
    ).animate().fade(duration: 400.ms, delay: (50 * index).ms).slideX(begin: 0.1, curve: Curves.easeOut);
  }

  Widget _buildMedicationListItem(MedicationViewData medViewData, Color surfaceColor) {
    final med = medViewData.medication;
    final status = medViewData.log.status;
    IconData medIcon;
    Color iconBgColor, iconColor, statusColor;
    String statusText;

    switch (med.form) {
      case MedicationForm.pill:
      case MedicationForm.tablet:
      case MedicationForm.capsule:
        medIcon = Icons.medication;
        break;
      case MedicationForm.injection:
        medIcon = Icons.vaccines;
        break;
      case MedicationForm.syrup:
        medIcon = Icons.medication_liquid;
        break;
    }

    switch (status) {
      case MedicationStatus.taken:
        statusText = 'Taken';
        statusColor = Colors.green;
        break;
      case MedicationStatus.missed:
        statusText = 'Missed';
        statusColor = Colors.red;
        break;
      case MedicationStatus.upcoming:
        statusText = 'Upcoming';
        statusColor = Colors.blue;
        break;
    }
    
    iconBgColor = statusColor.withAlpha(26);
    iconColor = statusColor;

    return GestureDetector(
      onTap: () => _showMedicationDetailsDialog(context, medViewData),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: status == MedicationStatus.missed ? const Border(left: BorderSide(color: Colors.red, width: 4)) : null,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.black.withAlpha(100) : Colors.black.withAlpha(20), 
              blurRadius: 16, 
              offset: const Offset(0, 6),
            )
          ]
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: iconBgColor,
              child: Icon(medIcon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('${med.dosage} • ${med.timing}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 4),
                Text(med.time.format(context), style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showMedicationDetailsDialog(BuildContext context, MedicationViewData medViewData) {
    final med = medViewData.medication;
    final status = medViewData.log.status;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Status text formatter
    String statusText;
    Color statusColor;
    switch (status) {
      case MedicationStatus.taken:
        statusText = 'Taken';
        statusColor = Colors.green;
        break;
      case MedicationStatus.missed:
        statusText = 'Missed';
        statusColor = Colors.red;
        break;
      case MedicationStatus.upcoming:
        statusText = 'Upcoming';
        statusColor = Colors.blue;
        break;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF2d1f1f) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.medical_information, color: Theme.of(context).primaryColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  med.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                _buildDetailRow(Icons.science, 'Dose/Form', '${med.dosage} (${med.form.name})'),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.access_time, 'Schedule', med.time.format(context)),
                const SizedBox(height: 12),
                _buildDetailRow(Icons.calendar_today, 'Timing', med.timing),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, size: 20, color: Colors.grey),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Status', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(38),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              statusText,
                              style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            ],
          ),
        ),
      ],
    );
  }
}
