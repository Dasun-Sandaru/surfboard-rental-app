import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';
import '../../../services/shop_service.dart';
import '../../../services/user_service.dart';

class SignInController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isObscure = true.obs;

  final AuthService _authService = Get.find();
  final UserService _userService = Get.find();

  Future<void> signIn() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;

      /// 1️⃣ Firebase Auth
      await _authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      /// 2️⃣ Email verification
      // if (!await _authService.isEmailVerified()) {
      //   await _authService.signOut();
      //   throw 'Email not verified';
      // }

      /// 3️⃣ User active check
      // if (!await _userService.isUserActive(_authService.currentUser!.uid)) {
      //   await _authService.signOut();
      //   throw 'User account disabled';
      // }

      /// 4️⃣ Get shop + role
      final appUser = await _userService.getUser(_authService.currentUser!.uid);

      if (appUser == null) throw 'User not found';

      final role = appUser.role;
      final shopId = appUser.shopId;
      final isActive = appUser.isActive;
      final isVerified = appUser.isVerified;

      /// 5️⃣ Navigate
      if (!isActive) {
        Get.offAllNamed(Routes.AUTH_GATE, arguments: {'gate': 'not-active'});
        return;
      }

      if (!isVerified) {
        Get.offAllNamed(Routes.AUTH_GATE, arguments: {'gate': 'not-verified'});
        return;
      }
      if (role == 'admin') {
        Get.offAllNamed(Routes.ADMIN_HOME, arguments: {'shopId': shopId});
        return;
      }
      if (role == 'staff') {
        Get.offAllNamed(Routes.STAFF_HOME, arguments: {'shopId': shopId});
        return;
      }
    } catch (e) {
      log(e.toString());
      Get.snackbar(
        'Login failed',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToForgotPassword() {
    Get.toNamed(Routes.FORGOT_PASSWORD);
  }

  void goToSignUpStaff() {
    Get.toNamed(Routes.SIGN_UP, arguments: {'role': 'staff'});
  }

  void goToSignUpAdmin() {
    Get.toNamed(Routes.SIGN_UP, arguments: {'role': 'admin'});
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
