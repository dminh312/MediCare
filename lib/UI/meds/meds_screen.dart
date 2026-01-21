import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicare/UI/meds/add_meds/add_meds_screen.dart';
import 'package:medicare/logic/models/medication_log_model.dart';
import 'package:medicare/logic/models/medication_model.dart';

class MedicationViewData {
  final MedicationModel medication;
  final MedicationStatus status;

  MedicationViewData({required this.medication, required this.status});
}

class MedsScreen extends StatefulWidget {
  const MedsScreen({super.key});

  @override
  State<MedsScreen> createState() => _MedsScreenState();
}

class _MedsScreenState extends State<MedsScreen> {
  late int _selectedDayIndex;
  Stream<List<MedicationViewData>>? _medsStream;
  final _auth = FirebaseAuth.instance;
  late DateTime _today;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now();
    // Show 3 days before, today, and 3 days after. Today is at index 3.
    _selectedDayIndex = 3;
    if (_auth.currentUser != null) {
      _updateMedsStream();
    }
  }

  DateTime get _selectedDate {
    return _today.add(Duration(days: _selectedDayIndex - 3));
  }

  void _updateMedsStream() {
    final user = _auth.currentUser;
    if (user == null) return;

    final selectedDay = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);

    setState(() {
      _medsStream = FirebaseFirestore.instance
          .collection('medications')
          .where('userId', isEqualTo: user.uid)
          .snapshots()
          .asyncMap((medicationSnapshot) async {
        final medications = medicationSnapshot.docs
            .map((doc) => MedicationModel.fromFirestore(doc))
            .toList();

        final logSnapshot = await FirebaseFirestore.instance
            .collection('medication_logs')
            .where('userId', isEqualTo: user.uid)
            .where('date', isEqualTo: Timestamp.fromDate(selectedDay))
            .get();

        final logs = logSnapshot.docs
            .map((doc) => MedicationLogModel.fromFirestore(doc))
            .toList();

        return medications.map((med) {
          final log = logs
              .cast<MedicationLogModel?>()
              .firstWhere((log) => log?.medicationId == med.id, orElse: () => null);

          MedicationStatus status;
          if (log != null) {
            status = log.status;
          } else {
            final now = DateTime.now();
            final today = DateTime(now.year, now.month, now.day);
            final medTime = DateTime(now.year, now.month, now.day, med.time.hour, med.time.minute);

            if (selectedDay.isBefore(today)) {
              status = MedicationStatus.missed;
            } else if (selectedDay.isAfter(today)) {
              status = MedicationStatus.upcoming;
            } else {
              if (medTime.isAfter(now)) {
                status = MedicationStatus.upcoming;
              } else {
                status = MedicationStatus.missed;
              }
            }
          }
          return MedicationViewData(medication: med, status: status);
        }).toList();
      });
    });
  }

  void _deleteMedication(String medId) {
    FirebaseFirestore.instance.collection('medications').doc(medId).delete();
  }

  void _editMedication(MedicationModel medication) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddMedsScreen(medication: medication),
      ),
    ).then((_) => _updateMedsStream());
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFff5252);
    final backgroundColor = isDarkMode ? const Color(0xFF1a1111) : const Color(0xFFfffbfb);
    final surfaceColor = isDarkMode ? const Color(0xFF2d1f1f) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('My Medications', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF111714))),
        backgroundColor: isDarkMode ? backgroundColor.withOpacity(0.95) : backgroundColor.withOpacity(0.95),
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: isDarkMode ? Colors.transparent : Colors.grey.withOpacity(0.1),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: primaryColor.withOpacity(isDarkMode ? 0.2 : 0.1),
              child: IconButton(
                icon: Icon(Icons.add, color: primaryColor),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AddMedsScreen()),
                  ).then((_) => _updateMedsStream());
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
              stream: _medsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No medications added yet.'));
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
              _updateMedsStream();
            }),
            child: Container(
              width: 55,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFff5252) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2d1f1f) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected ? [BoxShadow(color: const Color(0xFFff5252).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat.E().format(day), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey)),
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
          ...meds.map((med) => _buildMedicationItem(med, surfaceColor)),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(MedicationViewData medViewData, Color surfaceColor) {
    final med = medViewData.medication;
    return Dismissible(
      key: Key(med.id),
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
          _deleteMedication(med.id);
        }
      },
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _editMedication(med);
          return false; // Do not dismiss, just navigate
        } else if (direction == DismissDirection.endToStart) {
          final bool? shouldDelete = await showDialog<bool>(
            context: context,
            builder: (BuildContext context) {
              final isDarkMode = Theme.of(context).brightness == Brightness.dark;
              final surfaceColor = isDarkMode ? const Color(0xFF2d1f1f) : Colors.white;
              final primaryColor = const Color(0xFFff5252);
              final textColor = isDarkMode ? Colors.white : const Color(0xFF111714);

              return AlertDialog(
                backgroundColor: surfaceColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                icon: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                      Icons.delete_outline,
                      color: primaryColor,
                      size: 24)
                ),
                title: Text('Confirm Deletion', style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 18)),
                content: Text(
                  'Are you sure you want to delete this medication? This action cannot be undone.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor.withOpacity(0.7), fontSize: 14),
                ),
                actionsAlignment: MainAxisAlignment.center,
                actionsPadding: const EdgeInsets.only(bottom: 16, top: 16),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(120, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!),
                          ),
                        ),
                        child: Text('Cancel', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          minimumSize: const Size(120, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 2,
                          shadowColor: primaryColor.withOpacity(0.2),
                        ),
                        child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  )
                ],
              );
            },
          );
          return shouldDelete ?? false;
        }
        return false; // Should not happen for other directions
      },
      child: _buildMedicationListItem(medViewData, surfaceColor),
    );
  }

  Widget _buildMedicationListItem(MedicationViewData medViewData, Color surfaceColor) {
    final med = medViewData.medication;
    final status = medViewData.status;
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
    
    iconBgColor = statusColor.withOpacity(0.1);
    iconColor = statusColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: status == MedicationStatus.missed ? const Border(left: BorderSide(color: Colors.red, width: 4)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]
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
                  color: statusColor.withOpacity(0.15),
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
    );
  }
}