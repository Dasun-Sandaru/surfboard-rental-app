import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../../utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/validators/a_validator.dart'; // Assuming you have validators
import '../controllers/add_inventory_controller.dart';

class AddInventoryView extends StatelessWidget {
  const AddInventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddInventoryController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: false,
        leadingIcon: Icons.close,
        leadingOnPressed: () => Get.back(),
        centerTitle: true,
        title: Text(
          controller.mode == InventoryFormMode.edit
              ? "Edit Board"
              : "Add Board",
          style: TextStyle(
            color: colorScheme.onSurface,
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
                    _buildLabel(context, 'Board Name'),
                    SizedBox(height: 8.h),
                    _buildBoardName(context, controller),

                    SizedBox(height: 20.h),

                    /// 3. Type
                    _buildLabel(context, 'Surfboard Type'),
                    SizedBox(height: 8.h),
                    _buildTypeDropdown(context, controller),

                    SizedBox(height: 20.h),

                    /// 1. Brand (Dropdown)
                    _buildLabel(context, 'Brand'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.brandController,
                      hintText: "e.g., Surfline",
                      icon: Icons.storefront,
                      validator: (v) => AValidator.validateText(v, 'Brand'),
                      textAction: TextInputAction.next,
                    ),

                    SizedBox(height: 20.h),

                    /// 2. Size (Split Inputs)
                    _buildLabel(context, 'Size'),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        // Feet Input
                        Expanded(
                          child: _buildTextField(
                            context,
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
                            context,
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
                    _buildLabel(context, 'Volume'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.volumeController,
                      validator: (v) => AValidator.validateNumber(v, 'Volume'),
                      icon: Icons.water_drop,
                      hintText: "e.g., 34L",
                      inputType: TextInputType.number,
                      textAction: TextInputAction.next,
                    ),

                    SizedBox(height: 20.h),

                    /// 4. Color
                    _buildLabel(context, 'Color'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.colorController,
                      icon: Icons.color_lens,
                      validator: (v) => AValidator.validateText(v, 'Color'),
                      hintText: "e.g., Blue with stripes",
                      textAction: TextInputAction.next,
                    ),

                    SizedBox(height: 20.h),

                    /// 5. Purchase Cost
                    _buildLabel(context, 'Purchase Cost'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
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
                    _buildLabel(context, 'Rental Rate (Hourly)'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
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
                    _buildLabel(context, 'Rental Rate (Daily)'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
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
                    _buildLabel(context, 'Notes'),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
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
              color: colorScheme.surface,
              border: Border(top: BorderSide(color: colorScheme.outline)),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: controller.saveItem,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    controller.mode == InventoryFormMode.edit
                        ? "Update Board Details"
                        : "Add Board Details",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
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
  // WIDGET BUILDERS
  // ===========================================================================

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
    TextInputAction textAction = TextInputAction.next,
    RxBool? isObscure,
    String? Function(String?)? validator,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    InputDecoration decoration = InputDecoration(
      prefixIcon: Icon(icon, size: 20.w, color: colorScheme.onSurfaceVariant),
      hintText: hintText,
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
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

  Widget _buildTypeDropdown(
    BuildContext context,
    AddInventoryController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return CustomDropdown<SurfBoardType>(
      controller: controller.surfboardTypeController,
      hintText: 'Select board type',
      items: SurfBoardType.values,
      headerBuilder: (context, selectedItem, enabled) {
        return Text(
          selectedItem.name,
          style: TextStyle(color: colorScheme.onSurface, fontSize: 16.sp),
        );
      },
      listItemBuilder: (context, item, isSelected, onItemSelect) {
        return Material(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surface,
          child: InkWell(
            onTap: onItemSelect,
            splashColor: colorScheme.primary.withValues(alpha: 0.1),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Text(
                item.name,
                style: TextStyle(
                  color: isSelected
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16.sp,
                ),
              ),
            ),
          ),
        );
      },
      onChanged: (value) {
        controller.surfboardTypeController.value = value;
        controller.updateBoardName();
      },
      validator: (SurfBoardType? value) {
        if (value == null) {
          return 'Please select a board type';
        }
        return null;
      },
      decoration: CustomDropdownDecoration(
        closedFillColor: colorScheme.surfaceContainer,
        expandedFillColor: colorScheme.surfaceContainer,
        closedBorder: Border.all(color: colorScheme.outline),
        expandedBorder: Border.all(color: colorScheme.primary),
        closedBorderRadius: BorderRadius.circular(12),
        expandedBorderRadius: BorderRadius.circular(12),
        listItemDecoration: ListItemDecoration(
          selectedColor: colorScheme.primaryContainer,
        ),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          fontSize: 16.sp,
        ),
        closedErrorBorder: Border.all(color: colorScheme.error),
        errorStyle: TextStyle(color: colorScheme.error, fontSize: 14.sp),
        closedSuffixIcon: Icon(
          Iconsax.arrow_down_2,
          size: 20.w,
          color: colorScheme.onSurfaceVariant,
        ),
        expandedSuffixIcon: Icon(
          Iconsax.arrow_up_2,
          size: 20.w,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildBoardName(
    BuildContext context,
    AddInventoryController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Obx(
        () => Text(
          controller.boardName.value,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14.sp,
          ),
        ),
      ),
    );
  }
}
