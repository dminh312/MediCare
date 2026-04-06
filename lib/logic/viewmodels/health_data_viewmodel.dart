import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicare/logic/services/health_services.dart';

class HealthDataViewModel extends ChangeNotifier {
  bool _isConnected = false;
  bool _isLoading = true;
  
  int _todaySteps = 0;
  int _latestHeartRate = 0;
  String _sleepDuration = "0h 0m";

  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  int get todaySteps => _todaySteps;
  int get latestHeartRate => _latestHeartRate;
  String get sleepDuration => _sleepDuration;

  final HealthService _healthService = HealthService();
  final Health _health = Health();

  HealthDataViewModel() {
    loadData();
  }

  Future<void> checkConnectionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isConnected = prefs.getBool('health_connect_connected') ?? false;
    notifyListeners();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    await checkConnectionStatus();

    if (_isConnected) {
      await _fetchTodayData();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _fetchTodayData() async {
    try {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      // 1. Fetch Steps
      int? steps = await _health.getTotalStepsInInterval(midnight, now);
      _todaySteps = steps ?? 0;

      // 2. Fetch Latest Heart Rate
      final hrPoints = await _healthService.fetchHeartRate(days: 1);
      if (hrPoints.isNotEmpty) {
        // Sort by dateTo descending
        hrPoints.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        final latestPoint = hrPoints.first;
        if (latestPoint.value is NumericHealthValue) {
          _latestHeartRate = (latestPoint.value as NumericHealthValue).numericValue.round();
        }
      }

      // 3. Fetch Sleep (basic aggregation for today)
      final sleepPoints = await _health.getHealthDataFromTypes(
        startTime: now.subtract(const Duration(days: 1)),
        endTime: now,
        types: [HealthDataType.SLEEP_ASLEEP],
      );
      
      if (sleepPoints.isNotEmpty) {
        int totalSleepMinutes = 0;
        for (var point in sleepPoints) {
          if (point.value is NumericHealthValue) {
            totalSleepMinutes += (point.value as NumericHealthValue).numericValue.round();
          }
        }
        
        if (totalSleepMinutes > 0) {
          int hours = totalSleepMinutes ~/ 60;
          int remainingMinutes = totalSleepMinutes % 60;
          _sleepDuration = "\${hours}h \${remainingMinutes}m";
        }
      } else {
        _sleepDuration = "0h 0m";
      }

    } catch (e) {
      debugPrint("Error fetching local health data: \$e");
    }
  }

  void debugMockData() {
    // Inject mock data for UI testing if desired
    _todaySteps = 8432;
    _latestHeartRate = 72;
    _sleepDuration = "7h 20m";
    notifyListeners();
  }
}
