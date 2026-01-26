import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../../utils/helper/a_validator.dart';
import '../controllers/sign_up_controller.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Obx(
          () => Text(
            controller.role.value == UserRole.staff
                ? 'Join the Team'
                : 'Setup Shop',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => controller.role.value == UserRole.staff
              ? _buildStaffForm(context)
              : _buildAdminStepper(context),
        ),
      ),
    );
  }

  /// STAFF FORM
  Widget _buildStaffForm(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: EdgeInsets.all(ASizes.defaultPadding),
      child: Form(
        key: controller.staffFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create Staff Account",
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Fill in your details to get started.",
              style: TextStyle(
                fontSize: 14.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 24.h),

            /// Name
            _buildLabel(context, 'Full Name'),
            SizedBox(height: 8.h),
            _buildTextField(
              context,
              controller: controller.nameController,
              hintText: 'John Doe',
              icon: Iconsax.user,
              validator: (v) => AValidator.validateText(v, 'Name'),
            ),

            SizedBox(height: 16.h),

            /// Email
            _buildLabel(context, 'Email Address'),
            SizedBox(height: 8.h),
            _buildTextField(
              context,
              controller: controller.emailController,
              hintText: 'staff@surfshop.com',
              icon: Iconsax.sms,
              inputType: TextInputType.emailAddress,
              validator: (v) => AValidator.validateEmail(v),
            ),

            SizedBox(height: 16.h),

            /// Phone
            _buildLabel(context, 'Phone Number'),
            SizedBox(height: 8.h),
            _buildTextField(
              context,
              controller: controller.phoneController,
              hintText: '+1 234 567 890',
              icon: Iconsax.call,
              inputType: TextInputType.phone,
              validator: (v) => AValidator.validatePhoneNumber(v),
            ),

            SizedBox(height: 16.h),

            /// Shop Code
            _buildLabel(context, 'Shop Code'),
            SizedBox(height: 8.h),
            _buildTextField(
              context,
              controller: controller.shopCodeController,
              hintText: 'SHP-1234',
              icon: Iconsax.shop,
              validator: (v) => AValidator.validateText(v, 'Shop Code'),
            ),

            SizedBox(height: 16.h),

            /// Password
            _buildLabel(context, 'Password'),
            SizedBox(height: 8.h),
            _buildTextField(
              context,
              controller: controller.passwordController,
              hintText: '••••••••',
              icon: Iconsax.lock,
              isObscure: controller.isObscurePassword,
              validator: (v) => AValidator.validatePassword(v),
            ),

            SizedBox(height: 16.h),

            /// Confirm Password
            _buildLabel(context, 'Confirm Password'),
            SizedBox(height: 8.h),
            _buildTextField(
              context,
              controller: controller.confirmPasswordController,
              hintText: '••••••••',
              icon: Iconsax.lock,
              isObscure: controller.isObscureConfirmPassword,
              textAction: TextInputAction.done,
              validator: (value) => AValidator.validateConfirmPassword(
                controller.passwordController.text,
                value,
              ),
            ),

            SizedBox(height: 32.h),

            /// Sign Up Button
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: Obx(
                () => ElevatedButton(
                  onPressed: () => controller.registerShopStaff(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                          height: 24.h,
                          width: 24.w,
                          child: CircularProgressIndicator(
                            color: colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Create Account',
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
      ),
    );
  }

  // ADMIN STEPPER
  Widget _buildAdminStepper(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Theme(
      // Override Stepper Colors
      data: Theme.of(context).copyWith(
        canvasColor: colorScheme.surface,
        colorScheme: colorScheme.copyWith(
          primary: colorScheme.primary,
          onSurface: colorScheme.onSurface,
        ),
      ),
      child: Obx(
        () => Stepper(
          type: StepperType.vertical,
          currentStep: controller.currentStep.value,
          elevation: 0,
          physics: const ClampingScrollPhysics(),

          /// Custom Controls
          controlsBuilder: (context, details) {
            final isLastStep = controller.currentStep.value == 1;
            return Padding(
              padding: EdgeInsets.only(top: 24.h),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50.h,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: () {
                            if (controller.currentStep.value == 0) {
                              if (_validateShopStep()) {
                                details.onStepContinue!();
                              }
                            } else {
                              if (_validateOwnerStep()) {
                                controller.registerShopOwner();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: controller.isLoading.value
                              ? SizedBox(
                                  height: 24.h,
                                  width: 24.w,
                                  child: CircularProgressIndicator(
                                    color: colorScheme.onPrimary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  isLastStep ? 'Complete Setup' : 'Next Step',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  if (controller.currentStep.value > 0) ...[
                    SizedBox(width: 12.w),
                    Expanded(
                      child: SizedBox(
                        height: 50.h,
                        child: OutlinedButton(
                          onPressed: details.onStepCancel,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorScheme.outline),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(color: colorScheme.onSurface),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },

          onStepContinue: () {
            if (controller.currentStep.value < 1) {
              controller.currentStep.value++;
            }
          },
          onStepCancel: () => controller.previousStep(),
          steps: [
            /// Step 1: Shop Details
            Step(
              title: Text(
                'Shop Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: colorScheme.onSurface,
                ),
              ),
              content: Form(
                key: controller.shopFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    _buildLabel(context, 'Shop Name'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.shopNameController,
                      hintText: 'Aloha Surf Rentals',
                      icon: Iconsax.shop,
                      validator: (v) => AValidator.validateText(v, 'Shop Name'),
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel(context, 'Location'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.shopLocationController,
                      hintText: 'Ahangama Beach',
                      icon: Iconsax.location,
                      validator: (v) => AValidator.validateText(v, 'Location'),
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel(context, 'Contact Number'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.shopContactController,
                      hintText: '+94 77 123 4567',
                      icon: Iconsax.call,
                      inputType: TextInputType.phone,
                      validator: (v) => AValidator.validatePhoneNumber(v),
                    ),
                  ],
                ),
              ),
              isActive: controller.currentStep.value >= 0,
              state: controller.currentStep.value > 0
                  ? StepState.complete
                  : StepState.indexed,
            ),

            /// Step 2: Personal Details
            Step(
              title: Text(
                'Owner Information',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  color: colorScheme.onSurface,
                ),
              ),
              content: Form(
                key: controller.ownerFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    _buildLabel(context, 'Full Name'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.nameController,
                      hintText: 'Your Name',
                      icon: Iconsax.user,
                      validator: (v) => AValidator.validateText(v, 'Name'),
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel(context, 'Email Address'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.emailController,
                      hintText: 'admin@surfshop.com',
                      icon: Iconsax.sms,
                      inputType: TextInputType.emailAddress,
                      validator: (v) => AValidator.validateEmail(v),
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel(context, 'Phone Number'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.phoneController,
                      hintText: '+94 77 123 4567',
                      icon: Iconsax.call,
                      inputType: TextInputType.phone,
                      validator: (v) => AValidator.validatePhoneNumber(v),
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel(context, 'Password'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.passwordController,
                      hintText: '••••••••',
                      icon: Iconsax.lock,
                      isObscure: controller.isObscurePassword,
                      validator: (v) => AValidator.validatePassword(v),
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel(context, 'Confirm Password'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.confirmPasswordController,
                      hintText: '••••••••',
                      icon: Iconsax.lock,
                      isObscure: controller.isObscureConfirmPassword,
                      textAction: TextInputAction.done,
                      validator: (value) => AValidator.validateConfirmPassword(
                        controller.passwordController.text,
                        value,
                      ),
                    ),
                  ],
                ),
              ),
              isActive: controller.currentStep.value >= 1,
            ),
          ],
        ),
      ),
    );
  }

  // HELPER WIDGETS
  bool _validateShopStep() {
    return controller.shopFormKey.currentState?.validate() ?? false;
  }

  bool _validateOwnerStep() {
    return controller.ownerFormKey.currentState?.validate() ?? false;
  }

  /// Theme Label
  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  /// Theme Text Field
  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    TextInputAction textAction = TextInputAction.next,
    RxBool? isObscure,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    InputDecoration decoration = InputDecoration(
      prefixIcon: Icon(icon, size: 20.w, color: colorScheme.onSurfaceVariant),
      hintText: hintText,
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
      ),
      filled: true,
      fillColor: colorScheme.surfaceContainer,
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

    if (isObscure != null) {
      return Obx(
        () => TextFormField(
          controller: controller,
          textInputAction: textAction,
          keyboardType: inputType,
          obscureText: isObscure.value,
          validator: validator,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: decoration.copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                isObscure.value ? Iconsax.eye_slash : Iconsax.eye,
                size: 20.w,
                color: colorScheme.onSurfaceVariant,
              ),
              onPressed: () {
                isObscure.value = !isObscure.value;
              },
            ),
          ),
        ),
      );
    } else {
      return TextFormField(
        controller: controller,
        textInputAction: textAction,
        keyboardType: inputType,
        obscureText: false,
        validator: validator,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: decoration,
      );
    }
  }
}
