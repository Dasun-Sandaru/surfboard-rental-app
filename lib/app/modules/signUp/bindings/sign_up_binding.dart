import 'package:get/get.dart';

import '../../../services/auth_service.dart';
import '../controllers/sign_up_controller.dart';
class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<SignUpController>(() => SignUpController());
  }
}
