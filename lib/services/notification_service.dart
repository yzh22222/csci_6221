import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notifications.initialize(settings);
  }

  Future<void> scheduleExpiryNotification(
    int id,
    String foodName,
    DateTime expiryDate,
  ) async {
    final androidDetails = const AndroidNotificationDetails(
      'expiry_channel',
      'Food Expiry Notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    DateTime notifyTime = expiryDate.subtract(const Duration(days: 1));
    if (notifyTime.isBefore(DateTime.now())) {
      notifyTime = DateTime.now().add(const Duration(seconds: 5));
    }

    await notifications.zonedSchedule(
      id,
      'Food Expiring Soon!',
      '$foodName expires tomorrow!',
      tz.TZDateTime.from(notifyTime, tz.local),
      notificationDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }
}
