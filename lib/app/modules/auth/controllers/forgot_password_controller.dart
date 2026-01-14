import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/common/a_app_error_handler.dart';
import '../../../../utils/common/a_app_snacks.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final isSuccess = false.obs;

  final AuthService _authService = Get.find();
  final UserService _userService = Get.find();

  /// RESET PASSWORD
  Future<void> resetPassword() async {
    try {
      if (!(formKey.currentState?.validate() ?? false)) return;

      isLoading.value = true;
      final email = emailController.text.trim();

      // Check Email User Exists
      final userExists = await _userService.userExistsByEmail(email);
      if (!userExists) {
        appSnackBarSuccessAndFailure(
          'User with this email does not exist.',
          isSuccess: false,
        );
        return;
      }

      // Send Password Reset Email
      await _authService.sendPasswordResetEmail(email);

      isSuccess.value = true;

      // Show Success Snackbar
      appSnackBarSuccessAndFailure('Password reset email sent to $email.');
    } on FirebaseAuthException catch (e) {
      AppErrorHandler.handleError(e);
    } catch (e) {
      AppErrorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate Back To Login
  void goToLogin() {
    Get.back();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
