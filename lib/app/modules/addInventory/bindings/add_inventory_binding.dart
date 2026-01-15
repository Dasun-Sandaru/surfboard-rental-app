import 'package:get/get.dart';

import '../controllers/add_inventory_controller.dart';

class AddInventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddInventoryController>(
      () => AddInventoryController(),
    );
  }
}
