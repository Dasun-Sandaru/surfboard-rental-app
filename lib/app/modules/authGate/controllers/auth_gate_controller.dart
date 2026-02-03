import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../routes/app_pages.dart';
import '../../../../utils/theme/app_material_theme.dart';

class AuthGateController extends GetxController {
  // -- State --
  late final String gateType;
  late final bool isInactive;

  // -- UI Variables --
  final Rx<Color> mainColor = Colors.grey.obs;
  late final IconData mainIcon;
  late final String title;
  late final String description;

  @override
  void onInit() {
    super.onInit();
    // Get the Gate Type from arguments passed during navigation
    gateType = Get.arguments?['gate'] ?? 'unknown';
    // Determine Content based on Gate Type
    isInactive = gateType == 'not-active';

    final colorScheme = Get.theme.colorScheme;
    final statusColors = Get.theme.extension<StatusColors>();

    // Set UI variables based on state
    mainColor.value = isInactive
        ? colorScheme.error
        : (statusColors?.warning ?? Colors.orange);

    mainIcon = isInactive ? Iconsax.user_remove : Iconsax.shield_search;
    title = isInactive ? "Account Deactivated" : "Approval Pending";
    description = isInactive
        ? "Your account has been deactivated by the shop administrator. You no longer have access to the dashboard."
        : "Your account is currently under review. Please wait for an administrator to verify and approve your access.";
  }

  /// Logout User
  Future<void> logout() async {
    Get.offAllNamed(Routes.SIGN_IN);
  }
}