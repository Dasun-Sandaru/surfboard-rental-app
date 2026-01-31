import 'package:get/get.dart';

import '../../alerts/controllers/alerts_controller.dart';
import '../controllers/staff_home_controller.dart';

class StaffHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StaffHomeController>(() => StaffHomeController());
    Get.lazyPut<AlertsController>(() => AlertsController());
  }
}
