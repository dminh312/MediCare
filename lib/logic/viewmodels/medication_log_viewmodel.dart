import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medicare/logic/models/medication_log_model.dart';
import 'package:medicare/logic/models/medication_model.dart';
import 'package:medicare/logic/services/notification_service.dart';

class MedicationLogViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  final NotificationService _notificationService;

  MedicationLogViewModel({required NotificationService notificationService}) 
      : _notificationService = notificationService;

  Future<void> createLogsForNewMedication(MedicationModel medication) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    if (medication.reminderEnabled) {
      try {
        await _notificationService.scheduleDailyMedicationNotification(
          id: medication.id.hashCode,
          title: 'Time to take ${medication.name}!',
          body: 'Dosage: ${medication.dosage}. Don\'t forget!',
          time: medication.time,
          payload: medication.id,
        );
        debugPrint("[VM_NOTIF] Successfully scheduled medication: ${medication.name}");
      } catch (e) {
        debugPrint("[VM_NOTIF ERROR] Error scheduling: $e");
      }
    }

    // 2. Save to Firestore
    final batch = _firestore.batch();
    final now = DateTime.now();

    for (int i = 0; i < 30; i++) {
      final scheduledDateTime = DateTime(now.year, now.month, now.day + i, medication.time.hour, medication.time.minute);
      final logRef = _firestore.collection('medication_logs').doc();
      final log = MedicationLog(
        id: logRef.id,
        medicationId: medication.id,
        userId: user.uid,
        scheduledTime: Timestamp.fromDate(scheduledDateTime),
        status: MedicationStatus.upcoming,
      );
      batch.set(logRef, log.toFirestore());
    }

    await batch.commit();
  }

  Future<void> updateLogStatus(String logId, MedicationStatus status, {DateTime? actualTakenTime}) async {
    await _firestore.collection('medication_logs').doc(logId).update({
      'status': status.name,
      'actualTakenTime': actualTakenTime != null ? Timestamp.fromDate(actualTakenTime) : null,
    });
  }

  Future<void> handleNotificationTap(String medicationId) async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot = await _firestore
        .collection('medication_logs')
        .where('userId', isEqualTo: user.uid)
        .where('medicationId', isEqualTo: medicationId)
        .where('status', isEqualTo: 'upcoming')
        .where('scheduledTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledTime', isLessThan: Timestamp.fromDate(endOfDay))
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final logDoc = querySnapshot.docs.first;
      await updateLogStatus(logDoc.id, MedicationStatus.taken, actualTakenTime: now);
    }
  }

  Future<void> cancelNotificationsForMedication(String medicationId) async {
    await _notificationService.cancelNotification(medicationId.hashCode);
  }

  Future<void> updateLogsAndNotificationsForMedication(MedicationModel medication) async {
    // Cancel old reminders
    await cancelNotificationsForMedication(medication.id);
    
    // Delete old logs
    try {
      final querySnapshot = await _firestore
          .collection('medication_logs')
          .where('medicationId', isEqualTo: medication.id)
          .where('scheduledTime', isGreaterThan: Timestamp.now())
          .get();
          
      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      debugPrint("Error cleaning up old logs: $e");
    }

    // Create new reminders and new logs
    await createLogsForNewMedication(medication);
  }

  Future<void> rescheduleAllNotifications() async {
    final User? user = _auth.currentUser;
    if (user == null) return;

    try {
      final medications = await _firestore
          .collection('medications')
          .where('userId', isEqualTo: user.uid)
          .where('reminderEnabled', isEqualTo: true)
          .get();

      for (final doc in medications.docs) {
        final med = MedicationModel.fromFirestore(doc);
        await _notificationService.scheduleDailyMedicationNotification(
          id: med.id.hashCode,
          title: 'Time to take ${med.name}!',
          body: 'Dosage: ${med.dosage}. Don\'t forget!',
          time: med.time,
          payload: med.id,
        );
      }
    } catch (e) {
      debugPrint("Error rescheduling: $e");
    }
  }
}
