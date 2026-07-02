import 'package:get/get.dart';

import '../controllers/shop_setup_controller.dart';

class ShopSetupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShopSetupController>(() => ShopSetupController());
  }
}
