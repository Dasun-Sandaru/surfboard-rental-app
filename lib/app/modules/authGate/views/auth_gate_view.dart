import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../controllers/auth_gate_controller.dart';

class AuthGateView extends GetView<AuthGateController> {
  const AuthGateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: controller.bgDark,
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
                color: controller.mainColor.withOpacity(0.1), // Glow
                border: Border.all(
                    color: controller.mainColor.withOpacity(0.3), width: 2),
              ),
              child: Icon(controller.mainIcon,
                  size: 64.w, color: controller.mainColor),
            ),

            SizedBox(height: 32.h),

            /// 2. Title
            Text(
              controller.title,
              style: TextStyle(
                color: controller.textWhite,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16.h),

            /// 3. Description
            Text(
              controller.description,
              style: TextStyle(
                  color: controller.textGrey, fontSize: 14.sp, height: 1.5),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            /// 4. Contact Admin Button (Optional, mostly for inactive)
            if (controller.isInactive) ...[
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Open Email or Phone logic
                  },
                  icon: Icon(Iconsax.message, color: controller.textWhite),
                  label: const Text(
                    "Contact Administrator",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: controller.cardDark,
                    foregroundColor: controller.textWhite,
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
                onPressed: () => controller.logout(),
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
                    color: controller.textWhite,
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
