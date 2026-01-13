import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/storage/app_storage.dart';
import '../../../routes/app_pages.dart';

class OnboardController extends GetxController {
  final box = AppLocalStorage();
  final pageController = PageController();
  final currentPageIndex = 0.obs;

  /// UPDATE PAGE INDICATOR
  void updatePageIndicator(int index) => currentPageIndex.value = index;

  /// JUMP SPECIFIC PAGE
  void dotNavigationClick(int index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  /// UPDATE TO NEXT PAGE OR NAVIGATE TO SIGN IN
  void nextPage() {
    if (currentPageIndex.value == 2) {
      saveOnboardingShown();
      Get.offAllNamed(Routes.SIGN_IN);
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  /// SKIP TO LAST PAGE
  void skipPage() {
    currentPageIndex.value = 2;
    pageController.jumpToPage(2);
  }

  /// SAVE ONBOARDING SHOWN FLAG
  void saveOnboardingShown() async {
    await box.saveData('onboarding_shown', true);
  }
}
