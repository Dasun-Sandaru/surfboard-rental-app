import 'dart:async';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../routes/app_pages.dart';

class VerifyEmailController extends GetxController {
  final AuthService _authService = Get.find();

  RxBool isLoading = false.obs;
  RxBool isEmailVerified = false.obs;

  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    checkEmailVerification();
    // Check every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      checkEmailVerification();
    });
  }

  Future<void> checkEmailVerification() async {
    isLoading.value = true;
    try {
      isEmailVerified.value = await _authService.isEmailVerified();
      if (isEmailVerified.value) {
        Get.offAllNamed(Routes.HOME);
      }
      print('Email verification status w: $isEmailVerified');
    } catch (e) {
      print('Error checking email verification: $e');
    } finally {
      // print('Email verification check completed');
      isLoading.value = false;
    }
  }

  Future<void> resendVerificationEmail() async {
    try {
      await _authService.sendEmailVerification();
      Get.snackbar('Success', 'Verification email sent');
    } catch (e) {
      Get.snackbar('Error', 'Failed to send verification email');
    }
  }

  void goToLogin() {
    _authService.signOut();
    Get.offAllNamed(Routes.SIGN_IN);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
