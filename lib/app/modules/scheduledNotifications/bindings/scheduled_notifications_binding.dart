import 'package:get/get.dart';
import '../controllers/scheduled_notifications_controller.dart';

class ScheduledNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScheduledNotificationsController>(
      () => ScheduledNotificationsController(),
    );
  }
}
