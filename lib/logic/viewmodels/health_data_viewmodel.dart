import 'package:flutter/foundation.dart';
import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medicare/logic/services/health_services.dart';

class HealthDataViewModel extends ChangeNotifier {
  bool _isConnected = false;
  bool _isLoading = true;

  int _todaySteps = 0;
  int _latestHeartRate = 0;
  int _latestBloodOxygen = 0;
  String _sleepDuration = "0h 0m";
  int _stepGoal = 10000;
  List<int> _weeklyStepsChart = List.filled(7, 0);

  // Detailed Sleep Metrics
  int _sleepTotalMinutes = 0;
  int _sleepDeepMinutes = 0;
  int _sleepLightMinutes = 0;
  int _sleepAwakeMinutes = 0;
  int _sleepRemMinutes = 0;
  int _sleepScore = 0;
  int _sleepingHeartRateAvg = 0;
  List<double> _sleepingHeartRateChart = [];

  // Sleep Schedule
  String _bedtimeHour = "22";
  String _bedtimeMinute = "30";
  String _wakeUpHour = "06";
  String _wakeUpMinute = "30";
  bool _alarmEnabled = true;
  List<String> _selectedSleepDays = ["0", "1", "2", "3", "4"];

  bool get isConnected => _isConnected;
  bool get isLoading => _isLoading;
  int get todaySteps => _todaySteps;
  int get latestHeartRate => _latestHeartRate;
  int get latestBloodOxygen => _latestBloodOxygen;
  String get sleepDuration => _sleepDuration;
  int get stepGoal => _stepGoal;
  List<int> get weeklyStepsChart => _weeklyStepsChart;

  int get sleepTotalMinutes => _sleepTotalMinutes;
  int get sleepDeepMinutes => _sleepDeepMinutes;
  int get sleepLightMinutes => _sleepLightMinutes;
  int get sleepAwakeMinutes => _sleepAwakeMinutes;
  int get sleepRemMinutes => _sleepRemMinutes;
  int get sleepScore => _sleepScore;
  int get sleepingHeartRateAvg => _sleepingHeartRateAvg;
  List<double> get sleepingHeartRateChart => _sleepingHeartRateChart;

  String get bedtimeHour => _bedtimeHour;
  String get bedtimeMinute => _bedtimeMinute;
  String get wakeUpHour => _wakeUpHour;
  String get wakeUpMinute => _wakeUpMinute;
  bool get alarmEnabled => _alarmEnabled;
  List<int> get selectedSleepDays => _selectedSleepDays.map((e) => int.parse(e)).toList();

  final HealthService _healthService = HealthService();
  final Health _health = Health();

  HealthDataViewModel() {
    loadData();
  }

  Future<void> checkConnectionStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isConnected = prefs.getBool('health_connect_connected') ?? false;
    _stepGoal = prefs.getInt('step_goal') ?? 10000;
    
    _bedtimeHour = prefs.getString('sleep_bedtime_hour') ?? "22";
    _bedtimeMinute = prefs.getString('sleep_bedtime_minute') ?? "30";
    _wakeUpHour = prefs.getString('sleep_wakeup_hour') ?? "06";
    _wakeUpMinute = prefs.getString('sleep_wakeup_minute') ?? "30";
    _alarmEnabled = prefs.getBool('sleep_alarm_enabled') ?? true;
    _selectedSleepDays = prefs.getStringList('sleep_selected_days') ?? ["0", "1", "2", "3", "4"];
    
