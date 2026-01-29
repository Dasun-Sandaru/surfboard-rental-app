import 'package:get/get.dart';

import '../../alerts/controllers/alerts_controller.dart';
import '../controllers/admin_home_controller.dart';

class AdminHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AdminHomeController());
    Get.lazyPut<AlertsController>(() => AlertsController());
  }
}
