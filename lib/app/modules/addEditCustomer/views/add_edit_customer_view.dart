import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/helper/a_validator.dart'; // Assuming you have validators
import '../controllers/add_edit_customer_controller.dart';

class AddEditCustomerView extends GetView<AddEditCustomerController> {
  const AddEditCustomerView({super.key});

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
            controller.isEditMode.value ? "Edit Customer" : "Add Customer",
            style: TextStyle(
              color: textWhite,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // actions: [
        //   TextButton(
        //     onPressed: controller.saveCustomer,
        //     child: Text(
        //       "Save",
        //       style: TextStyle(
        //         color: primaryBlue,
        //         fontSize: 16.sp,
        //         fontWeight: FontWeight.bold,
        //       ),
        //     ),
        //   ),
        //   SizedBox(width: 8.w),
        // ],
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
                    _buildSectionHeader("Personal Information"),
                    SizedBox(height: 16.h),

                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("First Name"),
                              SizedBox(height: 8.h),
                              _buildTextField(
                                controller: controller.firstNameController,
                                hintText: "John",
                                icon: Iconsax.user,
                                validator: (v) =>
                                    AValidator.validateText(v, "First Name"),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Last Name"),
                              SizedBox(height: 8.h),
                              _buildTextField(
                                controller: controller.lastNameController,
                                hintText: "Doe",
                                icon: Iconsax.user,
                                validator: (v) =>
                                    AValidator.validateText(v, "Last Name"),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    /// 2. Contact Section
                    _buildSectionHeader("Contact Details"),
                    SizedBox(height: 16.h),

                    _buildLabel("Phone Number"),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.phoneController,
                      hintText: "(808) 555-0123",
                      icon: Iconsax.call,
                      inputType: TextInputType.phone,
                      validator: (v) => AValidator.validatePhoneNumber(v),
                    ),

                    SizedBox(height: 20.h),

                    _buildLabel("Email Address"),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.emailController,
                      hintText: "john.doe@example.com",
                      icon: Iconsax.sms,
                      inputType: TextInputType.emailAddress,
                      validator: (v) => AValidator.validateEmail(v),
                    ),

                    SizedBox(height: 20.h),

                    /// 3. Identification
                    _buildSectionHeader("Identification"),
                    SizedBox(height: 16.h),

                    _buildLabel("NIC / Passport Number"),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.nicController,
                      hintText: "N123456789",
                      icon: Iconsax.card,
                      validator: (v) =>
                          AValidator.validateText(v, "NIC Or Passport Number"),
                    ),

                    SizedBox(height: 20.h),

                    /// 4. Notes
                    _buildSectionHeader("Additional Info"),
                    SizedBox(height: 16.h),

                    _buildLabel("Notes"),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.notesController,
                      hintText: "Add customer preferences or notes...",
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
              color: bgDark,
              border: Border(top: BorderSide(color: borderDark)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: controller.saveCustomer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: Obx(
                  () => Text(
                    controller.isEditMode.value
                        ? "Update Customer"
                        : "Save Customer",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: textWhite,
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

  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: textGrey,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            // uppercase: true,
          ),
        ),
        SizedBox(height: 4.h),
        Divider(color: borderDark),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: textWhite,
        fontWeight: FontWeight.w600,
        fontSize: 14.sp,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputAction textAction = TextInputAction.next,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      textInputAction: textAction,
      maxLines: maxLines,
      style: TextStyle(color: textWhite),
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: textGrey.withOpacity(0.5)),
        filled: true,
        fillColor: cardDark,
        prefixIcon: Icon(icon, color: textGrey, size: 20.w),
        // Align icon to top if textarea
        prefixIconConstraints: maxLines > 1
            ? BoxConstraints(minWidth: 48.w, minHeight: 48.w, maxHeight: 48.w)
            : null,
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
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      ),
    );
  }
}
