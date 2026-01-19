import 'package:cloud_firestore/cloud_firestore.dart';

enum MedicationStatus { taken, missed, upcoming }

class MedicationLogModel {
  final String id;
  final String medicationId;
  final String userId;
  final DateTime date;
  final MedicationStatus status;
  final Timestamp updatedAt;

  MedicationLogModel({
    required this.id,
    required this.medicationId,
    required this.userId,
    required this.date,
    required this.status,
    required this.updatedAt,
  });

  factory MedicationLogModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicationLogModel(
      id: doc.id,
      medicationId: data['medicationId'],
      userId: data['userId'],
      date: (data['date'] as Timestamp).toDate(),
      status: MedicationStatus.values.byName(data['status']),
      updatedAt: data['updatedAt'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'medicationId': medicationId,
    'userId': userId,
    'date': Timestamp.fromDate(date),
    'status': status.name,
    'updatedAt': updatedAt,
  };
}
