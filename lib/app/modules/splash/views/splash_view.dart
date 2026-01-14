import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  // -- Theme Colors (Matches Admin Dashboard) --
  final Color bgDark = const Color(0xFF101f22);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textSubtle = const Color(0xFF94a3b8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
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
                color: primaryBlue.withValues(alpha: 0.1),
              ),
              child: Icon(Icons.surfing, size: 80.sp, color: primaryBlue),
            ),

            SizedBox(height: 24.h),

            /// App Name
            Text(
              "SURF RENTAL",
              style: TextStyle(
                color: textWhite,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              "Manager App",
              style: TextStyle(
                color: textSubtle,
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
                color: primaryBlue,
              ),
            ),

            SizedBox(height: 16.h),

            /// Dynamic Status Text
            Obx(
              () => Text(
                controller.updateStatus.value,
                style: TextStyle(color: textSubtle, fontSize: 12.sp),
              ),
            ),

            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}
