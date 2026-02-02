import 'package:get/get.dart';

import '../controllers/damages_pending_controller.dart';

class DamagesPendingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DamagesPendingController>(() => DamagesPendingController());
  }
}