    notifyListeners();
  }

  Future<void> updateStepGoal(int newGoal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('step_goal', newGoal);
    _stepGoal = newGoal;
    notifyListeners();
  }

  Future<void> saveSleepSchedule({
    required String bedtimeHour,
    required String bedtimeMinute,
    required String wakeUpHour,
    required String wakeUpMinute,
    required bool alarmEnabled,
    required List<int> selectedDays,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('sleep_bedtime_hour', bedtimeHour);
    await prefs.setString('sleep_bedtime_minute', bedtimeMinute);
    await prefs.setString('sleep_wakeup_hour', wakeUpHour);
    await prefs.setString('sleep_wakeup_minute', wakeUpMinute);
    await prefs.setBool('sleep_alarm_enabled', alarmEnabled);
    await prefs.setStringList('sleep_selected_days', selectedDays.map((e) => e.toString()).toList());

    _bedtimeHour = bedtimeHour;
    _bedtimeMinute = bedtimeMinute;
    _wakeUpHour = wakeUpHour;
    _wakeUpMinute = wakeUpMinute;
    _alarmEnabled = alarmEnabled;
    _selectedSleepDays = selectedDays.map((e) => e.toString()).toList();
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

      // Ensure configured before any direct _health calls
      await _healthService.isAvailable();

      // 1. Fetch Steps
      int? steps = await _health.getTotalStepsInInterval(midnight, now);
      _todaySteps = steps ?? 0;

      // 1.5 Fetch Weekly Steps
      _weeklyStepsChart = List.filled(7, 0);
      for (int i = 0; i < 7; i++) {
        final start = DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
        final end = (i == 6) ? now : start.add(const Duration(days: 1));
        int? daySteps = await _health.getTotalStepsInInterval(start, end);
        _weeklyStepsChart[i] = daySteps ?? 0;
      }

      // 2. Fetch Latest Heart Rate
      final hrPoints = await _healthService.fetchHeartRate(days: 1);
      if (hrPoints.isNotEmpty) {
        hrPoints.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        final latestPoint = hrPoints.first;
        if (latestPoint.value is NumericHealthValue) {
          _latestHeartRate = (latestPoint.value as NumericHealthValue).numericValue.round();
        }
      }

      // 2.5 Fetch Latest Blood Oxygen
      final spO2Points = await _healthService.fetchBloodOxygen(days: 7);
      if (spO2Points.isNotEmpty) {
        spO2Points.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        final latestSpO2 = spO2Points.first;
        if (latestSpO2.value is NumericHealthValue) {
          _latestBloodOxygen = (latestSpO2.value as NumericHealthValue).numericValue.round();
        }
      } else {
        _latestBloodOxygen = 98; // Fallback mock value
      }

      // 3. Fetch Sleep (Detailed stages)
      final sleepStartTime = now.subtract(const Duration(days: 1));
      final sleepPoints = await _health.getHealthDataFromTypes(
        startTime: sleepStartTime,
        endTime: now,
        types: [
          HealthDataType.SLEEP_ASLEEP,
          HealthDataType.SLEEP_AWAKE,
          HealthDataType.SLEEP_DEEP,
          HealthDataType.SLEEP_LIGHT,
          HealthDataType.SLEEP_REM,
        ],
      );

      _sleepDeepMinutes = 0;
      _sleepLightMinutes = 0;
      _sleepAwakeMinutes = 0;
      _sleepRemMinutes = 0;
      _sleepTotalMinutes = 0;

      DateTime? actualSleepStart;
      DateTime? actualSleepEnd;

      if (sleepPoints.isNotEmpty) {
        for (var point in sleepPoints) {
          if (actualSleepStart == null || point.dateFrom.isBefore(actualSleepStart)) {
            actualSleepStart = point.dateFrom;
          }
          if (actualSleepEnd == null || point.dateTo.isAfter(actualSleepEnd)) {
            actualSleepEnd = point.dateTo;
          }

          if (point.value is NumericHealthValue) {
            int minutes = (point.value as NumericHealthValue).numericValue.round();
            if (point.type == HealthDataType.SLEEP_DEEP) {
              _sleepDeepMinutes += minutes;
            } else if (point.type == HealthDataType.SLEEP_LIGHT) {
              _sleepLightMinutes += minutes;
            } else if (point.type == HealthDataType.SLEEP_AWAKE) {
              _sleepAwakeMinutes += minutes;
            } else if (point.type == HealthDataType.SLEEP_REM) {
              _sleepRemMinutes += minutes;
            } else if (point.type == HealthDataType.SLEEP_ASLEEP) {
              // Fallback if device only provides SLEEP_ASLEEP
              _sleepTotalMinutes += minutes;
            }
          }
        }

        // Priority to detailed stages if they exist
        int detailedTotal = _sleepDeepMinutes + _sleepLightMinutes + _sleepRemMinutes;
        if (detailedTotal > 0) {
          _sleepTotalMinutes = detailedTotal;
        }

        if (_sleepTotalMinutes > 0) {
          int hours = _sleepTotalMinutes ~/ 60;
          int remainingMinutes = _sleepTotalMinutes % 60;
          _sleepDuration = "\${hours}h \${remainingMinutes}m";

          // Calculate a simple mock score
          double deepRatio = _sleepTotalMinutes > 0 ? (_sleepDeepMinutes / _sleepTotalMinutes) : 0;
          double durationScore = (_sleepTotalMinutes / 480).clamp(0.0, 1.0); // 8 hours optimal
          _sleepScore = ((durationScore * 60) + (deepRatio * 150).clamp(0.0, 40.0)).round();
        }

        // Fetch Heart Rate during sleep session
        if (actualSleepStart != null && actualSleepEnd != null) {
          final sleepHrPoints = await _health.getHealthDataFromTypes(
            startTime: actualSleepStart,
            endTime: actualSleepEnd,
            types: [HealthDataType.HEART_RATE],
          );

          if (sleepHrPoints.isNotEmpty) {
            double sumHr = 0;
            for (var pt in sleepHrPoints) {
              if (pt.value is NumericHealthValue) {
                sumHr += (pt.value as NumericHealthValue).numericValue;
              }
            }
            _sleepingHeartRateAvg = (sumHr / sleepHrPoints.length).round();

            // Segment into 16 parts for the chart
            int segments = 16;
            _sleepingHeartRateChart = List.filled(segments, 0.0);
            int durationMs = actualSleepEnd.difference(actualSleepStart).inMilliseconds;
            
            if (durationMs > 0) {
              List<List<double>> segmentValues = List.generate(segments, (_) => []);
              
              for (var pt in sleepHrPoints) {
                if (pt.value is NumericHealthValue) {
                  double val = (pt.value as NumericHealthValue).numericValue.toDouble();
                  int ptOffsetMs = pt.dateFrom.difference(actualSleepStart).inMilliseconds;
                  int index = ((ptOffsetMs / durationMs) * segments).floor();
                  if (index >= 0 && index < segments) {
                    segmentValues[index].add(val);
                  }
                }
              }

              double maxHr = 1.0; // To normalize
              for (int i = 0; i < segments; i++) {
                if (segmentValues[i].isNotEmpty) {
                  double avg = segmentValues[i].reduce((a, b) => a + b) / segmentValues[i].length;
                  _sleepingHeartRateChart[i] = avg;
                  if (avg > maxHr) maxHr = avg;
                }
              }

              // Normalize between 0.3 and 0.8 mostly for UI
              for (int i = 0; i < segments; i++) {
                if (_sleepingHeartRateChart[i] > 0) {
                  _sleepingHeartRateChart[i] = 0.3 + ((_sleepingHeartRateChart[i] / maxHr) * 0.5);
                } else {
                  _sleepingHeartRateChart[i] = 0.3; // Fallback
                }
              }
            }
          }
        }
      } else {
        _sleepDuration = "0h 0m";
      }
    } catch (e) {
      debugPrint("Error fetching local health data: \$e");
    }
  }

  void debugMockData() {
    _todaySteps = 8432;
    _latestHeartRate = 72;
    _latestBloodOxygen = 98;
    _sleepDuration = "7h 20m";
    _sleepTotalMinutes = 440;
    _sleepDeepMinutes = 135;
    _sleepLightMinutes = 250;
    _sleepAwakeMinutes = 55;
    _sleepRemMinutes = 0;
    _sleepScore = 85;
    _sleepingHeartRateAvg = 58;
    _sleepingHeartRateChart = [
      0.40, 0.45, 0.38, 0.50, 0.60, 0.55, 0.48, 0.75,
      0.65, 0.58, 0.50, 0.42, 0.40, 0.35, 0.38, 0.45,
    ];
    notifyListeners();
  }
}
