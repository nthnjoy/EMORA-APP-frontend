import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (kIsWeb) return;
    
    try {
      tz.initializeTimeZones();
      final String timeZoneName = (await FlutterTimezone.getLocalTimezone()).identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _notificationsPlugin.initialize(
        settings,
        onDidReceiveNotificationResponse: (details) {
          debugPrint('Notification clicked: ${details.payload}');
        },
      );

      await requestPermissions();
    } catch (e) {
      debugPrint('NotificationService Init Error: $e');
    }
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    
    try {
      // For iOS
      await _notificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );

      // For Android 13+
      final androidPlugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
        await androidPlugin.requestExactAlarmsPermission();
      }
    } catch (e) {
      debugPrint('Permission Request Error: $e');
    }
  }

  Future<void> scheduleDailyNotification(TimeOfDay time) async {
    if (kIsWeb) return;

    try {
      await _notificationsPlugin.cancelAll();

      final now = tz.TZDateTime.now(tz.local);
      var scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );

      // Jika waktu sudah terlewat hari ini, schedule untuk besok
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      debugPrint('⏰ Scheduling daily notification for: ${scheduledDate.toString()}');
      debugPrint('⏰ Current time: ${now.toString()}');

      // Android notification details dengan importance maksimal
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'daily_reminder_channel',
        'Pengingat Harian EMOLENS',
        channelDescription: 'Mengingatkan Anda untuk mencatat mood harian.',
        importance: Importance.max,
        priority: Priority.max,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        fullScreenIntent: true,
        autoCancel: true,
      );

      // iOS notification details
      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        threadIdentifier: 'daily_reminder_channel',
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Schedule dengan inexactAllowWhileIdle dan matchDateTimeComponents untuk daily recurring
      // matchDateTimeComponents.time = repeat every hari di jam yang sama
      await _notificationsPlugin.zonedSchedule(
        0,
        'EMOLENS - Waktunya Check-in!',
        'Jangan lupa catat mood dan ceritamu hari ini ya.',
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint('✅ Notifikasi berhasil dijadwalkan!');
    } catch (e) {
      debugPrint('❌ Error scheduling notification: $e');
    }
  }

  Future<void> showImmediateNotification() async {
    if (kIsWeb) return;

    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'test_channel_id',
        'Uji Coba Notifikasi',
        channelDescription: 'Channel untuk mengetes notifikasi EMOLENS',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );

      const NotificationDetails details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _notificationsPlugin.show(
        99,
        'EMOLENS - Test Notifikasi',
        'Notifikasi berhasil diaktifkan dan berjalan!',
        details,
      );
    } catch (e) {
      debugPrint('Error showing immediate notification: $e');
    }
  }

  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _notificationsPlugin.cancelAll();
  }
}
