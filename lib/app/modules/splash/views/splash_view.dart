import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/a_image_strings.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),

            /// Static Logo
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: ClipOval(
                child: Image.asset(
                  AImageStrings.appLogo,
                  width: 80.sp,
                  height: 80.sp,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(height: 24.h),

            /// App Name
            Text(
              "SURF DESK",
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              "Effortless Rental Management",
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
                letterSpacing: 0.5,
              ),
            ),

            const Spacer(),

            /// Loading Indicator
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: colorScheme.primary,
              ),
            ),

            SizedBox(height: 16.h),

            /// Dynamic Status Text
            Obx(
              () => Text(
                controller.updateStatus.value,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12.sp,
                ),
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
