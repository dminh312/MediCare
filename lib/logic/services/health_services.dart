import 'package:health/health.dart';

class HealthService {
  final Health _health = Health();

  static const List<HealthDataType> _types = [
    HealthDataType.HEART_RATE,
    HealthDataType.STEPS,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.BLOOD_OXYGEN,
  ];

  static const List<HealthDataAccess> _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
  ];

  // Check Health Connect available (Android only)
  Future<bool> isAvailable() async {
    return await _health.isHealthConnectAvailable();
  }

  // Request permission
  Future<bool> requestPermission() async {
    return await _health.requestAuthorization(_types, permissions: _permissions);
  }

  // Check if permission already granted
  Future<bool> hasPermission() async {
    return await _health.hasPermissions(_types, permissions: _permissions) ?? false;
  }

  // Fetch data
  Future<List<HealthDataPoint>> fetchHealthData({int days = 1}) async {
    final now = DateTime.now();
    final startTime = now.subtract(Duration(days: days));

    final dataPoints = await _health.getHealthDataFromTypes(
      startTime: startTime,
      endTime: now,
      types: _types,
    );

    return Health.removeDuplicates(dataPoints);
  }

  // Fetch heart rate only
  Future<List<HealthDataPoint>> fetchHeartRate({int days = 1}) async {
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
    final now = DateTime.now();
    final startTime = now.subtract(Duration(days: days));

    return await _health.getHealthDataFromTypes(
      startTime: startTime,
      endTime: now,
      types: [HealthDataType.BLOOD_OXYGEN],
    );
  }
}