import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constants/a_enums.dart';
import '../controllers/auth_controller.dart';
import '../routes/app_pages.dart';

class RoleMiddleware extends GetMiddleware {
  final List<UserRole> allowedRoles;

  RoleMiddleware({required this.allowedRoles});

  @override
  RouteSettings? redirect(String? route) {
    try {
      final authController = Get.find<AuthController>();
      final currentUserRole = authController.currentUserRole.value;

      // If no role loaded yet (e.g. still fetching or not logged in),
      // AuthMiddleware should handle login check, but here we might block or wait.
      // If we are here, we strictly check role.

      if (currentUserRole == null) {
        // If we don't know the role, better be safe and redirect to a neutral place or loading.
        // Or if not logged in, AuthMiddleware would have caught it.
        // Assuming AuthMiddleware runs BEFORE this.
        return const RouteSettings(name: Routes.SIGN_IN);
      }

      if (!allowedRoles.contains(currentUserRole)) {
        // Unauthorized. Redirect to appropriate home or error.
        // If Admin tries to access Staff page? Or Staff tries Admin page?
        // Fallback to their own home.

        if (currentUserRole == UserRole.admin) {
          if (route != Routes.ADMIN_HOME) {
            return const RouteSettings(name: Routes.ADMIN_HOME);
          }
        } else if (currentUserRole == UserRole.staff) {
          if (route != Routes.STAFF_HOME) {
            return const RouteSettings(name: Routes.STAFF_HOME);
          }
        } else {
          return const RouteSettings(name: Routes.SIGN_IN);
        }
      }
    } catch (_) {
      return const RouteSettings(name: Routes.SIGN_IN);
    }
    return null;
  }
}
