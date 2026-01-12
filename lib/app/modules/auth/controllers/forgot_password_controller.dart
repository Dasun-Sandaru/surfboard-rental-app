import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/exceptions/firebase_exceptions.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final isLoading = false.obs;
  final isSuccess = false.obs; // track if reset email was sent

  final AuthService _authService = Get.find();
  final UserService _userService = Get.find();

  /// Send password reset email
  Future<void> resetPassword() async {
    try {
      // Validate email
      if (!(formKey.currentState?.validate() ?? false)) return;

      isLoading.value = true;
      final email = emailController.text.trim();

      // Check Email User exists
      final userExists = await _userService.userExistsByEmail(email);
      if (!userExists) {
        Get.snackbar(
          'Error',
          'User with this email does not exist.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          colorText: Colors.red,
        );
        return;
      }

      // Send reset email
      await _authService.sendPasswordResetEmail(email);

      isSuccess.value = true;

      // Show success snackbar
      Get.snackbar(
        'Success',
        'Password reset email sent to $email. Check your inbox.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green,
        duration: const Duration(seconds: 4),
      );
    } on FirebaseAuthException catch (e) {
      final errorMessage = AppFirebaseException(e).message;
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigate back to Login screen
  void goToLogin() {
    // Get.offAllNamed(Routes.SIGN_IN);
    Get.back();
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
