import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medicare/logic/models/medication_log_model.dart';
import 'package:medicare/logic/models/medication_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalMedicationService {
  static const String _medsKey = 'local_medications';
  static const String _logsKey = 'local_medication_logs';

  Future<void> saveMedicationLocally(MedicationModel medication) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing
    final List<String> medsJson = prefs.getStringList(_medsKey) ?? [];
    
    // Remove if exists
    medsJson.removeWhere((jsonStr) {
      final map = jsonDecode(jsonStr);
      return map['id'] == medication.id;
    });

    // Add new
    medsJson.add(jsonEncode(_medicationToMap(medication)));
    
    await prefs.setStringList(_medsKey, medsJson);
  }

  Future<void> deleteMedicationLocally(String medicationId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Remove med
    final medsJson = prefs.getStringList(_medsKey) ?? [];
    medsJson.removeWhere((jsonStr) {
      final map = jsonDecode(jsonStr);
      return map['id'] == medicationId;
    });
    await prefs.setStringList(_medsKey, medsJson);

    // Remove logs
    final logsJson = prefs.getStringList(_logsKey) ?? [];
    logsJson.removeWhere((jsonStr) {
      final map = jsonDecode(jsonStr);
      return map['medicationId'] == medicationId;
    });
    await prefs.setStringList(_logsKey, logsJson);
  }

  Future<void> createLocalLogsForMedication(MedicationModel medication) async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getStringList(_logsKey) ?? [];
    
    final now = DateTime.now();
    for (int i = 0; i < 30; i++) {
        final scheduledDateTime = DateTime(now.year, now.month, now.day + i, medication.time.hour, medication.time.minute);
        final logId = 'local_log_${medication.id}_$i';
        
        final log = MedicationLog(
          id: logId,
          medicationId: medication.id,
          userId: medication.userId,
          scheduledTime: Timestamp.fromDate(scheduledDateTime),
          status: MedicationStatus.upcoming,
        );
        logsJson.add(jsonEncode(_logToMap(log)));
    }
    
    await prefs.setStringList(_logsKey, logsJson);
  }

  Future<void> updateLocalLogStatus(String logId, MedicationStatus status, {DateTime? actualTakenTime}) async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getStringList(_logsKey) ?? [];
    
    for (int i = 0; i < logsJson.length; i++) {
      final map = jsonDecode(logsJson[i]);
      if (map['id'] == logId) {
        map['status'] = status.name;
        if (actualTakenTime != null) {
          map['actualTakenTime'] = actualTakenTime.millisecondsSinceEpoch;
        }
        logsJson[i] = jsonEncode(map);
        break;
      }
    }
    
    await prefs.setStringList(_logsKey, logsJson);
  }

  Future<List<MedicationModel>> getLocalMedications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final medsJson = prefs.getStringList(_medsKey) ?? [];
    
    final List<MedicationModel> meds = [];
    for (final str in medsJson) {
      final map = jsonDecode(str);
      if (map['userId'] == userId) {
        meds.add(_medicationFromMap(map));
      }
    }
    return meds;
  }

  Future<List<MedicationLog>> getLocalLogsForDateRange(String userId, DateTime start, DateTime end) async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getStringList(_logsKey) ?? [];
    
    final List<MedicationLog> logs = [];
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;

    for (final str in logsJson) {
      final map = jsonDecode(str);
      if (map['userId'] == userId) {
        final scheduledTimeMs = map['scheduledTime'] as int;
        if (scheduledTimeMs >= startMs && scheduledTimeMs < endMs) {
          logs.add(_logFromMap(map));
        }
      }
    }
    return logs;
  }
  
  Future<void> updateMissedLocalLogs(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final logsJson = prefs.getStringList(_logsKey) ?? [];
    bool updated = false;
    
    final cutoffMs = DateTime.now().subtract(const Duration(minutes: 15)).millisecondsSinceEpoch;

    for (int i = 0; i < logsJson.length; i++) {
        final map = jsonDecode(logsJson[i]);
        if (map['userId'] == userId && map['status'] == 'upcoming') {
            final scheduledTimeMs = map['scheduledTime'] as int;
            if (scheduledTimeMs < cutoffMs) {
                map['status'] = 'missed';
                logsJson[i] = jsonEncode(map);
                updated = true;
            }
        }
    }
    
    if (updated) {
        await prefs.setStringList(_logsKey, logsJson);
    }
  }

  Map<String, dynamic> _medicationToMap(MedicationModel med) {
    return {
      'id': med.id,
      'userId': med.userId,
      'name': med.name,
      'dosage': med.dosage,
      'dosageEntireTreatment': med.dosageEntireTreatment,
      'form': med.form.name,
      'frequency': med.frequency,
      'hour': med.time.hour,
      'minute': med.time.minute,
      'timing': med.timing,
      'reminderEnabled': med.reminderEnabled,
      'notes': med.notes,
      'createdAt': med.createdAt.millisecondsSinceEpoch,
    };
  }

  MedicationModel _medicationFromMap(Map<String, dynamic> map) {
    return MedicationModel(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      dosage: map['dosage'],
      dosageEntireTreatment: map['dosageEntireTreatment'],
      form: MedicationForm.values.byName(map['form']),
      frequency: map['frequency'],
      time: TimeOfDay(hour: map['hour'], minute: map['minute']),
      timing: map['timing'],
      reminderEnabled: map['reminderEnabled'] ?? true,
      notes: map['notes'],
      createdAt: Timestamp.fromMillisecondsSinceEpoch(map['createdAt']),
    );
  }

  Map<String, dynamic> _logToMap(MedicationLog log) {
    return {
      'id': log.id,
      'medicationId': log.medicationId,
      'userId': log.userId,
      'scheduledTime': log.scheduledTime.millisecondsSinceEpoch,
      'status': log.status.name,
      'actualTakenTime': log.actualTakenTime?.millisecondsSinceEpoch,
    };
  }

  MedicationLog _logFromMap(Map<String, dynamic> map) {
    return MedicationLog(
      id: map['id'],
      medicationId: map['medicationId'],
      userId: map['userId'],
      scheduledTime: Timestamp.fromMillisecondsSinceEpoch(map['scheduledTime']),
      status: MedicationStatus.values.byName(map['status']),
      actualTakenTime: map['actualTakenTime'] != null ? Timestamp.fromMillisecondsSinceEpoch(map['actualTakenTime']) : null,
    );
  }
}
