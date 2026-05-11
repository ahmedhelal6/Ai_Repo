import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static const int _dailyReminderId = 1;
  static bool _initialized = false;

  // =========================================================
  // INIT
  // =========================================================
  static Future<void> init() async {
    if (_initialized) return;

    try {
      // 1. Timezone - Get device local timezone
      tz_data.initializeTimeZones();
      
      // In flutter_timezone 5.0.2, getLocalTimezone returns a TimezoneInfo object
      final info = await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = info.identifier;
      
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('✅ Timezone set to: $timeZoneName');

      // 2. Settings
      const androidSettings = AndroidInitializationSettings('launcher_icon');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // 3. Initialize
      final bool? initialized = await _plugin.initialize(
        settings: const InitializationSettings(android: androidSettings, iOS: iosSettings),
        onDidReceiveNotificationResponse: (details) {
          debugPrint('🔔 Notification tapped: ${details.payload}');
        },
      );

      // 4. Android Channel
      await _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(
        const AndroidNotificationChannel(
          'daily_workout_reminder_channel',
          'Daily Workout Reminder',
          description: 'Reminds you to work out every day',
          importance: Importance.max,
          playSound: true,
        ),
      );

      _initialized = initialized ?? false;
      debugPrint('✅ NotificationService status: $_initialized');
    } catch (e) {
      debugPrint('❌ NotificationService Init Error: $e');
    }
  }

  // =========================================================
  // SCHEDULE
  // =========================================================
  static Future<bool> scheduleDailyNotification({
    required int hour,
    required int minute,
  }) async {
    try {
      await init();

      // Request permissions explicitly
      if (Platform.isAndroid) {
        final androidPlugin = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
        await androidPlugin?.requestNotificationsPermission();
        
        // Exact Alarm for Android 13+
        if (await androidPlugin?.canScheduleExactNotifications() == false) {
          await androidPlugin?.requestExactAlarmsPermission();
        }
      } else if (Platform.isIOS) {
        await _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true);
      }

      // Cancel previous
      await _plugin.cancel(id: _dailyReminderId);

      // Schedule
      final scheduledTime = _nextInstanceOfTime(hour, minute);
      
      await _plugin.zonedSchedule(
        id: _dailyReminderId,
        title: '💪 Workout Time!',
        body: 'Don\'t miss your training session today. Let\'s go!',
        scheduledDate: scheduledTime,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_workout_reminder_channel',
            'Daily Workout Reminder',
            importance: Importance.max,
            priority: Priority.high,
            icon: 'launcher_icon',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        // In v21.0.0 uiLocalNotificationDateInterpretation is no longer needed/supported
      );

      debugPrint('🚀 Reminder scheduled for $scheduledTime');
      return true;
    } catch (e) {
      debugPrint('❌ Scheduling Error: $e');
      return false;
    }
  }

  static tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static Future<void> cancelDailyNotification() async {
    await _plugin.cancel(id: _dailyReminderId);
  }
}