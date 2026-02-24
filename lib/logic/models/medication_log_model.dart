import 'package:cloud_firestore/cloud_firestore.dart';

enum MedicationStatus { taken, missed, upcoming }

class MedicationLog {
  final String id;
  final String medicationId;
  final String userId;
  final Timestamp scheduledTime;
  final MedicationStatus status;
  final Timestamp? actualTakenTime;

  MedicationLog({
    required this.id,
    required this.medicationId,
    required this.userId,
    required this.scheduledTime,
    required this.status,
    this.actualTakenTime,
  });

  factory MedicationLog.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return MedicationLog(
      id: doc.id,
      medicationId: data['medicationId'] ?? '',
      userId: data['userId'] ?? '',
      scheduledTime: data['scheduledTime'] ?? Timestamp.now(),
      status: MedicationStatus.values.byName(data['status'] ?? 'upcoming'),
      actualTakenTime: data['actualTakenTime'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'medicationId': medicationId,
      'userId': userId,
      'scheduledTime': scheduledTime,
      'status': status.name,
      'actualTakenTime': actualTakenTime,
    };
  }
}
