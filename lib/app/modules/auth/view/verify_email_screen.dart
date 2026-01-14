import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/a_sizes.dart';
import '../controllers/verify_email_controller.dart';

class VerifyEmailScreen extends GetView<VerifyEmailController> {
  const VerifyEmailScreen({super.key});

  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color borderDark = const Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        return Padding(
          padding: EdgeInsets.all(ASizes.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Icon (Glow Effect)
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryBlue.withValues(alpha: 0.1),
                ),
                child: Icon(Iconsax.verify, size: 80.w, color: primaryBlue),
              ),

              SizedBox(height: 32.h),

              Text(
                'Verify your email address',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: textWhite,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'We have sent a verification link to your email address. Please check your inbox and click the link to activate your account.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textGrey, height: 1.5),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 32.h),

              /// Continue Button
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: controller.goToLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: textWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    'Back to Login',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              /// Resend Button
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: OutlinedButton(
                  onPressed: controller.resendVerificationEmail,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: borderDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    'Resend Email',
                    style: TextStyle(
                      color: textWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              /// Check Verification Status (Auto-check Indicator)
              if (!controller.isEmailVerified.value)
                Column(
                  children: [
                    SizedBox(
                      height: 24.h,
                      width: 24.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryBlue),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      "Waiting for verification...",
                      style: TextStyle(color: textGrey, fontSize: 12.sp),
                    ),
                  ],
                ),
            ],
          ),
        );
      }),
    );
  }
}
