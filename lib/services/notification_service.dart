import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static const int lunchId = 101;
  static const int eveningId = 102;
  static const int appUpdateId = 201;
  static const int newServiceId = 301;
  static const int testId = 999;

  static const String _generalKey = 'notif_general';
  static const String _soundKey = 'notif_sound';
  static const String _vibrateKey = 'notif_vibrate';
  static const String _updateKey = 'notif_update';
  static const String _serviceKey = 'notif_service';

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    final timezoneInfo = await FlutterTimezone.getLocalTimezone();

    tz.setLocalLocation(tz.getLocation(timezoneInfo.identifier));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    await plugin.initialize(
      settings: const InitializationSettings(android: androidSettings),
    );

    _initialized = true;
  }

  Future<bool> requestPermission() async {
    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final granted = await androidPlugin?.requestNotificationsPermission();

    // Android versi lama bisa mengembalikan null karena
    // tidak memerlukan dialog izin notifikasi.
    return granted ?? true;
  }

  Future<bool> _isEnabled(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(key) ?? true;
  }

  Future<String> _createChannel({
    required String category,
    required String name,
    required String description,
  }) async {
    final soundEnabled = await _isEnabled(_soundKey);
    final vibrationEnabled = await _isEnabled(_vibrateKey);

    // ID berbeda untuk setiap kombinasi suara/getaran.
    // Android mengunci pengaturan channel setelah dibuat.
    final channelId =
        'waylo_${category}_s${soundEnabled ? 1 : 0}'
        '_v${vibrationEnabled ? 1 : 0}';

    final androidPlugin = plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        channelId,
        name,
        description: description,
        importance: Importance.high,
        playSound: soundEnabled,
        enableVibration: vibrationEnabled,
      ),
    );

    return channelId;
  }

  Future<NotificationDetails> _notificationDetails({
    required String category,
    required String name,
    required String description,
  }) async {
    final channelId = await _createChannel(
      category: category,
      name: name,
      description: description,
    );

    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        name,
        channelDescription: description,
        importance: Importance.high,
        priority: Priority.high,
        playSound: await _isEnabled(_soundKey),
        enableVibration: await _isEnabled(_vibrateKey),
      ),
    );
  }

  // GENERAL: notifikasi rutin harian.
  Future<void> updateSchedules() async {
    await initialize();

    await cancelRecommendations();

    final generalEnabled = await _isEnabled(_generalKey);

    if (!generalEnabled) return;

    await _scheduleDaily(
      id: lunchId,
      hour: 11,
      minute: 30,
      title: 'Lunch inspiration',
      body: 'Waktunya istirahat! Yuk, temukan tempat menarik di WAYLO.',
    );

    await _scheduleDaily(
      id: eveningId,
      hour: 19,
      minute: 30,
      title: 'Time to explore new places',
      body: 'Punya rencana untuk besok? Temukan destinasi baru bersama WAYLO!',
    );
  }

  Future<void> _scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    final details = await _notificationDetails(
      category: 'general',
      name: 'WAYLO Daily Recommendations',
      description: 'Pengingat dan rekomendasi harian WAYLO',
    );

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
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // APP UPDATE: panggil saat aplikasi memiliki informasi update.
  Future<void> showAppUpdate({
    required String title,
    required String body,
  }) async {
    await initialize();

    if (!await _isEnabled(_generalKey) || !await _isEnabled(_updateKey)) {
      return;
    }

    final details = await _notificationDetails(
      category: 'app_update',
      name: 'WAYLO App Updates',
      description: 'Informasi pembaruan aplikasi WAYLO',
    );

    await plugin.show(
      id: appUpdateId,
      title: title,
      body: body,
      notificationDetails: details,
      payload: 'app_update',
    );
  }

  // NEW SERVICE: panggil saat layanan/fitur baru tersedia.
  Future<void> showNewServiceAvailable({
    required String title,
    required String body,
  }) async {
    await initialize();

    if (!await _isEnabled(_generalKey) || !await _isEnabled(_serviceKey)) {
      return;
    }

    final details = await _notificationDetails(
      category: 'new_service',
      name: 'WAYLO New Services',
      description: 'Informasi layanan dan fitur baru WAYLO',
    );

    await plugin.show(
      id: newServiceId,
      title: title,
      body: body,
      notificationDetails: details,
      payload: 'new_service',
    );
  }

  Future<void> cancelRecommendations() async {
    await plugin.cancel(id: lunchId);
    await plugin.cancel(id: eveningId);
  }

  Future<void> cancelAllNotifications() async {
    await plugin.cancelAll();
  }

  Future<void> showTestNotification() async {
    await initialize();

    if (!await _isEnabled(_generalKey)) return;

    final details = await _notificationDetails(
      category: 'test',
      name: 'WAYLO Test',
      description: 'Notifikasi pengujian WAYLO',
    );

    await plugin.show(
      id: testId,
      title: 'Welcome to WAYLO ✈️',
      body: 'Notifikasi WAYLO berhasil diaktifkan!',
      notificationDetails: details,
    );
  }

  // Pengujian notifikasi saat aplikasi ditutup.
  // Future<void> scheduleTestInOneMinute() async {
  //   await initialize();

  //   if (!await _isEnabled(_generalKey)) {
  //     throw Exception('Aktifkan General Notification terlebih dahulu.');
  //   }

  //   final details = await _notificationDetails(
  //     category: 'background_test',
  //     name: 'WAYLO Background Test',
  //     description: 'Pengujian notifikasi saat aplikasi ditutup',
  //   );

  //   await plugin.zonedSchedule(
  //     id: 777,
  //     title: 'WAYLO Background Test ✈️',
  //     body: 'Berhasil! Notifikasi tetap berjalan saat aplikasi ditutup.',
  //     scheduledDate: tz.TZDateTime.now(
  //       tz.local,
  //     ).add(const Duration(minutes: 1)),
  //     notificationDetails: details,
  //     androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
  //   );
  //}
}
