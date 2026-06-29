import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/common/a_app_error_handler.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';

class SignInController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final signInEmailController = TextEditingController();
  final signInPasswordController = TextEditingController();

  final isLoading = false.obs;
  final isObscure = true.obs;

  final AuthService _authService = Get.find();

  Future<void> signIn() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;

      /// FIREBASE AUTH
      await _authService.signIn(
        email: signInEmailController.text.trim(),
        password: signInPasswordController.text.trim(),
      );

      // We do not perform manual routing here.
      // AuthController centrally listens to Firebase auth state changes and routes correctly,
      // avoiding duplicate navigation and race conditions.
    } catch (e) {
      isLoading.value = false;
      AppErrorHandler.handleError(e);
    }
  }

  /// NAVIGATE TO FORGOT PASSWORD
  void goToForgotPassword() {
    Get.toNamed(Routes.FORGOT_PASSWORD);
  }

  /// NAVIGATE TO SIGN UP STAFF
  void goToSignUpStaff() {
    Get.toNamed(Routes.SIGN_UP, arguments: {'role': UserRole.staff});
  }

  /// NAVIGATE TO SIGN UP ADMIN
  void goToSignUpAdmin() {
    Get.toNamed(Routes.SIGN_UP, arguments: {'role': UserRole.admin});
  }

  @override
  void onClose() {
    signInEmailController.dispose();
    signInPasswordController.dispose();
    super.onClose();
  }
}
