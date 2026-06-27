import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../models/notification_trigger_model.dart';
import 'local_notification_service.dart';
import 'user_service.dart';

class NotificationSyncService extends GetxService {
  final LocalNotificationService _localNotificationService =
      LocalNotificationService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = Get.find<UserService>();

  StreamSubscription<QuerySnapshot>? _triggerSubscription;

  @override
  void onInit() {
    super.onInit();
    _initLocalNotification();
  }

  Future<void> _initLocalNotification() async {
    await _localNotificationService.init();
    await _localNotificationService.requestPermissions();
  }

  void startSync() async {
    final shopId = await _userService.getShopIdFromStorage();
    if (shopId == null) {
      log("NotificationSyncService: shopId is null, cannot sync.");
      return;
    }

    // Cancel existing local notifications to avoid duplicates when re-syncing
    await _localNotificationService.cancelAllNotifications();

    // Listen to pending triggers for this shop
    _triggerSubscription?.cancel();
    _triggerSubscription = _firestore
        .collection('shops')
        .doc(shopId)
        .collection('notification_triggers')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      _processTriggers(snapshot.docs);
    }, onError: (e) {
      log("Error syncing notification triggers: $e");
    });
  }

  void _processTriggers(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) async {
    await _localNotificationService.cancelAllNotifications();
    
    for (var doc in docs) {
      try {
        final trigger = NotificationTriggerModel.fromSnapshot(doc);
        _scheduleForTrigger(trigger);
      } catch (e) {
        log("Error processing trigger document ${doc.id}: $e");
      }
    }
  }

  void _scheduleForTrigger(NotificationTriggerModel trigger) {
    final now = DateTime.now();

    // Calculate IDs (stable based on rentalId)
    // Warning 5 mins before
    final int warningId = trigger.rentalId.hashCode;
    // Exact due time
    final int exactId = trigger.rentalId.hashCode ^ 1;

    // Schedule exact due time notification
    if (trigger.expectedReturnTime.isAfter(now)) {
      _localNotificationService.scheduleNotification(
        id: exactId,
        title: "Overdue Rental",
        body: trigger.body.isNotEmpty ? trigger.body : "Rental ${trigger.rentalId} is now overdue!",
        scheduledDate: trigger.expectedReturnTime,
      );
    }

    // Schedule 5 min warning notification
    final warningTime =
        trigger.expectedReturnTime.subtract(const Duration(minutes: 5));
    if (warningTime.isAfter(now)) {
      _localNotificationService.scheduleNotification(
        id: warningId,
        title: "Upcoming Return",
        body: trigger.title.isNotEmpty
            ? trigger.title
            : "Rental ${trigger.rentalId} is due in 5 minutes.",
        scheduledDate: warningTime,
      );
    }
  }

  void stopSync() {
    _triggerSubscription?.cancel();
    _localNotificationService.cancelAllNotifications();
  }

  @override
  void onClose() {
    _triggerSubscription?.cancel();
    super.onClose();
  }
}
