import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());
  }
}
