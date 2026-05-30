import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(const InitializationSettings(android: android, iOS: ios));
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    try {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, badge: true, sound: false);
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      return granted ?? true;
    } catch (e, s) {
      if (kDebugMode) debugPrint('notif permission error: $e\n$s');
      return false;
    }
  }

  /// Daily reminder. Uses *inexact* alarms so Android 12+ doesn't require
  /// SCHEDULE_EXACT_ALARM permission. A wellness nudge doesn't need
  /// second-level precision. Any platform failure (denied permission,
  /// missing channel, etc.) is swallowed — never blocks onboarding.
  Future<void> scheduleDaily(int hour, int minute) async {
    try {
      await _plugin.cancel(1);
      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
      await _plugin.zonedSchedule(
        1,
        'A breath for you.',
        'A quiet minute of niyam — when you’re ready.',
        scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'niyam_daily',
            'Daily reminder',
            channelDescription: 'A gentle nudge to breathe',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'niyam://mood',
      );
    } catch (e, s) {
      if (kDebugMode) debugPrint('scheduleDaily failed: $e\n$s');
    }
  }

  Future<void> cancelAll() async => _plugin.cancelAll();
}
