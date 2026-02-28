import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medicare/logic/models/medication_log_model.dart';
import 'package:medicare/logic/models/medication_model.dart';

class NotificationCenterScreen extends StatefulWidget {
  const NotificationCenterScreen({super.key});

  @override
  State<NotificationCenterScreen> createState() => _NotificationCenterScreenState();
}

class _NotificationCenterScreenState extends State<NotificationCenterScreen> {
  final _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> _getNotificationStream() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('medication_logs')
        .where('userId', isEqualTo: user.uid)
        .snapshots()
        .asyncMap((logSnapshot) async {
      if (logSnapshot.docs.isEmpty) return [];

      final medicationIds = logSnapshot.docs.map((doc) => doc.data()['medicationId'] as String).toSet().toList();
      if (medicationIds.isEmpty) return [];

      final medicationSnapshot = await FirebaseFirestore.instance
          .collection('medications')
          .where(FieldPath.documentId, whereIn: medicationIds)
          .get();

      final medicationsMap = {for (var doc in medicationSnapshot.docs) doc.id: MedicationModel.fromFirestore(doc)};

      final viewDataList = <Map<String, dynamic>>[];
      for (final logDoc in logSnapshot.docs) {
        final log = MedicationLog.fromFirestore(logDoc);
        final medication = medicationsMap[log.medicationId];
        if (medication != null) {
          viewDataList.add({
            'log': log,
            'medication': medication,
          });
        }
      }
      
      // Manually sort in Dart to avoid requiring a Firestore Composite Index
      viewDataList.sort((a, b) {
        final logA = a['log'] as MedicationLog;
        final logB = b['log'] as MedicationLog;
        return logB.scheduledTime.compareTo(logA.scheduledTime);
      });
      
      return viewDataList.take(50).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1a1111) : const Color(0xFFfffbfb);
    final surfaceColor = isDarkMode ? const Color(0xFF2d1f1f) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF111714);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        title: Text('Notifications', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 22),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getNotificationStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            debugPrint("Notification Center Error: ${snapshot.error}");
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
              ),
            );
          }
          
          final items = snapshot.data ?? [];
          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  const Text('No notifications yet', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final data = items[index];
              final log = data['log'] as MedicationLog;
              final med = data['medication'] as MedicationModel;
              
              final timeString = DateFormat('MMM d, h:mm a').format(log.scheduledTime.toDate());
              
              IconData medIcon;
              Color statusColor;
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

              switch (log.status) {
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

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10)],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: statusColor.withValues(alpha: 0.15),
                      child: Icon(medIcon, color: statusColor, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text('Time to take ${med.name}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: 8),
                              Text(timeString, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text('Dosage: ${med.dosage} • ${med.timing}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
