import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../controllers/auth_gate_controller.dart';

class AuthGateView extends GetView<AuthGateController> {
  const AuthGateView({super.key});

  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color errorRed = const Color(0xFFEF4444);
  final Color warningOrange = const Color(0xFFF59E0B);
  final Color cardDark = const Color(0xFF182c30);

  @override
  Widget build(BuildContext context) {
    // 1. Get the Gate Type from arguments passed during navigation
    final String gateType = Get.arguments?['gate'] ?? 'unknown';

    // 2. Determine Content based on Gate Type
    final bool isInactive = gateType == 'not-active';

    // Config based on state
    final Color mainColor = isInactive ? errorRed : warningOrange;
    final IconData mainIcon = isInactive
        ? Iconsax.user_remove
        : Iconsax.shield_search;
    final String title = isInactive
        ? "Account Deactivated"
        : "Approval Pending";
    final String description = isInactive
        ? "Your account has been deactivated by the shop administrator. You no longer have access to the dashboard."
        : "Your account is currently under review. Please wait for an administrator to verify and approve your access.";

    return Scaffold(
      backgroundColor: bgDark,
      body: Padding(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            /// 1. Status Icon with Glow Effect
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: mainColor.withOpacity(0.1), // Glow
                border: Border.all(color: mainColor.withOpacity(0.3), width: 2),
              ),
              child: Icon(mainIcon, size: 64.w, color: mainColor),
            ),

            SizedBox(height: 32.h),

            /// 2. Title
            Text(
              title,
              style: TextStyle(
                color: textWhite,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16.h),

            /// 3. Description
            Text(
              description,
              style: TextStyle(color: textGrey, fontSize: 14.sp, height: 1.5),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            /// 4. Contact Admin Button (Optional, mostly for inactive)
            if (isInactive) ...[
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Open Email or Phone logic
                  },
                  icon: Icon(Iconsax.message, color: textWhite),
                  label: Text(
                    "Contact Administrator",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cardDark,
                    foregroundColor: textWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],

            /// 5. Logout Button (Crucial so they aren't stuck)
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: OutlinedButton(
                onPressed: () {
                  // Call your logout logic here
                  // controller.logout();
                  // Get.offAllNamed(Routes.LOGIN);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Text(
                  "Sign Out",
                  style: TextStyle(
                    color: textWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}
