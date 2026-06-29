import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../services/local_notification_service.dart';

class ScheduledNotificationsController extends GetxController {
  final LocalNotificationService _notificationService =
      LocalNotificationService();

  final pendingNotifications = <PendingNotificationRequest>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPendingNotifications();
  }

  Future<void> fetchPendingNotifications() async {
    isLoading.value = true;
    try {
      final notifications = await _notificationService
          .getPendingNotifications();
      log("Notifications : ${notifications.length}");
      pendingNotifications.assignAll(notifications);
    } catch (e) {
      Get.snackbar('error'.tr, 'failed_to_fetch_notifications'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  DateTime? getScheduledTimeForNotification(int id) {
    final timeStr = GetStorage().read('notif_time_$id');
    if (timeStr != null) {
      final parsed = DateTime.tryParse(timeStr);
      return parsed?.toLocal();
    }
    return null;
  }

  Future<void> cancelNotification(int id) async {
    await _notificationService.cancelNotification(id);
    fetchPendingNotifications();
    Get.snackbar('success'.tr, '${'notification_cancelled'.tr} $id');
  }

  Future<void> cancelAllNotifications() async {
    await _notificationService.cancelAllNotifications();
    fetchPendingNotifications();
    Get.snackbar('success'.tr, 'all_notifications_cancelled'.tr);
  }
}
