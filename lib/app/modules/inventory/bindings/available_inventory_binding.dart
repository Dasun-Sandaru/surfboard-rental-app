import 'package:get/get.dart';

import '../controllers/available_inventory_controller.dart';

class AvailableInventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AvailableInventoryController>(
      () => AvailableInventoryController(),
    );
  }
}
