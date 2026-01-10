import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/exceptions/firebase_exceptions.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';

class SignUpController extends GetxController {
  final GlobalKey<FormState> staffFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> shopFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> ownerFormKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();
  final shopCodeController = TextEditingController();

  final shopNameController = TextEditingController();
  final shopLocationController = TextEditingController();
  final shopContactController = TextEditingController();

  final isLoading = false.obs;
  final currentStep = 0.obs;
  final role = 'staff'.obs;

  RxBool isObscurePassword = true.obs;
  RxBool isObscureConfirmPassword = true.obs;

  final AuthService _authService = Get.find();
  final UserService _userService = Get.find();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['role'] != null) {
      role.value = args['role'];
    }
  }

  /// ======================
  /// REGISTER ADMIN
  /// ======================
  Future<void> registerShopOwner() async {
    if (!(ownerFormKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;

      final credential = await _authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final user = credential.user!;
      await _userService.createShopWithOwner(
        userId: user.uid,
        shopName: shopNameController.text.trim(),
        location: shopLocationController.text.trim(),
        contactNumber: shopContactController.text.trim(),
        ownerName: nameController.text.trim(),
        ownerEmail: emailController.text.trim(),
        phone: phoneController.text.trim(),
      );

      Get.offAllNamed(Routes.VERIFY_EMAIL);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// ======================
  /// REGISTER STAFF
  /// ======================
  Future<void> registerShopStaff() async {
    if (!(staffFormKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;

      final credential = await _authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await _userService.createStaffUser(
        userId: credential.user!.uid,
        shopId: shopCodeController.text.trim(),
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
      );

      Get.offAllNamed(Routes.VERIFY_EMAIL);
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  void _handleError(Object e) {
    if (kDebugMode) {
      debugPrint(e.toString());
    }

    final message = e is FirebaseAuthException
        ? AppFirebaseException(e).message
        : 'Something went wrong';

    Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();
    shopCodeController.dispose();
    shopNameController.dispose();
    shopLocationController.dispose();
    shopContactController.dispose();
    super.onClose();
  }
}
