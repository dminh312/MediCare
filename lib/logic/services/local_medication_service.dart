import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:medicare/logic/models/medication_log_model.dart';
import 'package:medicare/logic/models/medication_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalMedicationService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('medications.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE medications(
        id TEXT PRIMARY KEY,
        userId TEXT,
        name TEXT,
        dosage TEXT,
        dosageEntireTreatment TEXT,
        form TEXT,
        frequency TEXT,
        time_hour INTEGER,
        time_minute INTEGER,
        timing TEXT,
        reminderEnabled INTEGER,
        notes TEXT,
        createdAt INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE medication_logs(
        id TEXT PRIMARY KEY,
        medicationId TEXT,
        userId TEXT,
        scheduledTime INTEGER,
        status TEXT,
        actualTakenTime INTEGER
      )
    ''');
  }

  // --- Medications CRUD ---

  Future<void> saveMedicationLocally(MedicationModel medication) async {
    final db = await database;
    await db.insert(
      'medications',
      _medicationToMap(medication),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteMedicationLocally(String medicationId) async {
    final db = await database;
    await db.delete('medications', where: 'id = ?', whereArgs: [medicationId]);
    await db.delete(
      'medication_logs',
      where: 'medicationId = ?',
      whereArgs: [medicationId],
    );
  }

  Future<List<MedicationModel>> getLocalMedications(String userId) async {
    final db = await database;
    final result = await db.query(
      'medications',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    return result.map((json) => _medicationFromMap(json)).toList();
  }

  Future<List<MedicationModel>> searchLocalMedications(
    String userId,
    String query,
  ) async {
    final db = await database;
    final result = await db.query(
      'medications',
      where: 'userId = ? AND LOWER(name) LIKE ?',
      whereArgs: [userId, '%${query.toLowerCase()}%'],
    );
    return result.map((json) => _medicationFromMap(json)).toList();
  }

  // --- Logs CRUD ---

  Future<void> createLocalLogsForMedication(MedicationModel medication) async {
    final db = await database;
    final now = DateTime.now();

    final batch = db.batch();
    for (int i = 0; i < 30; i++) {
      final scheduledDateTime = DateTime(
        now.year,
        now.month,
        now.day + i,
        medication.time.hour,
        medication.time.minute,
      );
      final logId = 'local_log_${medication.id}_$i';

      final log = MedicationLog(
        id: logId,
        medicationId: medication.id,
        userId: medication.userId,
        scheduledTime: Timestamp.fromDate(scheduledDateTime),
        status: MedicationStatus.upcoming,
      );
      batch.insert(
        'medication_logs',
        _logToMap(log),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<void> updateLocalLogStatus(
    String logId,
    MedicationStatus status, {
    DateTime? actualTakenTime,
  }) async {
    final db = await database;
    await db.update(
      'medication_logs',
      {
        'status': status.name,
        if (actualTakenTime != null)
          'actualTakenTime': actualTakenTime.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [logId],
    );
  }

  Future<List<MedicationLog>> getLocalLogsForDateRange(
    String userId,
    DateTime start,
    DateTime end,
  ) async {
    final db = await database;
    final startMs = start.millisecondsSinceEpoch;
    final endMs = end.millisecondsSinceEpoch;

    final result = await db.query(
      'medication_logs',
      where: 'userId = ? AND scheduledTime >= ? AND scheduledTime < ?',
      whereArgs: [userId, startMs, endMs],
    );
    return result.map((json) => _logFromMap(json)).toList();
  }

  Future<void> updateMissedLocalLogs(String userId) async {
    final db = await database;
    final cutoffMs = DateTime.now()
        .subtract(const Duration(minutes: 15))
        .millisecondsSinceEpoch;

    await db.update(
      'medication_logs',
      {'status': 'missed'},
      where: 'userId = ? AND status = ? AND scheduledTime < ?',
      whereArgs: [userId, 'upcoming', cutoffMs],
    );
  }

  // --- Parsers ---

  Map<String, dynamic> _medicationToMap(MedicationModel med) {
    return {
      'id': med.id,
      'userId': med.userId,
      'name': med.name,
      'dosage': med.dosage,
      'dosageEntireTreatment': med.dosageEntireTreatment,
      'form': med.form.name,
      'frequency': med.frequency,
      'time_hour': med.time.hour,
      'time_minute': med.time.minute,
      'timing': med.timing,
      'reminderEnabled': med.reminderEnabled ? 1 : 0,
      'notes': med.notes,
      'createdAt': med.createdAt.millisecondsSinceEpoch,
    };
  }

  MedicationModel _medicationFromMap(Map<String, Object?> map) {
    return MedicationModel(
      id: map['id'] as String,
      userId: map['userId'] as String,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      dosageEntireTreatment: map['dosageEntireTreatment'] as String?,
      form: MedicationForm.values.byName(map['form'] as String),
      frequency: map['frequency'] as String,
      time: TimeOfDay(
        hour: map['time_hour'] as int,
        minute: map['time_minute'] as int,
      ),
      timing: map['timing'] as String,
      reminderEnabled: (map['reminderEnabled'] as int) == 1,
      notes: map['notes'] as String?,
      createdAt: Timestamp.fromMillisecondsSinceEpoch(map['createdAt'] as int),
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

  MedicationLog _logFromMap(Map<String, Object?> map) {
    return MedicationLog(
      id: map['id'] as String,
      medicationId: map['medicationId'] as String,
      userId: map['userId'] as String,
      scheduledTime: Timestamp.fromMillisecondsSinceEpoch(
        map['scheduledTime'] as int,
      ),
      status: MedicationStatus.values.byName(map['status'] as String),
      actualTakenTime: map['actualTakenTime'] != null
          ? Timestamp.fromMillisecondsSinceEpoch(map['actualTakenTime'] as int)
          : null,
    );
  }
}
