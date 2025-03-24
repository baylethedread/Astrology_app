import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:astrology_ui/main.dart'; // Import main.dart to access the top-level navigatorKey

class NotificationService {
  static final NotificationService _notificationService = NotificationService._internal();
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  Future<void> init() async {
    // Initialize time zones
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/New_York')); // Set your desired time zone

    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // Combine settings for both platforms
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        if (response.payload != null && response.payload!.startsWith('horoscope|')) {
          final zodiacSign = response.payload!.split('|')[1];
          // Add a slight delay to ensure the app is fully initialized
          if (navigatorKey.currentState == null) {
            Future.delayed(const Duration(milliseconds: 500), () {
              navigatorKey.currentState?.pushNamed(
                '/horoscope',
                arguments: {'initialZodiacSign': zodiacSign},
              );
            });
          } else {
            navigatorKey.currentState?.pushNamed(
              '/horoscope',
              arguments: {'initialZodiacSign': zodiacSign},
            );
          }
        }
      },
    );

    // Request permissions for Android 13+
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final bool? granted = await androidPlugin.requestNotificationsPermission();
      if (granted == false) {
        print('Notification permissions denied');
        // Optionally, you can notify the user to enable permissions in settings
      }
    }

    // Request permissions for iOS
    final iosPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosPlugin != null) {
      await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> scheduleDailyHoroscopeNotification(String title, String body, String zodiacSign) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'daily_horoscope_channel',
      'Daily Horoscope',
      channelDescription: 'Daily horoscope notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    try {
      // Schedule the notification for 8:00 AM every day
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        0, // Notification ID (unique for each notification)
        title,
        body,
        _nextInstanceOfEightAM(),
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // Repeat daily at the specified time
        payload: 'horoscope|$zodiacSign', // Include zodiac sign in the payload
      );
      print('Scheduled daily horoscope notification for $zodiacSign');
    } catch (e) {
      print('Failed to schedule notification: $e');
    }
  }

  tz.TZDateTime _nextInstanceOfEightAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      8, // 8:00 AM
      0,
      0,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      print('All notifications canceled');
    } catch (e) {
      print('Failed to cancel notifications: $e');
    }
  }
}