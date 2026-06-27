import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:get/get.dart';
import 'config_service.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize all timezone database entries
      tz.initializeTimeZones();

      // Use the shop's configured timezone from ConfigService as the source of truth.
      // This ensures all staff devices schedule alarms at the correct shop-local time,
      // regardless of the device's own timezone setting.
      final configService = Get.find<ConfigService>();
      final shopTimeZone = configService.timeZone.value;

      try {
        tz.setLocalLocation(tz.getLocation(shopTimeZone));
        log("Timezone set to shop config: $shopTimeZone");
      } catch (_) {
        // Fallback: if the admin-configured timezone string is invalid,
        // default to UTC so we never crash.
        tz.setLocalLocation(tz.getLocation('UTC'));
        log(
          "Warning: Invalid shop timezone '$shopTimeZone', falling back to UTC",
        );
      }

      // Android Initialization
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // iOS Initialization (Darwin)
      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsDarwin,
          );

      await _flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          log("Notification Tapped: ${details.payload}");
        },
      );

      _isInitialized = true;
      log("LocalNotificationService Initialized");
    } catch (e) {
      log("Error initializing LocalNotificationService: $e");
    }
  }

  Future<void> requestPermissions() async {
    try {
      // For iOS
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      // For Android 13+
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
    } catch (e) {
      log("Error requesting notification permissions: $e");
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    try {
      // Convert the UTC DateTime from Firestore into the shop's timezone.
      // tz.local is set to the shop's configured timezone during init().
      final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      );

      if (tzScheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        log("Skipping past notification (ID: $id, was for: $tzScheduledDate)");
        return;
      }

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'rental_alerts',
            'Rental Alerts',
            channelDescription: 'Notifications for rental due times',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      log(
        "Scheduled Notification ID: $id for $tzScheduledDate (TZ: ${tz.local.name})",
      );
    } catch (e) {
      log("Error scheduling notification: $e");
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id: id);
    log("Cancelled notification ID: $id");
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
    log("Cancelled all notifications");
  }
}
