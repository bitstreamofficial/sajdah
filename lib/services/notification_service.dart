// services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notifications.initialize(initializationSettings);
  }

  Future<void> schedulePrayerNotification(
    String prayerName,
    DateTime prayerTime,
  ) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'prayer_channel',
          'Prayer Notifications',
          channelDescription: 'Notifications for prayer times',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    // Schedule notification 10 minutes before prayer time
    final scheduledTime = prayerTime.subtract(const Duration(minutes: 10));

    // await _notifications.zonedSchedule(
    //   prayerName.hashCode,
    //   'Prayer Time Reminder',
    //   '$prayerName prayer is in 10 minutes',
    //   tz.TZDateTime.from(scheduledTime, tz.local),
    //   platformChannelSpecifics,
    //   uiLocalNotificationDateInterpretation:
    //       UILocalNotificationDateInterpretation.absoluteTime,
    //   matchDateTimeComponents: DateTimeComponents.time, androidScheduleMode: null,
    // );
  }

  Future<void> showPrayerTimeNotification(String prayerName) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'prayer_now_channel',
          'Prayer Time Now',
          channelDescription: 'Current prayer time notifications',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await _notifications.show(
      0,
      'Prayer Time',
      'It\'s time for $prayerName prayer',
      platformChannelSpecifics,
    );
  }
}
