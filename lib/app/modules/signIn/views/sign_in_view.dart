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

  @override
  Widget build(BuildContext context) {
    // Use a slightly lighter background for the scaffold to make input fields pop
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// 1. Hero Image Section
            _buildHeader(context),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: ASizes.defaultPadding),
              child: Column(
                children: [
                  SizedBox(height: 16.h),

                  /// 2. Welcome Text
                  Text(
                    'Welcome Back!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Log in to manage your surfboards rentals",
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 24.h),

                  /// 3. Main Form
                  _buildForm(context),

                  SizedBox(height: 16.h),

                  /// 4. Divider
                  _buildDivider(context),

                  SizedBox(height: 16.h),

                  /// 5. Improved Sign Up Section
                  _buildSignUpSection(context),

                  SizedBox(height: 16.h),
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
          height: 180.h,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Colors.blueGrey,
            // Ideally use an image here:
            // image: DecorationImage(image: AssetImage('assets/surf_hero.png'), fit: BoxFit.cover),
            borderRadius: BorderRadius.only(
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
              color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Ride the wave",
              style: TextStyle(
                color: Colors.white,
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
          IsTextFieldRequired(fieldName: 'Email Address'.tr),
          SizedBox(height: 6.h),
          TextFormField(
            controller: controller.emailController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              prefixIcon: Icon(Iconsax.sms, size: 20.w),
              hintText: 'hello@surfshop.com',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: EdgeInsets.symmetric(
                vertical: 14.h,
                horizontal: 16.w,
              ),
            ),
            validator: (value) => AValidator.validateText(value, 'E-Mail'.tr),
          ),

          SizedBox(height: 16.h),

          /// Password
          IsTextFieldRequired(fieldName: 'Password'.tr),
          SizedBox(height: 6.h),
          Obx(
            () => TextFormField(
              controller: controller.passwordController,
              textInputAction: TextInputAction.done,
              obscureText: controller.isObscure.value,
              decoration: InputDecoration(
                prefixIcon: Icon(Iconsax.lock, size: 20.w),
                hintText: '••••••••',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 14.h,
                  horizontal: 16.w,
                ),
                suffixIcon: IconButton(
                  onPressed: () => controller.isObscure.toggle(),
                  icon: Icon(
                    controller.isObscure.value
                        ? Iconsax.eye_slash
                        : Iconsax.eye,
                    size: 20.w,
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
              onPressed: () {
                controller.goToForgotPassword();
              },
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(
                'Forgot Password?',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: 8.h),

          /// Sign In Button (Full Width)
          SizedBox(
            width: double.infinity,
            height: 50.h,
            child: ElevatedButton(
              onPressed: () => controller.signIn(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
              ),
              child: Text(
                'Sign In',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Visual separation with "Or"
  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            "Or join us",
            style: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
          ),
        ),
        Expanded(child: Divider(color: Colors.grey[300], thickness: 1)),
      ],
    );
  }

  /// The fixed Sign Up section
  Widget _buildSignUpSection(BuildContext context) {
    return Column(
      children: [
        Text(
          "Don't have an account?",
          style: TextStyle(color: Colors.grey[600], fontSize: 13.sp),
        ),
        SizedBox(height: 12.h),

        // Option 1: Two buttons side by side
        Row(
          children: [
            /// Staff Button
            Expanded(
              child: OutlinedButton(
                onPressed: () => controller.goToSignUpStaff(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.user, size: 16.w, color: Colors.grey[700]),
                    SizedBox(width: 8.w),
                    Text("As Staff", style: TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
            ),

            SizedBox(width: 12.w),

            /// Shop Owner Button
            Expanded(
              child: OutlinedButton(
                onPressed: () => controller.goToSignUpAdmin(),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.blueAccent.withOpacity(0.5)),
                  backgroundColor: Colors.blue.withOpacity(0.05),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.shop, size: 16.w, color: Colors.blueAccent),
                    SizedBox(width: 8.w),
                    Text(
                      "Setup Shop",
                      style: TextStyle(
                        color: Colors.blueAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
