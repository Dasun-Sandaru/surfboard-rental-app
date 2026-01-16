import 'dart:developer';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/helper/a_validator.dart'; // Assuming you have validators
import '../controllers/add_inventory_controller.dart';

class AddInventoryView extends StatelessWidget {
  const AddInventoryView({super.key});

  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22);
  final Color cardDark = const Color(0xFF182c30);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color borderDark = const Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddInventoryController());

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        showbackArrow: false,
        leadingIcon: Icons.close,
        leadingOnPressed: () => Get.back(),
        centerTitle: true,
        title: Text(
          "Add Board",
          style: TextStyle(
            color: textWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
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
                    /// Name
                    _buildLabel('Board Name'),
                    SizedBox(height: 8.h),
                    _buildBoardName(controller),

                    SizedBox(height: 20.h),

                    /// 3. Type
                    _buildLabel('Surfboard Type'),
                    SizedBox(height: 8.h),
                    _buildTypeDropdown(controller),

                    SizedBox(height: 20.h),

                    /// 1. Brand (Dropdown)
                    _buildLabel('Brand'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.brandController,
                      hintText: "e.g., Surfline",
                      icon: Icons.storefront,
                      validator: (v) => AValidator.validateText(v, 'Brand'),
                      textAction: TextInputAction.next,
                    ),

                    SizedBox(height: 20.h),

                    /// 2. Size (Split Inputs)
                    _buildLabel('Size'),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        // Feet Input
                        Expanded(
                          child: _buildTextField(
                            controller: controller.sizeFeetController,
                            hintText: "6 ft",
                            validator: (v) =>
                                AValidator.validateNumber(v, 'Size Feet'),
                            icon: Icons.height,
                            inputType: TextInputType.number,
                            textAction: TextInputAction.next,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        // Inches Input
                        Expanded(
                          child: _buildTextField(
                            controller: controller.sizeInchesController,
                            hintText: "2 in",
                            validator: (v) =>
                                AValidator.validateNumber(v, 'Size Inches'),
                            icon: Icons.straighten,
                            inputType: TextInputType.number,
                            textAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    /// Volume
                    _buildLabel('Volume'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.volumeController,
                      validator: (v) => AValidator.validateNumber(v, 'Volume'),
                      icon: Icons.water_drop,
                      hintText: "e.g., 34L",
                      inputType: TextInputType.number,
                      textAction: TextInputAction.next,
                    ),

                    SizedBox(height: 20.h),

                    /// 4. Color
                    _buildLabel('Color'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.colorController,
                      icon: Icons.color_lens,
                      validator: (v) => AValidator.validateText(v, 'Color'),

                      hintText: "e.g., Blue with stripes",
                      textAction: TextInputAction.next,
                    ),

                    SizedBox(height: 20.h),

                    /// 5. Purchase Cost
                    _buildLabel('Purchase Cost'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.costController,
                      hintText: "0.00",
                      icon: Icons.attach_money,
                      inputType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) =>
                          AValidator.validateAmount(v, 'Purchase Cost'),
                      textAction: TextInputAction.next,
                    ),

                    /// rental rate hour
                    SizedBox(height: 20.h),
                    _buildLabel('Rental Rate (Hourly)'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.rentalRateController,
                      hintText: "0.00",
                      icon: Icons.attach_money,
                      inputType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) =>
                          AValidator.validateAmount(v, 'Rental Rate'),
                      textAction: TextInputAction.next,
                    ),

                    SizedBox(height: 20.h),

                    /// rental rate day
                    _buildLabel('Rental Rate (Daily)'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.rentalRateDayController,
                      hintText: "0.00",
                      icon: Icons.attach_money,
                      inputType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (v) =>
                          AValidator.validateAmount(v, 'Rental Rate (Daily)'),
                      textAction: TextInputAction.next,
                    ),

                    SizedBox(height: 20.h),

                    /// Notes
                    _buildLabel('Notes'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      controller: controller.notesController,
                      icon: Icons.note,
                      hintText: "Additional details about the board",
                      inputType: TextInputType.multiline,
                      textAction: TextInputAction.done,
                      validator: (v) => null,
                    ),

                    // Extra space at bottom to ensure scrolling above button
                    SizedBox(height: 50.h),
                  ],
                ),
              ),
            ),
          ),

          /// Bottom Action Bar
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
                onPressed: controller.saveItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  "Save Item",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: textWhite,
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
  // WIDGET BUILDERS
  // ===========================================================================

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

  Widget _buildTypeDropdown(AddInventoryController controller) {
    return CustomDropdown<String>(
      controller: controller.surfboardTypeController,
      hintText: 'Select board type',
      items: controller.surfboardTypelist,
      // initialItem: controller.list[0],
      onChanged: (value) {
        controller.typeController.text = value ?? '';
        log('changing value to: $value');
      },
      validator: (String? value) {
        if (value == null || value.isEmpty) {
          return 'Please select a board type';
        }
        return null;
      },
      decoration: CustomDropdownDecoration(
        closedFillColor: cardDark,
        expandedFillColor: cardDark,
        closedBorder: BoxBorder.all(color: borderDark),
        expandedBorder: BoxBorder.all(color: primaryBlue),
        hintStyle: TextStyle(color: textGrey.withOpacity(0.5), fontSize: 16.sp),
        listItemStyle: TextStyle(color: textWhite, fontSize: 16.sp),
        headerStyle: TextStyle(color: textWhite, fontSize: 16.sp),
        closedErrorBorder: BoxBorder.all(color: Colors.redAccent),
        errorStyle: TextStyle(color: Colors.redAccent, fontSize: 14.sp),
        closedSuffixIcon: Icon(
          Iconsax.arrow_down_2,
          size: 20.w,
          color: textGrey,
        ),
        expandedSuffixIcon: Icon(
          Iconsax.arrow_up_2,
          size: 20.w,
          color: primaryBlue,
        ),
      ),
    );
  }

  Widget _buildBoardName(AddInventoryController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderDark),
      ),
      child: Obx(
        () => Text(
          controller.boardName.value,
          style: TextStyle(color: textGrey, fontSize: 14.sp),
        ),
      ),
    );
  }
}
