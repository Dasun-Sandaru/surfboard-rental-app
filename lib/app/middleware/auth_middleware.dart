import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../routes/app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    // If the user tries to access the auth routes, let it be
    if (route == Routes.SIGN_IN ||
        route == Routes.SIGN_UP ||
        route == Routes.SPLASH ||
        route == Routes.FORGOT_PASSWORD) {
      return null;
    }

    // Access AuthController safely
    // Assuming AuthController is registered at startup (e.g. InitialBinding)
    try {
      final authController = Get.find<AuthController>();
      if (authController.firebaseUser.value == null) {
        return const RouteSettings(name: Routes.SIGN_IN);
      }
    } catch (_) {
      // If AuthController is not found, default to Sign In
      return const RouteSettings(name: Routes.SIGN_IN);
    }

    return null;
  }
}
