
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance =
      NotificationService._();

  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static const int lunchId = 101;
  static const int afternoonId = 102;
  static const int testId = 999;

  static const String recommendationChannel =
      'waylo_recommendations';

  Future<void> initialize() async {
    tz_data.initializeTimeZones();

    final timezoneInfo =
        await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(
      tz.getLocation(timezoneInfo.identifier),
    );

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await plugin.initialize(
      settings: const InitializationSettings(
        android: androidSettings,
      ),
    );
  }

  Future<bool> requestPermission() async {
    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final granted =
        await androidPlugin?.requestNotificationsPermission();

    return granted ?? false;
  }

  Future<void> updateSchedules() async {
    final prefs = await SharedPreferences.getInstance();

    final generalEnabled =
        prefs.getBool('notif_general') ?? true;

    final serviceEnabled =
        prefs.getBool('notif_service') ?? true;

    await cancelRecommendations();

    if (!generalEnabled || !serviceEnabled) {
      return;
    }

    await _scheduleDaily(
      id: lunchId,
      hour: 11,
      minute: 30,
      title: 'Lunch inspiration 🍜',
      body:
          'Lagi jam makan siang, yuk temukan tempat menarik di WAYLO!',
    );

    await _scheduleDaily(
      id: afternoonId,
      hour: 15,
      minute: 30,
      title: 'Time to explore 🌿',
      body:
          'Bosan di rumah? Yuk, temukan destinasi baru bersama WAYLO!',
    );
  }

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final now = tz.TZDateTime.now(tz.local);

    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          recommendationChannel,
          'WAYLO Recommendations',
          channelDescription:
              'Rekomendasi destinasi dari WAYLO',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelRecommendations() async {
    await plugin.cancel(id: lunchId);
    await plugin.cancel(id: afternoonId);
  }

  Future<void> cancelAllNotifications() async {
    await plugin.cancelAll();
  }

  Future<void> showTestNotification() async {
    await plugin.show(
      id: testId,
      title: 'Welcome to WAYLO ✈️',
      body: 'Notifikasi WAYLO berhasil diaktifkan!',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'waylo_test',
          'WAYLO Test',
          channelDescription:
              'Notifikasi pengujian WAYLO',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        ),
      ),
    );
  }
}
