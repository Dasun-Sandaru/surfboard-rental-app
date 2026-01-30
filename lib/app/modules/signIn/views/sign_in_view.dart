import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';
import '../../../../utils/validators/a_validator.dart';
import '../controllers/sign_in_controller.dart';

class SignInView extends GetView<SignInController> {
  const SignInView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            /// Hero Image Section
            _buildHeader(context),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: ASizes.defaultPadding),
              child: Column(
                children: [
                  SizedBox(height: 24.h),

                  /// Welcome Text
                  Text(
                    'welcome_back'.tr,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "login_subtitle".tr,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 32.h),

                  /// Main Form
                  _buildForm(context),

                  SizedBox(height: 24.h),

                  /// Divider
                  _buildDivider(context),

                  SizedBox(height: 24.h),

                  /// Sign Up Section
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

  /// Helper widgets

  /// Build Header
  Widget _buildHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      children: [
        Container(
          height: 220.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            image: const DecorationImage(
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

        Container(
          height: 220.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                colorScheme.surface.withValues(alpha: 0.9),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  /// Build Form
  Widget _buildForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Form(
      key: controller.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Email
          _buildLabel(context, 'Email Address'.tr),
          SizedBox(height: 8.h),
          TextFormField(
            controller: controller.signInEmailController,
            textInputAction: TextInputAction.next,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(color: colorScheme.onSurface),
            decoration: _inputDecoration(
              context,
              hint: 'hello@surfshop.com',
              icon: Iconsax.sms,
            ),
            validator: (value) =>
                AValidator.validateText(value, 'email_address'.tr),
          ),

          SizedBox(height: 20.h),

          /// Password
          _buildLabel(context, 'Password'.tr),
          SizedBox(height: 8.h),
          Obx(
            () => TextFormField(
              controller: controller.signInPasswordController,
              textInputAction: TextInputAction.done,
              obscureText: controller.isObscure.value,
              style: TextStyle(color: colorScheme.onSurface),
              decoration:
                  _inputDecoration(
                    context,
                    hint: '••••••••',
                    icon: Iconsax.lock,
                  ).copyWith(
                    suffixIcon: IconButton(
                      onPressed: () => controller.isObscure.toggle(),
                      icon: Icon(
                        controller.isObscure.value
                            ? Iconsax.eye_slash
                            : Iconsax.eye,
                        size: 20.w,
                        color: colorScheme.onSurfaceVariant,
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
                'forgot_password'.tr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
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
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                  shadowColor: colorScheme.primary.withValues(alpha: 0.4),
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                        height: 24.h,
                        width: 24.h,
                        child: CircularProgressIndicator(
                          color: colorScheme.onPrimary,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'sign_in'.tr,
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
  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      prefixIcon: Icon(icon, size: 20.w, color: colorScheme.onSurfaceVariant),
      hintText: hint,
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
      ),
      filled: true,
      fillColor: colorScheme.surfaceContainer, // Dark background for input
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.error),
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Separation with "Or"
  Widget _buildDivider(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: colorScheme.outline, thickness: 1)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(
            "or_join_us".tr,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12.sp,
            ),
          ),
        ),
        Expanded(child: Divider(color: colorScheme.outline, thickness: 1)),
      ],
    );
  }

  /// Sign Up Section
  Widget _buildSignUpSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          "dont_have_account".tr,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 16.h),

        Row(
          children: [
            /// Staff Button
            Expanded(
              child: _buildOutlineButton(
                context,
                text: "as_staff".tr,
                icon: Iconsax.user,
                color: colorScheme.onSurface,
                onPressed: () => controller.goToSignUpStaff(),
              ),
            ),

            SizedBox(width: 12.w),

            /// Shop Owner Button
            Expanded(
              child: _buildOutlineButton(
                context,
                text: "setup_shop".tr,
                icon: Iconsax.shop,
                color: colorScheme.primary,
                isPrimary: true,
                onPressed: () => controller.goToSignUpAdmin(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Reusable Outline Button
  Widget _buildOutlineButton(
    BuildContext context, {
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    bool isPrimary = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: BorderSide(color: isPrimary ? color : colorScheme.outline),
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
