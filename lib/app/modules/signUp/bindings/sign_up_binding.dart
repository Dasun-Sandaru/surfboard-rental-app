import 'package:get/get.dart';

import '../../../services/auth_service.dart';
import '../controllers/sign_up_controller.dart';

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    // Delete existing controller if any to prevent GlobalKey conflicts
    Get.delete<SignUpController>(force: true);

    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.put<SignUpController>(SignUpController());
  }
}
