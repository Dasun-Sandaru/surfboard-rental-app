import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/validators/a_validator.dart'; // Assuming you have validators
import '../controllers/add_edit_customer_controller.dart';

class AddEditCustomerView extends GetView<AddEditCustomerController> {
  const AddEditCustomerView({super.key});

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
            controller.isEditMode.value
                ? "edit_customer".tr
                : "add_customer".tr,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ASizes.defaultPadding),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// 1. Name Section
                    _buildSectionHeader(context, "personal_information".tr),
                    SizedBox(height: 16.h),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(context, "first_name".tr),
                              SizedBox(height: 8.h),
                              _buildTextField(
                                context,
                                controller: controller.firstNameController,
                                hintText: "John",
                                icon: Iconsax.user,
                                validator: (v) =>
                                    AValidator.validateText(v, "first_name".tr),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(context, "last_name".tr),
                              SizedBox(height: 8.h),
                              _buildTextField(
                                context,
                                controller: controller.lastNameController,
                                hintText: "Doe",
                                icon: Iconsax.user,
                                validator: (v) =>
                                    AValidator.validateText(v, "last_name".tr),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    /// 2. Contact Section
                    _buildSectionHeader(context, "contact_details".tr),
                    SizedBox(height: 16.h),

                    _buildLabel(context, "phone".tr),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.phoneController,
                      hintText: "(808) 555-0123",
                      icon: Iconsax.call,
                      inputType: TextInputType.phone,
                      validator: (v) => AValidator.validatePhoneNumber(v),
                    ),

                    SizedBox(height: 20.h),

                    _buildLabel(context, "email".tr),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.emailController,
                      hintText: "john.doe@example.com",
                      icon: Iconsax.sms,
                      inputType: TextInputType.emailAddress,
                      validator: (v) => AValidator.validateEmail(v),
                    ),

                    SizedBox(height: 20.h),

                    /// 3. Identification
                    _buildSectionHeader(context, "identification".tr),
                    SizedBox(height: 16.h),

                    _buildLabel(context, "nic_passport_number".tr),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.nicController,
                      hintText: "N123456789",
                      icon: Iconsax.card,
                      validator: (v) =>
                          AValidator.validateText(v, "nic_passport_number".tr),
                    ),

                    SizedBox(height: 20.h),

                    /// 4. Notes
                    _buildSectionHeader(context, "additional_info".tr),
                    SizedBox(height: 16.h),

                    _buildLabel(context, "notes".tr),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.notesController,
                      hintText: "enter_customer_notes".tr,
                      icon: Iconsax.note,
                      maxLines: 4,
                      textAction: TextInputAction.newline,
                      inputType: TextInputType.multiline,
                    ),

                    SizedBox(height: 50.h), // Bottom padding for scrolling
                  ],
                ),
              ),
            ),
          ),

          /// Bottom Save Button
          Container(
            padding: EdgeInsets.all(ASizes.defaultPadding),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(top: BorderSide(color: colorScheme.outline)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: controller.saveCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Obx(
                    () => Text(
                      controller.isEditMode.value
                          ? "update_customer".tr
                          : "save_customer".tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // HELPER WIDGETS
  // ===========================================================================

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 4.h),
        Divider(color: colorScheme.outline),
      ],
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputAction textAction = TextInputAction.next,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      textInputAction: textAction,
      maxLines: maxLines,
      style: TextStyle(color: colorScheme.onSurface),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant, size: 20.w),
        prefixIconConstraints: maxLines > 1
            ? BoxConstraints(minWidth: 48.w, minHeight: 48.w, maxHeight: 48.w)
            : null,
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );
  }
}
