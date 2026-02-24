import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/rxdart.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  debugPrint("[BACKGROUND] Click: ${notificationResponse.payload}");
}

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final BehaviorSubject<String?> onNotificationClick = BehaviorSubject();

  // Đổi sang v8 tiêu chuẩn để reset mọi cài đặt cũ
  static const String _channelId = 'medicare_standard_v8';
  static const String _channelName = 'Nhắc nhở Thuốc';

  Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));

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
          description: 'Kênh nhắc nhở uống thuốc tiêu chuẩn.',
          importance: Importance.max, // Để hiện Pop-up banner
          playSound: true,
          enableVibration: true,
        ));

        await androidPlugin.requestNotificationsPermission();
        
        final bool? canSchedule = await androidPlugin.canScheduleExactNotifications();
        if (canSchedule == false) {
          await androidPlugin.requestExactAlarmsPermission();
        }
      }
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
      final tz.TZDateTime scheduledDate = _nextInstanceOfTime(time);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id & 0x7FFFFFFF,
        title,
        body,
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
            // Bỏ fullScreenIntent để tránh bị hệ thống chặn âm thầm
            styleInformation: BigTextStyleInformation(''),
          ),
        ),
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint("[SERVICE] Đã đặt lịch: $title lúc $scheduledDate");
    } catch (e) {
      debugPrint("[SERVICE ERROR] Lỗi đặt lịch thuốc: $e");
    }
  }

  Future<void> scheduleTestNotification10s() async {
    try {
      final tz.TZDateTime scheduledDate = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));
      debugPrint("[TEST] Đang đặt lịch 10 giây tại: $scheduledDate");

      await flutterLocalNotificationsPlugin.zonedSchedule(
        888,
        '⏰ MediCare Test (10s)',
        'Hệ thống đặt lịch đã hoạt động!',
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint("[TEST ERROR] Lỗi 10s: $e");
    }
  }

  Future<void> showTestNotification() async {
    await flutterLocalNotificationsPlugin.show(
      999,
      'MediCare Now',
      'Thông báo tức thì!',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId, 
          _channelName, 
          importance: Importance.max, 
          priority: Priority.high
        ),
      ),
    );
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(tz.local, now.year, now.month, now.day, time.hour, time.minute);
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelNotification(int id) async =>
      await flutterLocalNotificationsPlugin.cancel(id & 0x7FFFFFFF);
}
