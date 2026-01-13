import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';

import '../../../../utils/logging/app_logger.dart';
import '../../../../utils/storage/app_storage.dart';
import '../../../controllers/auth_controller.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  final _storage = AppLocalStorage();
  final updateStatus = 'init'.obs;

  @override
  void onInit() {
    super.onInit();
    _startApp();
  }

  Future<void> _startApp() async {
    await checkAppUpdate();
    _handleOnboarding();
  }

  /// ======================
  /// APP UPDATE
  /// ======================
  Future<void> checkAppUpdate() async {
    try {
      updateStatus.value = 'Checking for updates...';

      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        AppLogger.info('Update available');

        if (updateInfo.immediateUpdateAllowed) {
          await InAppUpdate.performImmediateUpdate();
        } else if (updateInfo.flexibleUpdateAllowed) {
          await InAppUpdate.startFlexibleUpdate();
          await InAppUpdate.completeFlexibleUpdate();
        }
      }
    } catch (e) {
      AppLogger.error('Update check failed: $e');
    }
  }

  /// ======================
  /// ONBOARDING
  /// ======================
  void _handleOnboarding() {
    final isOnboardingShown = _storage.readData('onboarding_shown') ?? false;

    if (!isOnboardingShown) {
      Get.offAllNamed(Routes.ONBOARD);
      return;
    }

    /// AuthController will take over from here
    Future.delayed(const Duration(seconds: 2), () {
      // Get.offAllNamed(Routes.AUTH_GATE);
      Get.put(AuthController(), permanent: true);
    });
  }
}
