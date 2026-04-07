import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum MedicationForm { pill, injection, syrup, tablet, capsule }

class MedicationModel {
  final String id;
  final String userId;
  final String name;
  final String dosage;
  final String? dosageEntireTreatment;
  final MedicationForm form;
  final String frequency;
  final TimeOfDay time;
  final String timing;
  final bool reminderEnabled;
  final String? notes;
  final Timestamp createdAt;

  MedicationModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.dosage,
    this.dosageEntireTreatment,
    required this.form,
    required this.frequency,
    required this.time,
    required this.timing,
    required this.reminderEnabled,
    this.notes,
    required this.createdAt,
  });

  factory MedicationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MedicationModel(
      id: doc.id,
      userId: data['userId'],
      name: data['name'],
      dosage: data['dosage'],
      dosageEntireTreatment: data['dosageEntireTreatment'],
      form: MedicationForm.values.byName(data['form']),
      frequency: data['frequency'],
      time: TimeOfDay(hour: data['hour'], minute: data['minute']),
      timing: data['timing'],
      reminderEnabled: data['reminderEnabled'],
      notes: data['notes'],
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toFirestore() => {
    'userId': userId,
    'name': name,
    'dosage': dosage,
    'dosageEntireTreatment': dosageEntireTreatment,
    'form': form.name,
    'frequency': frequency,
    'hour': time.hour,
    'minute': time.minute,
    'timing': timing,
    'reminderEnabled': reminderEnabled,
    'notes': notes,
    'createdAt': createdAt,
  };
}
