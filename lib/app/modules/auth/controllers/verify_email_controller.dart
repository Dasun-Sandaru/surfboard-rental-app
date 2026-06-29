import 'dart:async';
import 'package:get/get.dart';
import '../../../../utils/common/a_app_error_handler.dart';
import '../../../../utils/common/a_app_snacks.dart';
import '../../../services/auth_service.dart';
import '../../../controllers/auth_controller.dart';

class VerifyEmailController extends GetxController {
  final AuthService _authService = Get.find();

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

  /// EMAIL VERIFICATION CHECKING
  void _startEmailVerificationCheck() {
    // Initial check
    checkEmailVerification();

    // Periodic check
    _verificationTimer = Timer.periodic(
      const Duration(seconds: _checkIntervalSeconds),
      (_) => checkEmailVerification(),
    );
  }

  /// CHECK EMAIL VERIFICATION
  Future<void> checkEmailVerification() async {
    try {
      isLoading.value = true;

      final verified = await _authService.isEmailVerified();
      isEmailVerified.value = verified;

      if (verified) {
        _verificationTimer?.cancel();

        // Delegate to AuthController to handle role-based navigation and load configuration
        final authController = Get.find<AuthController>();
        await authController.handleAuthChanged(_authService.currentUser);
      }
    } catch (e) {
      AppErrorHandler.handleError(e);
    } finally {
      isLoading.value = false;
    }
  }

  /// RESEND VERIFICATION EMAIL
  Future<void> resendVerificationEmail() async {
    if (!canResend) return;
    try {
      isLoading.value = true;
      await _authService.resendVerificationEmail();

      appSnackBarSuccessAndFailure('Verification email sent.');

      _startResendCooldown();
    } catch (e) {
      AppErrorHandler.handleError(e);
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

  /// GO TO LOGIN
  Future<void> goToLogin() async {
    try {
      await _authService.signOut();
      // AuthController will automatically route them to SIGN_IN
    } catch (e) {
      AppErrorHandler.handleError(e);
    }
  }

  @override
  void onClose() {
    _verificationTimer?.cancel();
    _resendCountdownTimer?.cancel();
    super.onClose();
  }
}
