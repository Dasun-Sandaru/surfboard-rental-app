import 'package:get/get.dart';

import '../controllers/damage_fee_controller.dart';

class DamageFeeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DamageFeeController>(
      () => DamageFeeController(),
    );
  }
}
