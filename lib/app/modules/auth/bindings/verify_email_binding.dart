import 'package:get/get.dart';
import '../controllers/verify_email_controller.dart';
import '../../../services/auth_service.dart';

class VerifyEmailBinding extends Bindings {
  @override
  void dependencies() {
    // Delete existing controller if any to prevent conflicts
    Get.delete<VerifyEmailController>(force: true);

    Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
    Get.put<VerifyEmailController>(VerifyEmailController());
  }
}
