import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';
import 'package:surfboard_rental_app/utils/validators/app_validator.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../controllers/settings_controller.dart';

class EditProfileView extends GetView<SettingsController> {
  EditProfileView({super.key});

  // Global Key for the form
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20.h),

              /// 1. Profile Image with Edit Badge
              Center(
                child: Stack(
                  children: [
                    // Avatar
                    Container(
                      padding: EdgeInsets.all(4.w), // Border effect
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 60.w,
                        backgroundColor: colorScheme.surfaceContainer,
                        // Logic to show Initials if no image is available
                        child: Obx(() {
                          final name =
                              controller.userProfile.value[FirestoreFields
                                  .name] ??
                              "?";
                          return Text(
                            name.isNotEmpty ? name[0].toUpperCase() : "?",
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 48.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }),
                      ),
                    ),

                    // Camera Badge
                    Positioned(
                      bottom: 4.h,
                      right: 4.w,
                      child: InkWell(
                        onTap: () {
                          // controller.pickImage();
                        },
                        child: Container(
                          height: 36.w,
                          width: 36.w,
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.surface,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Iconsax.camera,
                            color: colorScheme.onPrimary,
                            size: 18.w,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              /// 2. Input Fields
              _buildLabel(context, "Full Name"),
              SizedBox(height: 8.h),
              _buildTextField(
                context,
                controller: controller.nameController,
                hintText: "Enter your full name",
                icon: Iconsax.user,
                validator: (value) => AppValidator.validateText(value, 'Name'),
              ),

              SizedBox(height: 20.h),

              _buildLabel(context, "Phone Number"),
              SizedBox(height: 8.h),
              _buildTextField(
                context,
                controller: controller.phoneController,
                hintText: "Enter phone number",
                icon: Iconsax.call,
                inputType: TextInputType.phone,
                validator: (value) => AppValidator.validatePhoneNumber(value),
              ),

              SizedBox(height: 20.h),

              _buildLabel(context, "Email Address"),
              SizedBox(height: 8.h),
              _buildTextField(
                context,
                controller: controller.emailController,
                hintText: "Enter email address",
                icon: Iconsax.sms,
                inputType: TextInputType.emailAddress,
                enabled: false, // Emails are often non-editable
              ),

              SizedBox(height: 40.h),

              /// 3. Save Button
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      controller.saveProfile();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                    shadowColor: colorScheme.primary.withOpacity(0.4),
                  ),
                  child: Text(
                    "Save Changes",
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
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildLabel(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    bool enabled = true,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      enabled: enabled,
      validator: validator,
      style: TextStyle(
        color: enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        prefixIcon: Icon(
          icon,
          color: enabled
              ? colorScheme.onSurfaceVariant
              : colorScheme.onSurfaceVariant.withOpacity(0.5),
          size: 20.w,
        ),
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
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );
  }
}
