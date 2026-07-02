import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants/a_enums.dart';
import '../controllers/auth_controller.dart';
import '../services/config_service.dart';
import '../routes/app_pages.dart';

class AccessControlMiddleware extends GetMiddleware {
  final String routeKey;

  /// Routes that guests (unauthenticated users) are allowed to access.
  /// e.g. QR Scanner is used during Sign Up to scan shop codes.
  static const List<String> _guestAllowedRoutes = ['qr_scanner'];

  AccessControlMiddleware({required this.routeKey});

  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();

      // 1. Guest Check — only allow specific routes for unauthenticated users
      if (authController.firebaseUser.value == null) {
        if (_guestAllowedRoutes.contains(routeKey)) {
          return null; // Allow guest access for whitelisted routes
        }
        return const RouteSettings(name: Routes.SIGN_IN);
      }

      // 2. Admin Bypass — admins have full access
      if (authController.currentUserRole.value == UserRole.admin) {
        return null;
      }

      // 3. Staff Access — check dynamic config rules
      if (Get.isRegistered<ConfigService>()) {
        final configService = Get.find<ConfigService>();
        final accessRules = configService.staffAccessRules;

        // If rule exists and is FALSE, block access
        if (accessRules.containsKey(routeKey) &&
            accessRules[routeKey] == false) {
          return const RouteSettings(name: Routes.STAFF_HOME);
        }
      }

      return null; // Access granted
    } catch (e) {
      // Fail-closed: redirect to sign-in on error
      return const RouteSettings(name: Routes.SIGN_IN);
    }
  }
}
