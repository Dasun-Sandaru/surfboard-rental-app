import 'package:get/get.dart';

import '../../../services/auth_service.dart';
import '../controllers/sign_in_controller.dart';

class SignInBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<SignInController>(() => SignInController(), fenix: true);
  }
}
