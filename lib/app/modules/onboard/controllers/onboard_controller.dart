import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/storage/app_storage.dart';
import '../../../routes/app_pages.dart';

class OnboardController extends GetxController {
  final box = AppLocalStorage();
  final pageController = PageController();
  final currentPageIndex = 0.obs;

  // update current index when page scroll
  void updatePageIndicator(int index) => currentPageIndex.value = index;

  // jump to the specific dot selected page
  void dotNavigationClick(int index) {
    currentPageIndex.value = index;
    pageController.jumpToPage(index);
  }

  // update current index & jump to next page
  void nextPage() {
    if (currentPageIndex.value == 2) {
      saveOnboardingShown();
      Get.offAllNamed(Routes.SIGN_IN);
    } else {
      int page = currentPageIndex.value + 1;
      pageController.jumpToPage(page);
    }
  }

  // update current index & jump to the last page
  void skipPage() {
    currentPageIndex.value = 2;
    pageController.jumpToPage(2);
  }

  void saveOnboardingShown() async {
    await box.saveData('onboarding_shown', true);
  }
}
