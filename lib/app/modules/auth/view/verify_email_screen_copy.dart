import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/a_sizes.dart';
import '../controllers/verify_email_controller.dart';

class VerifyEmailScreenCopy extends GetView<VerifyEmailController> {
  const VerifyEmailScreenCopy({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(automaticallyImplyLeading: false),
      body: Obx(() {
        return Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(ASizes.defaultPadding),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// 1. Icon
                  Icon(Iconsax.verify, size: 100.w, color: Colors.blueAccent),
                  SizedBox(height: 32.h),

                  /// 2. Text
                  Text(
                    'Verify your email address',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'We have sent a verification link to your email address. Please check your inbox and click the link to activate your account.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 32.h),

                  /// 3. Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: ElevatedButton(
                      // Redirect to Login Page
                      onPressed: controller.goToLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back to Login'),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  /// 4. Resend Button
                  TextButton(
                    onPressed: controller.resendVerificationEmail,
                    child: const Text('Resend Email'),
                  ),

                  SizedBox(height: 16.h),

                  /// 5. Check Verification Status
                  TextButton(
                    onPressed: controller.checkEmailVerification,
                    child: const Text('Check Verification Status'),
                  ),
                ],
              ),
            ),
            if (!controller.isEmailVerified.value)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}
