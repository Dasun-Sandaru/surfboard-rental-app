import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../controllers/auth_gate_controller.dart';

class AuthGateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthGateController>(
      () => AuthGateController(),
    );
    // Get.put(AuthController(), permanent: true);
  }
}
