import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/common/a_app_error_handler.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../../utils/storage/app_storage.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';

class SignInController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isObscure = true.obs;

  final AuthService _authService = Get.find();
  final UserService _userService = Get.find();
  final _storage = AppLocalStorage();

  Future<void> signIn() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;

      /// FIREBASE AUTH
      await _authService.signIn(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      /// GET SHOP ID + ROLE
      final appUser = await _userService.getUser(_authService.currentUser!.uid);

      if (appUser == null) throw 'User not found';

      final role = appUser.role;
      final shopId = appUser.shopId;
      final isActive = appUser.isActive;
      final isVerified = appUser.isVerified;

      // SAVE SHOP ID LOCALLY
      await _storage.saveData('shop_id', shopId);

      /// Navigate
      if (!isActive) {
        Get.offAllNamed(Routes.AUTH_GATE, arguments: {'gate': 'not-active'});
        return;
      }

      if (!isVerified) {
        Get.offAllNamed(Routes.AUTH_GATE, arguments: {'gate': 'not-verified'});
        return;
      }
      if (role == UserRole.admin) {
        Get.offAllNamed(Routes.ADMIN_HOME, arguments: {'shopId': shopId});
        return;
      }
      if (role == UserRole.staff) {
        Get.offAllNamed(Routes.STAFF_HOME, arguments: {'shopId': shopId});
        return;
      }
    } catch (e) {
      AppErrorHandler.handleError(e);
    } finally {
      isLoading.value = false;
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
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
