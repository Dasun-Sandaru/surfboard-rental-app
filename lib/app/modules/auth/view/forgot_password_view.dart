import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/helper/a_validator.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22);
  final Color cardDark = const Color(0xFF182c30);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color borderDark = const Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text('', style: TextStyle(color: textWhite)),
      ),
      body: Padding(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        child: Form(
          key: controller.formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Text(
                "Forgot Password".tr,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textWhite,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                "Enter your email and we will send you a link to reset your password.",
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: textGrey, height: 1.5),
              ),
              SizedBox(height: 32.h),

              /// Email Input
              _buildLabel('Email Address'),
              SizedBox(height: 8.h),
              TextFormField(
                controller: controller.emailController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: textWhite), // White text input
                decoration: InputDecoration(
                  prefixIcon: Icon(Iconsax.sms, size: 20.w, color: textGrey),
                  hintText: 'hello@surfshop.com',
                  hintStyle: TextStyle(color: textGrey.withValues(alpha: 0.5)),
                  filled: true,
                  fillColor: cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderDark),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: borderDark),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: primaryBlue),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16.h,
                    horizontal: 16.w,
                  ),
                ),
                validator: (value) =>
                    AValidator.validateText(value, 'E-Mail'.tr),
              ),

              SizedBox(height: 32.h),

              /// Send Reset Button
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: textWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                      shadowColor: primaryBlue.withValues(alpha: 0.4),
                    ),
                    child: controller.isLoading.value
                        ? SizedBox(
                            height: 24.h,
                            width: 24.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "Send Reset Link",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              /// Back to Login Button (shown after success)
              Obx(
                () => controller.isSuccess.value
                    ? SizedBox(
                        width: double.infinity,
                        height: 54.h,
                        child: OutlinedButton(
                          onPressed: controller.goToLogin,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: borderDark),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                          child: Text(
                            "Back to Login",
                            style: TextStyle(
                              color: textWhite,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.sp,
                            ),
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Helper to build labels consistent with the theme
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(color: textWhite, fontWeight: FontWeight.w500),
    );
  }
}
