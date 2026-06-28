import 'dart:developer';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'config_service.dart';

class LocalNotificationService {
  static final LocalNotificationService _instance =
      LocalNotificationService._internal();
  factory LocalNotificationService() => _instance;
  LocalNotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;
  bool _timezonesInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone database once
      if (!_timezonesInitialized) {
        tz.initializeTimeZones();
        _timezonesInitialized = true;
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

      await flutterLocalNotificationsPlugin.initialize(
        settings: initializationSettings,
        onDidReceiveNotificationResponse: (details) {
          log("Notification Tapped: ${details.payload}", name: 'LocalNotification');
          final payload = details.payload;
          if (payload != null && payload.startsWith('rental:')) {
            final rentalId = payload.substring('rental:'.length);
            log("Navigating to rental detail: $rentalId", name: 'LocalNotification');
            Get.toNamed('/rental-detail', arguments: rentalId);
          }
        },
      );

      _isInitialized = true;
      log("LocalNotificationService Initialized");
    } catch (e) {
      log("Error initializing LocalNotificationService: $e");
    }
  }

  /// Resolves the shop timezone at call-time (not init-time) to avoid race conditions
  tz.Location _resolveShopTimezone() {
    try {
      final configService = Get.find<ConfigService>();
      final shopTimeZone = configService.timeZone.value;
      final location = tz.getLocation(shopTimeZone);
      log("Resolved shop timezone: $shopTimeZone", name: 'LocalNotification');
      return location;
    } catch (e) {
      log("Warning: Could not resolve shop timezone, falling back to UTC: $e",
          name: 'LocalNotification');
      return tz.getLocation('UTC');
    }
  }

  Future<void> requestPermissions() async {
    try {
      // For iOS
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      // For Android 13+ (POST_NOTIFICATIONS)
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();

        // For Android 12+ (SCHEDULE_EXACT_ALARM)
        final exactAlarmGranted =
            await androidPlugin.requestExactAlarmsPermission();
        log(
          "Exact alarm permission granted: $exactAlarmGranted",
          name: 'LocalNotification',
        );
      }
    } catch (e) {
      log("Error requesting notification permissions: $e",
          name: 'LocalNotification');
    }
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    try {
      // Resolve timezone at schedule-time to avoid init race condition
      final shopLocation = _resolveShopTimezone();

      // Always convert to UTC first, then to shop timezone
      final utcDate = scheduledDate.toUtc();
      final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(
        utcDate,
        shopLocation,
      );
      final tzNow = tz.TZDateTime.now(shopLocation);

      log(
        "DEBUG: Input=$scheduledDate (isUtc=${scheduledDate.isUtc})",
        name: 'LocalNotification',
      );
      log(
        "DEBUG: UTC=$utcDate",
        name: 'LocalNotification',
      );
      log(
        "DEBUG: TZ scheduled=$tzScheduledDate (zone=${shopLocation.name})",
        name: 'LocalNotification',
      );
      log(
        "DEBUG: TZ now=$tzNow",
        name: 'LocalNotification',
      );

      if (tzScheduledDate.isBefore(tzNow)) {
        log("Skipping past notification (ID: $id, was for: $tzScheduledDate)");
        return;
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: tzScheduledDate,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            'rental_alerts',
            'Rental Alerts',
            channelDescription: 'Notifications for rental due times',
            importance: Importance.max,
            priority: Priority.high,
            styleInformation: BigTextStyleInformation(
              body,
              contentTitle: title,
              summaryText: 'Rental Alert',
            ),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: payload ?? tzScheduledDate.toIso8601String(),
      );
      
      // Save scheduled time for the UI to display
      final storage = GetStorage();
      storage.write('notif_time_$id', scheduledDate.toIso8601String());

      log(
        "SUCCESS: Scheduled ID=$id for $tzScheduledDate (${shopLocation.name})",
        name: 'LocalNotification',
      );
    } catch (e) {
      log("Error scheduling notification: $e", name: 'LocalNotification');
    }
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id: id);
    GetStorage().remove('notif_time_$id');
    log("Cancelled notification ID: $id");
  }

  Future<void> cancelAllNotifications() async {
    final pending = await getPendingNotifications();
    for (var req in pending) {
      GetStorage().remove('notif_time_${req.id}');
    }
    await flutterLocalNotificationsPlugin.cancelAll();
    log("Cancelled all notifications");
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    } catch (e) {
      log("Error fetching pending notifications: $e");
      return [];
    }
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      await flutterLocalNotificationsPlugin.show(
        id: id,
        title: title,
        body: body,
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
      );
      log("Immediate notification sent successfully", name: 'LocalNotification');
    } catch (e) {
      log("Error sending immediate notification: $e", name: 'LocalNotification');
    }
  }

  Future<bool> canScheduleExactAlarms() async {
    try {
      final androidPlugin = flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        return await androidPlugin.canScheduleExactNotifications() ?? false;
      }
    } catch (e) {
      log("Error checking exact alarm permission: $e", name: 'LocalNotification');
    }
    return false;
  }
}
