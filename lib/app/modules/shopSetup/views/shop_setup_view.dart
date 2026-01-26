import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../controllers/shop_setup_controller.dart';

class ShopSetupView extends GetView<ShopSetupController> {
  const ShopSetupView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(ASizes.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),

              /// Branding/Logo Placeholder
              Center(
                child: Container(
                  height: 100.w,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer,
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.primary, width: 2),
                  ),
                  child: Icon(
                    Iconsax.shop,
                    size: 40.w,
                    color: colorScheme.primary,
                  ),
                ),
              ),

              SizedBox(height: 32.h),

              /// Titles
              Text(
                'Set Up Your Shop',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Tell us a little about your surf shop to get started.',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14.sp,
                ),
              ),

              SizedBox(height: 32.h),

              /// Form
              _buildLabel(context, "Shop Name"),
              SizedBox(height: 8.h),
              _buildTextField(
                context,
                hintText: "Pacific Surf Rentals",
                icon: Iconsax.shop,
              ),

              SizedBox(height: 20.h),

              _buildLabel(context, "Location"),
              SizedBox(height: 8.h),
              _buildTextField(
                context,
                hintText: "Waikiki Beach, Hawaii",
                icon: Iconsax.location,
              ),

              SizedBox(height: 20.h),

              _buildLabel(context, "Contact Number"),
              SizedBox(height: 8.h),
              _buildTextField(
                context,
                hintText: "+1 (808) 555-0123",
                icon: Iconsax.call,
                keyboardType: TextInputType.phone,
              ),

              SizedBox(height: 20.h),

              _buildLabel(context, "Business Email"),
              SizedBox(height: 8.h),
              _buildTextField(
                context,
                hintText: "contact@pacificsurf.com",
                icon: Iconsax.sms,
                keyboardType: TextInputType.emailAddress,
              ),

              SizedBox(height: 48.h),

              /// Action Button
              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement shop setup logic
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Finish Setup",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
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
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return TextFormField(
      keyboardType: keyboardType,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withOpacity(0.5),
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainer,
        prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant, size: 20.w),
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );
  }
}
