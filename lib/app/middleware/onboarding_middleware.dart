import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/storage/app_storage.dart';
import '../routes/app_pages.dart';

class OnboardingMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (route == Routes.ONBOARD) {
      return null;
    }

    final storage = AppLocalStorage();
    // Assuming 'onboarding_shown' is set to true when user completes onboarding
    final hasSeenOnboarding =
        storage.readData<bool>('onboarding_shown') ?? false;

    if (!hasSeenOnboarding) {
      return const RouteSettings(name: Routes.ONBOARD);
    }

    return null;
  }
}
