import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/validators/a_validator.dart';
import '../controllers/settings_controller.dart';

class EditShopView extends GetView<SettingsController> {
  EditShopView({super.key});

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
          "Edit Shop Details",
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

              /// Shop Icon (Static for now)
              Center(
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 50.w,
                    backgroundColor: colorScheme.surfaceContainer,
                    child: Icon(
                      Iconsax.shop,
                      color: colorScheme.primary,
                      size: 40.w,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              /// Shop Name
              _buildLabel(context, "Shop Name"),
              SizedBox(height: 8.h),
              _buildTextField(
                context,
                controller: controller.shopNameController,
                hintText: "Enter shop name",
                icon: Iconsax.shop,
                validator: (value) =>
                    AValidator.validateText(value, 'Shop Name'),
              ),

              SizedBox(height: 20.h),

              /// Location
              _buildLabel(context, "Location"),
              SizedBox(height: 8.h),
              _buildTextField(
                context,
                controller: controller.shopLocationController,
                hintText: "Enter shop location",
                icon: Iconsax.location,
                validator: (value) =>
                    AValidator.validateText(value, 'Location'),
              ),

              SizedBox(height: 20.h),

              /// Shop Contact Number
              _buildLabel(context, "Shop Contact Number"),
              SizedBox(height: 8.h),
              _buildTextField(
                context,
                controller: controller.shopContactController,
                hintText: "Enter shop contact number",
                icon: Iconsax.call,
                validator: (value) => AValidator.validatePhoneNumber(value),
              ),

              SizedBox(height: 40.h),

              /// Save Button
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      controller.saveShopDetails();
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
