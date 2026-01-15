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
        title: Obx(
          () => Text(
            controller.role.value == UserRole.staff
                ? 'Join the Team'
                : 'Setup Shop',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: textWhite,
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
                color: textWhite,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Fill in your details to get started.",
              style: TextStyle(fontSize: 14.sp, color: textGrey),
            ),
            SizedBox(height: 24.h),

            /// Name
            _buildLabel('Full Name'),
            SizedBox(height: 8.h),
            _buildTextField(
              controller: controller.nameController,
              hintText: 'John Doe',
              icon: Iconsax.user,
              validator: (v) => AValidator.validateText(v, 'Name'),
            ),

            SizedBox(height: 16.h),

            /// Email
            _buildLabel('Email Address'),
            SizedBox(height: 8.h),
            _buildTextField(
              controller: controller.emailController,
              hintText: 'staff@surfshop.com',
              icon: Iconsax.sms,
              inputType: TextInputType.emailAddress,
              validator: (v) => AValidator.validateEmail(v),
            ),

            SizedBox(height: 16.h),

            /// Phone
            _buildLabel('Phone Number'),
            SizedBox(height: 8.h),
            _buildTextField(
              controller: controller.phoneController,
              hintText: '+1 234 567 890',
              icon: Iconsax.call,
              inputType: TextInputType.phone,
              validator: (v) => AValidator.validatePhoneNumber(v),
            ),

            SizedBox(height: 16.h),

            /// Shop Code
            _buildLabel('Shop Code'),
            SizedBox(height: 8.h),
            _buildTextField(
              controller: controller.shopCodeController,
              hintText: 'SHP-1234',
              icon: Iconsax.shop,
              validator: (v) => AValidator.validateText(v, 'Shop Code'),
            ),

            SizedBox(height: 16.h),

            /// Password
            _buildLabel('Password'),
            SizedBox(height: 8.h),
            _buildTextField(
              controller: controller.passwordController,
              hintText: '••••••••',
              icon: Iconsax.lock,
              isObscure: controller.isObscurePassword,
              validator: (v) => AValidator.validatePassword(v),
            ),

            SizedBox(height: 16.h),

            /// Confirm Password
            _buildLabel('Confirm Password'),
            SizedBox(height: 8.h),
            _buildTextField(
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
                    backgroundColor: primaryBlue,
                    foregroundColor: textWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
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
    return Theme(
      // Override Stepper Colors For Dark Mode
      data: Theme.of(context).copyWith(
        canvasColor: bgDark,
        colorScheme: ColorScheme.dark(
          primary: primaryBlue,
          onSurface: textWhite,
          background: bgDark,
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
                            backgroundColor: primaryBlue,
                            foregroundColor: textWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
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
                            side: BorderSide(color: borderDark),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Back',
                            style: TextStyle(color: textWhite),
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
                  color: textWhite,
                ),
              ),
              content: Form(
                key: controller.shopFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    _buildLabel('Shop Name'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.shopNameController,
                      hintText: 'Aloha Surf Rentals',
                      icon: Iconsax.shop,
                      validator: (v) => AValidator.validateText(v, 'Shop Name'),
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Location'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.shopLocationController,
                      hintText: 'Ahangama Beach',
                      icon: Iconsax.location,
                      validator: (v) => AValidator.validateText(v, 'Location'),
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Contact Number'),
                    SizedBox(height: 8.h),
                    _buildTextField(
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
                  color: textWhite,
                ),
              ),
              content: Form(
                key: controller.ownerFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    _buildLabel('Full Name'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.nameController,
                      hintText: 'Your Name',
                      icon: Iconsax.user,
                      validator: (v) => AValidator.validateText(v, 'Name'),
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Email Address'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.emailController,
                      hintText: 'admin@surfshop.com',
                      icon: Iconsax.sms,
                      inputType: TextInputType.emailAddress,
                      validator: (v) => AValidator.validateEmail(v),
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Phone Number'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.phoneController,
                      hintText: '+94 77 123 4567',
                      icon: Iconsax.call,
                      inputType: TextInputType.phone,
                      validator: (v) => AValidator.validatePhoneNumber(v),
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Password'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.passwordController,
                      hintText: '••••••••',
                      icon: Iconsax.lock,
                      isObscure: controller.isObscurePassword,
                      validator: (v) => AValidator.validatePassword(v),
                    ),
                    SizedBox(height: 16.h),
                    _buildLabel('Confirm Password'),
                    SizedBox(height: 8.h),
                    _buildTextField(
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

  /// Dark Theme Label
  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(color: textWhite, fontWeight: FontWeight.w500),
    );
  }

  /// Dark Theme Text Field
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    TextInputAction textAction = TextInputAction.next,
    RxBool? isObscure,
    String? Function(String?)? validator,
  }) {
    InputDecoration decoration = InputDecoration(
      prefixIcon: Icon(icon, size: 20.w, color: textGrey),
      hintText: hintText,
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
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
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
          style: TextStyle(color: textWhite),
          decoration: decoration.copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                isObscure.value ? Iconsax.eye_slash : Iconsax.eye,
                size: 20.w,
                color: textGrey,
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
        style: TextStyle(color: textWhite),
        decoration: decoration,
      );
    }
  }


}
