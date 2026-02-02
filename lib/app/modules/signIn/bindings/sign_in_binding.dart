import 'package:get/get.dart';

import '../../../services/auth_service.dart';
import '../controllers/sign_in_controller.dart';

class SignInBinding extends Bindings {
  @override
  void dependencies() {
    // Delete existing controller if any to prevent disposed controller issues
    Get.delete<SignInController>(force: true);

    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.put<SignInController>(SignInController());
  }
}
