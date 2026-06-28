import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/constants/a_enums.dart';
import '../controllers/auth_controller.dart';
import '../services/config_service.dart';
import '../routes/app_pages.dart';

class AccessControlMiddleware extends GetMiddleware {
  final String routeKey;

  AccessControlMiddleware({required this.routeKey});

  @override
  RouteSettings? redirect(String? route) {
    try {
      // 1. Check User Role
      // Admins usually bypass this, but let's check dynamic rules primarily for staff.
      // If you want strict rules even for admins, remove this check.
      // Assuming this middleware is mainly for limiting STAFF access.
      final authController = Get.find<AuthController>();
      if (authController.firebaseUser.value == null) {
        return null; // Guests allowed (e.g. scanning shop code on Sign Up)
      }
      if (authController.currentUserRole.value == UserRole.admin) {
        return null; // Admins allowed everywhere
      }

      // 2. Check Dynamic Config Rule
      if (Get.isRegistered<ConfigService>()) {
        final configService = Get.find<ConfigService>();
        final accessRules = configService.staffAccessRules;

        // If rule exists and is FALSE, block access
        if (accessRules.containsKey(routeKey) &&
            accessRules[routeKey] == false) {
          // Block access
          return const RouteSettings(name: Routes.STAFF_HOME);
        }
      }

      return null; // Access granted
    } catch (e) {
      // Fallback
      return null;
    }
  }
}
