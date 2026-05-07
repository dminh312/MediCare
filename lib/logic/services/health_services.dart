import 'dart:io';
import 'package:health/health.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:device_info_plus/device_info_plus.dart';

class HealthService {
  final Health _health = Health();
  bool _isConfigured = false;

  List<HealthDataType> _types = [
    HealthDataType.HEART_RATE,
    HealthDataType.STEPS,
    
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHTHealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,,
    HealthDataType.SLEEP_REM,
    HealthDataType.BLOOD_OXYGEN,
  ];

  List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  Future<void> _ensureConfigured() async {
    if (!_isConfigured) {
      await _health.configure();
      _isConfigured = true;
    }
  }

  // Check Health Connect available (Android only)
  Future<bool> isAvailable() async {
    await _ensureConfigured();
    return await _health.isHealthConnectAvailable();
  }

  // Request permission
  Future<bool> requestPermission() async {
    await _ensureConfigured();
    return await _health.requestAuthorization(
      _types,
      permissions: _permissions,
    );
  }

  // Check if permission already granted
  Future<bool> hasPermission() async {
    await _ensureConfigured();
    return await _health.hasPermissions(_types, permissions: _permissions) ??
        false;
  }

  // Fetch data
  Future<List<HealthDataPoint>> fetchHealthData({int days = 1}) async {
    await _ensureConfigured();
    final now = DateTime.now();
    final startTime = now.subtract(Duration(days: days));

    final dataPoints = await _health.getHealthDataFromTypes(
      startTime: startTime,
      endTime: now,
      types: _types,
    );

    return _health.removeDuplicates(dataPoints);
  }

  // Fetch heart rate only
  Future<List<HealthDataPoint>> fetchHeartRate({int days = 1}) async {
    await _ensureConfigured();
    final now = DateTime.now();
    final startTime = now.subtract(Duration(days: days));

    return await _health.getHealthDataFromTypes(
      startTime: startTime,
      endTime: now,
      types: [HealthDataType.HEART_RATE],
    );
  }

  // Fetch steps only
  Future<List<HealthDataPoint>> fetchSteps({int days = 1}) async {
    await _ensureConfigured();
    final now = DateTime.now();
    final startTime = now.subtract(Duration(days: days));

    return await _health.getHealthDataFromTypes(
      startTime: startTime,
      endTime: now,
      types: [HealthDataType.STEPS],
    );
  }

  // Fetch blood oxygen only
  Future<List<HealthDataPoint>> fetchBloodOxygen({int days = 1}) async {
    await _ensureConfigured();
    final now = DateTime.now();
    final startTime = now.subtract(Duration(days: days));

    return await _health.getHealthDataFromTypes(
      startTime: startTime,
      endTime: now,
      types: [HealthDataType.BLOOD_OXYGEN],
    );
  }


  // Sync data to Firebase
  Future<bool> syncHealthDataToFirebase({int days = 1}) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("HealthService sync: User not logged in.");
        return false;
      }

      bool available = await isAvailable();
      if (!available) {
        print("HealthService sync: Health Connect not available, prompting install...");
        await _health.installHealthConnect();
        return false;
      }

      // Check and request permission
      bool permitted = await hasPermission();
      if (!permitted) {
        permitted = await requestPermission();
        if (!permitted) {
          print("HealthService sync: Permission denied.");
          return false;
        }
      }

      // Fetch all data
      final dataPoints = await fetchHealthData(days: days);

      if (dataPoints.isEmpty) {
        print("HealthService sync: No data to sync.");
        return true;
      }

      // Group data by date
      Map<String, Map<String, List<Map<String, dynamic>>>> groupedData = {};

      for (var point in dataPoints) {
        final date = point.dateFrom;
        final dateString =
            "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

        if (!groupedData.containsKey(dateString)) {
          groupedData[dateString] = {
            'HEART_RATE': [],
            'STEPS': [],
            'SLEEP_ASLEEP': [],
            'BLOOD_OXYGEN': [],
            'OTHER': [],
          };
        }

        String typeKey = point.type.name;
        if (!groupedData[dateString]!.containsKey(typeKey)) {
          typeKey = 'OTHER';
        }

        dynamic value;
        if (point.value is NumericHealthValue) {
          value = (point.value as NumericHealthValue).numericValue;
        } else {
          value = point.value.toString();
        }

        groupedData[dateString]![typeKey]!.add({
          'value': value,
          'unit': point.unit.name,
          'dateFrom': point.dateFrom.toIso8601String(),
          'dateTo': point.dateTo.toIso8601String(),
          'sourceName': point.sourceName,
          'sourceId': point.sourceId,
        });
      }

      // Batch write to Firestore
      final firestore = FirebaseFirestore.instance;
      final batch = firestore.batch();

      groupedData.forEach((dateString, typesMap) {
        final docRef = firestore
            .collection('users')
            .doc(user.uid)
            .collection('health_data')
            .doc(dateString);

        // We use set with merge: true to avoid overwriting existing data for the same day that wasn't updated
        batch.set(docRef, {
          'last_synced': FieldValue.serverTimestamp(),
          'data': typesMap,
        }, SetOptions(merge: true));
      });

      await batch.commit();
      print("HealthService sync: Success.");
      return true;
    } catch (e) {
      print("HealthService sync error: \$e");
      return false;
    }
  }
}
