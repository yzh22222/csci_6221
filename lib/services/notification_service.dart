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

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await notifications.initialize(settings);
    // NEW: Request permission for Android 13+ and iOS
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    // iOS
    await notifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);

    // Android 13+ runtime permission
    await notifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> sendDemoNotification(String itemName) async {
    const androidDetails = AndroidNotificationDetails(
      'demo_channel',
      'Demo Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await notifications.show(
      999, // fixed ID for demo notifications
      'Heads up!',
      '$itemName is expiring soon!',
      details,
    );
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
      '$foodName expires soon!',
      tz.TZDateTime.from(notifyTime, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
