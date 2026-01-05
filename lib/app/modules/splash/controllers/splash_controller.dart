import 'dart:async';

import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';

import '../../../../utils/logging/app_logger.dart';
import '../../../../utils/storage/app_storage.dart';
import '../../../controllers/user_controller.dart';
import '../../../models/user_model.dart' as MyUser;
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  final box = AppLocalStorage();
  final updateStatus = 'init'.obs;
  bool _navigated = false;

  @override
  void onInit() {
    super.onInit();
    checkAppUpdate();
  }

  Future<void> checkAppUpdate() async {
    try {
      updateStatus.value = 'Checking for app updates...';

      final updateInfo = await InAppUpdate.checkForUpdate();

      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        AppLogger.info('Update available');
        updateStatus.value = 'Update available! Preparing to update...';

        if (updateInfo.immediateUpdateAllowed) {
          updateStatus.value = 'Performing immediate update...';
          final result = await InAppUpdate.performImmediateUpdate();

          if (result == AppUpdateResult.success) {
            AppLogger.info('App updated successfully (Immediate)');
            updateStatus.value = 'App updated successfully!';
          }
        } else if (updateInfo.flexibleUpdateAllowed) {
          updateStatus.value = 'Downloading flexible update...';
          final result = await InAppUpdate.startFlexibleUpdate();

          if (result == AppUpdateResult.success) {
            updateStatus.value = 'Finalizing update...';
            await InAppUpdate.completeFlexibleUpdate();
            AppLogger.info('App updated successfully (Flexible)');
            updateStatus.value = 'App updated successfully!';
          }
        } else {
          AppLogger.info('Update available but not allowed');
          updateStatus.value = 'Update available but not allowed.';
        }
      } else {
        AppLogger.info('No update available');
        updateStatus.value = 'No updates found. Launching app...';
      }
    } catch (e) {
      AppLogger.error('Error checking for update: $e');
      updateStatus.value = 'Something went wrong. Launching app...';
    } finally {
      navigateToNextScreen();
    }
  }

  void navigateToNextScreen() {
    final isOnboardingShown = box.readData('onboarding_shown') ?? false;

    if (!isOnboardingShown) {
      Get.offNamed(Routes.ONBOARD);
      return;
    }

    final userController = Get.find<UserController>();
    ever(userController.userModel, (MyUser.UserModel? userModel) {
      if (!_navigated) {
        _navigated = true;
        if (userModel != null) {
          if (userModel.role == 'Admin') {
            Get.offNamed(Routes.ADMIN_HOME);
          } else {
            Get.offNamed(Routes.STAFF_HOME);
          }
        } else {
          Get.offNamed(Routes.SIGN_IN);
        }
      }
    });

    // Add a timeout in case userModel never gets a value.
    // For example, if there is no internet connection.
    Future.delayed(const Duration(seconds: 3), () {
      if (!_navigated) {
        _navigated = true;
        // Default navigation if userModel is not resolved.
        Get.offNamed(Routes.SIGN_IN);
      }
    });
  }
}
