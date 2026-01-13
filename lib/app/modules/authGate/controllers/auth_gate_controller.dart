import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/app/routes/app_pages.dart';
import 'package:surfboard_rental_app/app/services/auth_service.dart';

class AuthGateController extends GetxController {
  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color errorRed = const Color(0xFFEF4444);
  final Color warningOrange = const Color(0xFFF59E0B);
  final Color cardDark = const Color(0xFF182c30);

  // -- State --
  late final String gateType;
  late final bool isInactive;

  // -- UI Variables --
  late final Color mainColor;
  late final IconData mainIcon;
  late final String title;
  late final String description;

  @override
  void onInit() {
    super.onInit();
    // 1. Get the Gate Type from arguments passed during navigation
    gateType = Get.arguments?['gate'] ?? 'unknown';
    // 2. Determine Content based on Gate Type
    isInactive = gateType == 'not-active';
    // 3. Set UI variables based on state
    mainColor = isInactive ? errorRed : warningOrange;
    mainIcon = isInactive ? Iconsax.user_remove : Iconsax.shield_search;
    title = isInactive ? "Account Deactivated" : "Approval Pending";
    description = isInactive
        ? "Your account has been deactivated by the shop administrator. You no longer have access to the dashboard."
        : "Your account is currently under review. Please wait for an administrator to verify and approve your access.";
  }

  // -- Logout User --
  Future<void> logout() async {
    // await AuthService.instance.logout();
    Get.offAllNamed(Routes.SIGN_IN);
  }
}
