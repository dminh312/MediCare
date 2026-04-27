import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const int currentFlowVersion = 3;

  static const String completedKey = 'has_completed_onboarding';
  static const String flowVersionKey = 'onboarding_flow_version';

  static bool hasCompletedCurrentFlow(SharedPreferences prefs) {
    final hasCompleted = prefs.getBool(completedKey) ?? false;
    final completedVersion = prefs.getInt(flowVersionKey) ?? 0;

    return hasCompleted && completedVersion >= currentFlowVersion;
  }

  static Future<void> markCompleted(SharedPreferences prefs) async {
    await prefs.setBool(completedKey, true);
    await prefs.setInt(flowVersionKey, currentFlowVersion);
  }

  static Future<void> reset(SharedPreferences prefs) async {
    await prefs.remove(completedKey);
    await prefs.remove(flowVersionKey);
    await prefs.remove('health_connect_connected');
    await prefs.remove('has_seen_walkthrough');
  }
}
