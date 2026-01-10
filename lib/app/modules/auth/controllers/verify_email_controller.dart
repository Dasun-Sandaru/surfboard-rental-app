import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_pages.dart';
import '../../../services/user_service.dart';

class VerifyEmailController extends GetxController {
  final AuthService _authService = Get.find();
  final UserService _userService = Get.find();

  final isLoading = false.obs;
  final isEmailVerified = false.obs;
  final resendCountdown = 0.obs;

  Timer? _resendCountdownTimer;

  static const int _resendCooldownSeconds = 60;
  static const int _checkIntervalSeconds = 5;

  Timer? _verificationTimer;

  @override
  void onInit() {
    super.onInit();
    _startEmailVerificationCheck();
  }

  /// ======================
  /// Email verification check
  /// ======================
  void _startEmailVerificationCheck() {
    // Initial check
    checkEmailVerification();

    // Periodic check
    _verificationTimer = Timer.periodic(
      const Duration(seconds: _checkIntervalSeconds),
      (_) => checkEmailVerification(),
    );
  }

  Future<void> checkEmailVerification() async {
    try {
      isLoading.value = true;

      final verified = await _authService.isEmailVerified();
      isEmailVerified.value = verified;

      if (verified) {
        _verificationTimer?.cancel();

        // Navigate to role-based home
        final user = _authService.currentUser;
        if (user != null) {
          final role = await _userService.getUserRole();
          if (role == 'admin') {
            Get.offAllNamed(Routes.ADMIN_HOME);
          } else if (role == 'staff') {
            Get.offAllNamed(Routes.STAFF_HOME);
          } else {
            await _authService.signOut();
            Get.offAllNamed(Routes.SIGN_IN);
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking email verification: $e');
      Get.snackbar(
        'Error',
        'Failed to check email verification status',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// ======================
  /// Resend verification email
  /// ======================
  Future<void> resendVerificationEmail() async {
    if (!canResend) return;

    try {
      isLoading.value = true;
      await _authService.resendVerificationEmail();

      Get.snackbar(
        'Success',
        'Verification email sent. Please check your inbox.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );

      _startResendCooldown();
    } catch (e) {
      debugPrint('Error resending verification email: $e');
      Get.snackbar(
        'Error',
        'Failed to send verification email',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _startResendCooldown() {
    resendCountdown.value = _resendCooldownSeconds;
    _resendCountdownTimer?.cancel();
    _resendCountdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (resendCountdown.value > 0) {
        resendCountdown.value--;
      } else {
        _resendCountdownTimer?.cancel();
      }
    });
  }

  bool get canResend => resendCountdown.value == 0;

  String get resendButtonText => canResend
      ? 'Resend Verification Email'
      : 'Resend in ${resendCountdown.value}s';

  /// ======================
  /// Go back to login
  /// ======================
  Future<void> goToLogin() async {
    try {
      await _authService.signOut();
      Get.offAllNamed(Routes.SIGN_IN);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  @override
  void onClose() {
    _verificationTimer?.cancel();
    _resendCountdownTimer?.cancel();
    super.onClose();
  }
}
