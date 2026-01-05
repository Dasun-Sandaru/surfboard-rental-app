import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/common/is_text_field_required.dart';
import '../../../../utils/helper/a_validator.dart';
import '../controllers/sign_up_controller.dart';

class SignUpView extends GetView<SignUpController> {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Obx(
          () => Text(
            controller.role.value == 'staff' ? 'Join the Team' : 'Setup Shop',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => controller.role.value == 'staff'
              ? _buildStaffForm(context)
              : _buildAdminStepper(context),
        ),
      ),
    );
  }

  // STAFF
  Widget _buildStaffForm(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(ASizes.defaultPadding),
      child: Form(
        key: controller.staffFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Header Text
            Text(
              "Create Staff Account",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 4.h),
            Text(
              "Fill in your details to get started.",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 24.h),

            /// Name
            IsTextFieldRequired(fieldName: 'Full Name'),
            SizedBox(height: 6.h),
            _buildTextField(
              controller: controller.nameController,
              hintText: 'John Doe',
              icon: Iconsax.user,
              validator: (v) => AValidator.validateText(v, 'Name'),
            ),

            SizedBox(height: 16.h),

            /// Email
            IsTextFieldRequired(fieldName: 'Email Address'),
            SizedBox(height: 6.h),
            _buildTextField(
              controller: controller.emailController,
              hintText: 'staff@surfshop.com',
              icon: Iconsax.sms,
              inputType: TextInputType.emailAddress,
              validator: (v) => AValidator.validateEmail(v),
            ),

            SizedBox(height: 16.h),

            /// Phone
            // Text(
            //   'Phone Number (Optional)',
            //   style: Theme.of(context).textTheme.bodySmall,
            // ),
            IsTextFieldRequired(fieldName: 'Phone Number'),
            SizedBox(height: 6.h),
            _buildTextField(
              controller: controller.phoneController,
              hintText: '+1 234 567 890',
              icon: Iconsax.call,
              inputType: TextInputType.phone,
              validator: (v) => AValidator.validatePhoneNumber(v),
            ),

            SizedBox(height: 16.h),

            /// Shop Code
            IsTextFieldRequired(fieldName: 'Shop Code'),
            SizedBox(height: 6.h),
            _buildTextField(
              controller: controller.shopCodeController,
              hintText: 'SHP-1234',
              icon: Iconsax.shop,
              validator: (v) => AValidator.validateText(v, 'Shop Code'),
            ),

            SizedBox(height: 16.h),

            /// Password
            IsTextFieldRequired(fieldName: 'Password'),
            SizedBox(height: 6.h),
            _buildTextField(
              controller: controller.passwordController,
              hintText: '••••••••',
              icon: Iconsax.lock,
              isObscure: controller.isObscurePassword,
              validator: (v) => AValidator.validatePassword(v),
            ),

            SizedBox(height: 16.h),

            /// Confirm Password
            IsTextFieldRequired(fieldName: 'Confirm Password'),
            SizedBox(height: 6.h),
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
              child: ElevatedButton(
                onPressed: () => controller.registerShopStaff(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 2,
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Create Account',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ADMIN
  Widget _buildAdminStepper(BuildContext context) {
    return Theme(
      data: Theme.of(
        context,
      ).copyWith(colorScheme: ColorScheme.light(primary: Colors.black87)),
      child: Obx(
        () => Stepper(
          type: StepperType.vertical,
          currentStep: controller.currentStep.value,
          elevation: 0,
          physics: const ClampingScrollPhysics(),

          /// Custom Controls (Buttons) for the Stepper
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
                              // Validate only shop information fields
                              if (_validateShopStep()) {
                                details.onStepContinue!();
                              }
                            } else {
                              // Validate owner information before registering
                              if (_validateOwnerStep()) {
                                controller.registerShopOwner();
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 2,
                          ),
                          child: controller.isLoading.value
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
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
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Back',
                            style: TextStyle(color: Colors.black87),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              content: Form(
                key: controller.shopFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    IsTextFieldRequired(fieldName: 'Shop Name'),
                    SizedBox(height: 6.h),
                    _buildTextField(
                      controller: controller.shopNameController,
                      hintText: 'Aloha Surf Rentals',
                      icon: Iconsax.shop,
                      validator: (v) => AValidator.validateText(v, 'Shop Name'),
                    ),
                    SizedBox(height: 16.h),
                    IsTextFieldRequired(fieldName: 'Location'),
                    SizedBox(height: 6.h),
                    _buildTextField(
                      controller: controller.shopLocationController,
                      hintText: 'Ahangama Beach',
                      icon: Iconsax.location,
                      validator: (v) => AValidator.validateText(v, 'Location'),
                    ),
                    SizedBox(height: 16.h),
                    IsTextFieldRequired(fieldName: 'Contact Number'),
                    SizedBox(height: 6.h),
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
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
              ),
              content: Form(
                key: controller.ownerFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8.h),
                    IsTextFieldRequired(fieldName: 'Full Name'),
                    SizedBox(height: 6.h),
                    _buildTextField(
                      controller: controller.nameController,
                      hintText: 'Your Name',
                      icon: Iconsax.user,
                      validator: (v) => AValidator.validateText(v, 'Name'),
                    ),
                    SizedBox(height: 16.h),
                    IsTextFieldRequired(fieldName: 'Email Address'),
                    SizedBox(height: 6.h),
                    _buildTextField(
                      controller: controller.emailController,
                      hintText: 'admin@surfshop.com',
                      icon: Iconsax.sms,
                      inputType: TextInputType.emailAddress,
                      validator: (v) => AValidator.validateEmail(v),
                    ),
                    SizedBox(height: 16.h),
                    IsTextFieldRequired(fieldName: 'Phone Number'),
                    SizedBox(height: 6.h),
                    _buildTextField(
                      controller: controller.phoneController,
                      hintText: '+94 77 123 4567',
                      icon: Iconsax.call,
                      inputType: TextInputType.phone,
                      validator: (v) => AValidator.validatePhoneNumber(v),
                    ),
                    SizedBox(height: 16.h),
                    IsTextFieldRequired(fieldName: 'Password'),
                    SizedBox(height: 6.h),
                    _buildTextField(
                      controller: controller.passwordController,
                      hintText: '••••••••',
                      icon: Iconsax.lock,
                      isObscure: controller.isObscurePassword,
                      validator: (v) => AValidator.validatePassword(v),
                    ),
                    SizedBox(height: 16.h),
                    IsTextFieldRequired(fieldName: 'Confirm Password'),
                    SizedBox(height: 6.h),
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
 

  /// Validate only shop information fields for Step 1
  bool _validateShopStep() {
    return controller.shopFormKey.currentState?.validate() ?? false;
  }

  /// Validate only owner information fields for Step 2
  bool _validateOwnerStep() {
    return controller.ownerFormKey.currentState?.validate() ?? false;
  }

  /// Reusable Text Field to keep code clean and consistent
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    TextInputAction textAction = TextInputAction.next,
    RxBool? isObscure,
    String? Function(String?)? validator,
  }) {
    if (isObscure != null) {
      return Obx(
        () => TextFormField(
          controller: controller,
          textInputAction: textAction,
          keyboardType: inputType,
          obscureText: isObscure.value,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20.w),
            hintText: hintText,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.h,
              horizontal: 16.w,
            ),
            suffixIcon: IconButton(
              icon: Icon(isObscure.value ? Iconsax.eye_slash : Iconsax.eye),
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
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20.w),
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: EdgeInsets.symmetric(
            vertical: 16.h,
            horizontal: 16.w,
          ),
        ),
      );
    }
  }
}
