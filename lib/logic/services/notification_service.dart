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
  // background handled
}

class MedicationNotificationRequest {
  final int id;
  final String title;
  final String body;
  final TimeOfDay time;
  final String payload;

  const MedicationNotificationRequest({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.payload,
  });
}

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();
  Future<void>? _initFuture;
  bool _isInitialized = false;

  static const String _channelId = 'medicare_urgent_v9';
  static const String _channelName = 'Medication Reminders';

  Future<void> init({bool requestPermissions = false}) async {
    if (!_isInitialized) {
      _initFuture ??= _initializePlugin();
      try {
        await _initFuture;
      } catch (_) {
        _initFuture = null;
        rethrow;
      }
    }

    if (requestPermissions) {
      await _requestPlatformPermissions();
    }
  }

  Future<void> _initializePlugin() async {
    _initTimezone();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    final InitializationSettings initializationSettings =
        InitializationSettings(
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
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          const AndroidNotificationChannel(
            _channelId,
            _channelName,
            description:
                'Highest priority notification channel for medication reminders.',
            importance: Importance.max,
            playSound: true,
            enableVibration: true,
          ),
        );
      }
    }

    _isInitialized = true;
  }

  Future<bool> requestPermissions() async {
    await init();
    return _requestPlatformPermissions();
  }

  Future<bool> _requestPlatformPermissions() async {
    bool granted = false;
    if (Platform.isIOS) {
      final iosPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      final result = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      granted = result ?? false;
    } else if (Platform.isAndroid) {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        final result = await androidPlugin.requestNotificationsPermission();
        granted = result ?? false;
        final bool? canSchedule = await androidPlugin
            .canScheduleExactNotifications();
        if (canSchedule == false) {
          await androidPlugin.requestExactAlarmsPermission();
        }
      }
    }
    return granted;
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
      await init();
      final prefs = await SharedPreferences.getInstance();
      final bool masterEnabled = prefs.getBool('pushNotifications') ?? true;
      final bool medsEnabled = prefs.getBool('medicationReminders') ?? true;

      if (!masterEnabled || !medsEnabled) {
        return;
      }

      await _scheduleDailyMedicationNotificationUnchecked(
        id: id,
        title: title,
        body: body,
        time: time,
        payload: payload,
      );
    } catch (e) {
      // ignore
    }
  }

  Future<void> scheduleDailyMedicationNotifications(
    Iterable<MedicationNotificationRequest> requests,
  ) async {
    try {
      await init();
      final prefs = await SharedPreferences.getInstance();
      final bool masterEnabled = prefs.getBool('pushNotifications') ?? true;
      final bool medsEnabled = prefs.getBool('medicationReminders') ?? true;

      if (!masterEnabled || !medsEnabled) {
        return;
      }

      for (final request in requests) {
        await _scheduleDailyMedicationNotificationUnchecked(
          id: request.id,
          title: request.title,
          body: request.body,
          time: request.time,
          payload: request.payload,
        );
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _scheduleDailyMedicationNotificationUnchecked({
    required int id,
    required String title,
    required String body,
    required TimeOfDay time,
    required String payload,
  }) async {
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
          icon: '@mipmap/launcher_icon',
          styleInformation: BigTextStyleInformation(body, contentTitle: title),
        ),
      ),
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await init();
      final prefs = await SharedPreferences.getInstance();
      final bool masterEnabled = prefs.getBool('pushNotifications') ?? true;
      if (!masterEnabled) return;

      final safeId = id & 0x7FFFFFFF;
      await flutterLocalNotificationsPlugin.show(
        safeId,
        title,
        body,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.max,
            priority: Priority.max,
            showWhen: true,
            icon: '@mipmap/launcher_icon',
          ),
        ),
        payload: payload,
      );
    } catch (e) {
      // ignore
    }
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    _initTimezone();
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If the time already passed, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async {
    await init();
    await flutterLocalNotificationsPlugin.cancel(id & 0x7FFFFFFF);
  }
}
