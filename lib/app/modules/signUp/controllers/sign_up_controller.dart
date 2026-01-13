import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/exceptions/firebase_exceptions.dart';
import '../../../routes/app_pages.dart';
import '../../../services/auth_service.dart';
import '../../../services/user_service.dart';

class SignUpController extends GetxController {
  final ownerFormKey = GlobalKey<FormState>();
  final staffFormKey = GlobalKey<FormState>();
  final shopFormKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final phoneController = TextEditingController();

  final shopNameController = TextEditingController();
  final shopLocationController = TextEditingController();
  final shopContactController = TextEditingController();
  final shopCodeController = TextEditingController();

  final isLoading = false.obs;
  final role = 'staff'.obs;
  final currentStep = 0.obs;

  final isObscurePassword = true.obs;
  final isObscureConfirmPassword = true.obs;

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

  // ======================
  // REGISTER SHOP OWNER
  // ======================
  Future<void> registerShopOwner() async {
    if (!(ownerFormKey.currentState?.validate() ?? false)) return;
    if (!(shopFormKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;

      // Firebase Auth
      final credential = await _authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      // Create user profile, shop, and membership
      await _userService.registerAdminWithShop(
        uid: uid,
        shopName: shopNameController.text.trim(),
        shopLocation: shopLocationController.text.trim(),
        shopContactNumber: shopContactController.text.trim(),
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

  // ======================
  // REGISTER STAFF
  // ======================
  Future<void> registerShopStaff() async {
    if (!(staffFormKey.currentState?.validate() ?? false)) return;

    try {
      isLoading.value = true;

      // Firebase Auth
      final credential = await _authService.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      // Create user profile and membership
      await _userService.registerStaff(
        uid: uid,
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

  // ======================
  // ERROR HANDLING
  // ======================
  void _handleError(Object e) {
    if (kDebugMode) debugPrint(e.toString());

    final message = e is FirebaseAuthException
        ? AppFirebaseException(e).message
        : e.toString();

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
    shopNameController.dispose();
    shopLocationController.dispose();
    shopContactController.dispose();
    shopCodeController.dispose();
    super.onClose();
  }
}
