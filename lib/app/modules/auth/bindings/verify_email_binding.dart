import 'package:get/get.dart';
import '../controllers/verify_email_controller.dart';
import '../../../services/auth_service.dart';

class VerifyEmailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.lazyPut<VerifyEmailController>(() => VerifyEmailController(), fenix: true);
  }
}
