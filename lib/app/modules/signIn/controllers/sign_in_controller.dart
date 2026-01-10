import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/exceptions/firebase_exceptions.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';

class SignInController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final emailController1 = TextEditingController();
  final passwordController = TextEditingController();

  final isObscure = true.obs;
  final isLoading = false.obs;

  final AuthService _authService = Get.find();
  final UserService _userService = Get.find();

  /// ======================
  /// SIGN IN
  /// ======================
  Future<void> signIn() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;

      await _authService.signIn(
        email: emailController1.text.trim(),
        password: passwordController.text.trim(),
      );

      /// Refresh verification state
      final isVerified = await _authService.isEmailVerified();

      if (!isVerified) {
        await _authService.signOut();

        Get.snackbar(
          'Email not verified',
          'Please verify your email before signing in.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
        return;
      }

      /// Fetch user role
      final role = await _userService.getUserRole();

      if (role == 'admin') {
        Get.offAllNamed(Routes.ADMIN_HOME);
      } else if (role == 'staff') {
        Get.offAllNamed(Routes.STAFF_HOME);
      } else {
        await _authService.signOut();
        Get.snackbar(
          'Access denied',
          'User role not assigned. Contact support.',
        );
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar(
        'Login failed',
        AppFirebaseException(e).message,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e, stack) {
      if (kDebugMode) {
        debugPrint(e.toString());
        debugPrint(stack.toString());
      }

      Get.snackbar(
        'Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ======================
  /// NAVIGATION
  /// ======================
  void goToForgotPassword() => Get.toNamed(Routes.FORGOT_PASSWORD);

  void goToSignUpStaff() =>
      Get.toNamed(Routes.SIGN_UP, arguments: {'role': 'staff'});

  void goToSignUpAdmin() =>
      Get.toNamed(Routes.SIGN_UP, arguments: {'role': 'admin'});

  @override
  void onClose() {
    emailController1.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
