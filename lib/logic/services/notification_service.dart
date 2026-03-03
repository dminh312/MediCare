import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // Ensure timezones are loaded in this isolated background entry point
  if (!tz.timeZoneDatabase.isInitialized) {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
  }
  debugPrint("[BACKGROUND] Clicked notification: ${notificationResponse.payload}");
}

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();

  static const String _channelId = 'medicare_urgent_v9';
  static const String _channelName = 'Medication Reminders';

  Future<void> init() async {
    _initTimezone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          onNotificationClick.add(response.payload);
        }
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );

    if (Platform.isAndroid) {
      final androidPlugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: 'Highest priority notification channel for medication reminders.',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
        ));

        // Request required permissions for Android 13+ and Android 12+
        await androidPlugin.requestNotificationsPermission();
        final bool? canSchedule = await androidPlugin.canScheduleExactNotifications();
        if (canSchedule == false) {
          await androidPlugin.requestExactAlarmsPermission();
        }
      }
    }
  }

  static void _initTimezone() {
    if (!tz.timeZoneDatabase.isInitialized) {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    }
  }

  Future<void> scheduleDailyMedicationNotification({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required String payload,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool masterEnabled = prefs.getBool('pushNotifications') ?? true;
      final bool medsEnabled = prefs.getBool('medicationReminders') ?? true;

      if (!masterEnabled || !medsEnabled) {
        debugPrint("[SERVICE] Skipped medication reminder ($title) because user disabled notifications.");
        return;
      }

      final tz.TZDateTime scheduledDate = _nextInstanceOfTime(time);
      final int safeId = id & 0x7FFFFFFF;

      await flutterLocalNotificationsPlugin.zonedSchedule(
        safeId,
        title,
        body,
        scheduledDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.max,
            priority: Priority.max,
            showWhen: true,
            icon: '@mipmap/ic_launcher',
            styleInformation: BigTextStyleInformation(body, contentTitle: title),
          ),
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint("[SERVICE] Scheduled medication: $title at $scheduledDate (ID: $safeId)");
    } catch (e) {
      debugPrint("[SERVICE ERROR] Error scheduling medication: $e");
    }
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    _initTimezone();
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);

    // If the time already passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async =>
      await flutterLocalNotificationsPlugin.cancel(id & 0x7FFFFFFF);
}
