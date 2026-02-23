import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService._();
  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const Map<String, int> _ids = {
    'Morning': 2001,
    'Afternoon': 2002,
    'Evening': 2003,
  };

  static const Map<String, ({int hour, int minute})> _times = {
    'Morning': (hour: 6, minute: 0),
    'Afternoon': (hour: 13, minute: 0),
    'Evening': (hour: 18, minute: 0),
  };

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    _initialized = true;
  }

  Future<void> scheduleFeedingReminders({
    required bool enabled,
    required List<String> times,
  }) async {
    await init();

    for (final id in _ids.values) {
      await _plugin.cancel(id);
    }

    if (!enabled) return;

    for (final key in times) {
      final id = _ids[key];
      final slot = _times[key];
      if (id == null || slot == null) continue;

      await _plugin.zonedSchedule(
        id,
        'Feeding Reminder',
        'It\'s time for $key feeding.',
        _nextInstance(slot.hour, slot.minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'feeding_reminders',
            'Feeding Reminders',
            channelDescription: 'Daily reminders for animal feeding schedules',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
