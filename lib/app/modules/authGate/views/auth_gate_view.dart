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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),

            /// Status Icon with Glow Effect
            Obx(
              () => Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: controller.mainColor.value.withValues(
                    alpha: 0.1,
                  ), // Glow
                  border: Border.all(
                    color: controller.mainColor.value.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Icon(
                  controller.mainIcon,
                  size: 64.w,
                  color: controller.mainColor.value,
                ),
              ),
            ),

            SizedBox(height: 32.h),

            /// Title
            Text(
              controller.title,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16.h),

            /// Description
            Text(
              controller.description,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),

            const Spacer(),

            /// Contact Admin Button
            if (controller.isInactive) ...[
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Open Email or Phone logic
                  },
                  icon: Icon(Iconsax.message, color: colorScheme.onPrimary),
                  label: const Text(
                    "Contact Administrator",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
            ],

            /// Logout Button (Crucial so they aren't stuck)
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: OutlinedButton(
                onPressed: () => controller.logout(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.outline),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Text(
                  "Sign Out",
                  style: TextStyle(
                    color: colorScheme.error,
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
