import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/exceptions/firebase_exceptions.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final isLoading = false.obs;

  final AuthService _authService = Get.find();

  /// Send password reset email to user
  Future<void> resetPassword() async {
    try {
      // validate email field
      if (!(formKey.currentState?.validate() ?? false)) {
        return;
      }

      isLoading.value = true;
      final email = emailController.text.trim();

      // check if user exists
      final userExists = await _authService.userExistsByEmail(email);
      if (!userExists) {
        Get.snackbar(
          'Email Not Found',
          'No account exists with this email address.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange,
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // send password reset email
      await _authService.sendPasswordResetEmail(email);

      // show success message
      Get.snackbar(
        'Success',
        'Password reset email sent to $email. Check your inbox.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        duration: const Duration(seconds: 4),
      );

      // navigate back to login after success
      Future.delayed(
        const Duration(seconds: 2),
        () => Get.offAllNamed(Routes.SIGN_IN),
      );
    } on FirebaseAuthException catch (e) {
      final errorMessage = AppFirebaseException(e).message;
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
