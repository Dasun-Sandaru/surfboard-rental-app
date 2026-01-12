import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/is_text_field_required.dart';
import '../../../../utils/helper/a_validator.dart';
import '../controllers/sign_in_controller.dart';

class SignInView extends GetView<SignInController> {
  const SignInView({super.key});

  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22); // Main Background
  final Color cardDark = const Color(0xFF182c30); // Input Fields
  final Color primaryBlue = const Color(0xFF4A90E2); // Primary Action
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color borderDark = const Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 1. Hero Image Section
            _buildHeader(context),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: ASizes.defaultPadding),
              child: Column(
                children: [
                  SizedBox(height: 24.h),

                  /// 2. Welcome Text
                  Text(
                    'Welcome Back!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: textWhite,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Log in to manage your surfboards rentals",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: textGrey),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 32.h),

                  /// 3. Main Form
                  _buildForm(context),

                  SizedBox(height: 24.h),

                  /// 4. Divider
                  _buildDivider(context),

                  SizedBox(height: 24.h),

                  /// 5. Improved Sign Up Section
                  _buildSignUpSection(context),

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Helper widget for the top Image/Header
  Widget _buildHeader(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 220.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: cardDark, // Slightly lighter than bg
            image: DecorationImage(
              // Add your image asset here later
              image: AssetImage("assets/login_header.jpg"),
              fit: BoxFit.cover,
              opacity: 0.5,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        // Gradient Overlay for smooth transition
        Container(
          height: 220.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                bgDark.withValues(alpha: 0.9), // Fade into background color
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
        Positioned(
          bottom: 20.h,
          left: 20.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Ride the wave",
              style: TextStyle(
                color: textWhite,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Helper widget for the Form inputs
  Widget _buildForm(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Email
          _buildLabel('Email Address'.tr),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller.emailController1,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: textWhite), // White text input
            decoration: _inputDecoration(
              hint: 'hello@surfshop.com',
              icon: Iconsax.sms,
            ),
            validator: (value) => AValidator.validateText(value, 'E-Mail'.tr),
          ),

          SizedBox(height: 20.h),

          /// Password
          _buildLabel('Password'.tr),
          SizedBox(height: 8.h),
          Obx(
            () => TextFormField(
              controller: controller.passwordController,
              textInputAction: TextInputAction.done,
              obscureText: controller.isObscure.value,
              style: TextStyle(color: textWhite),
              decoration: _inputDecoration(hint: '••••••••', icon: Iconsax.lock)
                  .copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => controller.isObscure.toggle(),
                      icon: Icon(
                        controller.isObscure.value
                            ? Iconsax.eye_slash
                            : Iconsax.eye,
                        size: 20.w,
                        color: textGrey,
                      ),
                    ),
                  ),
              validator: (value) => AValidator.validatePassword(value),
            ),
          ),

          /// Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => controller.goToForgotPassword(),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(
                'Forgot Password?',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          /// Sign In Button
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: Obx(
              () => ElevatedButton(
                onPressed: () => controller.signIn(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue, // Use Theme Blue
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
                        width: 24.h,
                        child: CircularProgressIndicator(
                          color: textWhite,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Reusable Input Decoration for Dark Mode
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      prefixIcon: Icon(icon, size: 20.w, color: textGrey),
      hintText: hint,
      hintStyle: TextStyle(color: textGrey.withValues(alpha: 0.5)),
      filled: true,
      fillColor: cardDark, // Dark background for input
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(color: textWhite, fontWeight: FontWeight.w500),
    );
  }

  /// Visual separation with "Or"
  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: borderDark, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            "Or join us",
            style: TextStyle(color: textGrey, fontSize: 12.sp),
          ),
        ),
        Expanded(child: Divider(color: borderDark, thickness: 1)),
      ],
    );
  }

  /// Sign Up Section
  Widget _buildSignUpSection(BuildContext context) {
    return Column(
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(color: textGrey, fontSize: 13.sp),
        ),
        SizedBox(height: 16.h),

        Row(
          children: [
            /// Staff Button
            Expanded(
              child: _buildOutlineButton(
                text: "As Staff",
                icon: Iconsax.user,
                color: textWhite,
                onPressed: () => controller.goToSignUpStaff(),
              ),
            ),

            SizedBox(width: 12.w),

            /// Shop Owner Button
            Expanded(
              child: _buildOutlineButton(
                text: "Setup Shop",
                icon: Iconsax.shop,
                color: primaryBlue,
                isPrimary: true,
                onPressed: () => controller.goToSignUpAdmin(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOutlineButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: isPrimary ? color : borderDark),
        backgroundColor: isPrimary
            ? color.withValues(alpha: 0.1)
            : Colors.transparent,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18.w, color: color),
          SizedBox(width: 8.w),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
