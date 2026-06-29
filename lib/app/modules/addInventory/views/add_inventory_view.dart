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
              ? "edit_board".tr
              : "add_board".tr,
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
                    _buildLabel(context, 'board_name'.tr),
                    SizedBox(height: 8.h),
                    _buildBoardName(context, controller),

                    SizedBox(height: 20.h),

                    /// 3. Type
                    _buildLabel(context, 'surfboard_type'.tr),
                    SizedBox(height: 8.h),
                    _buildTypeDropdown(context, controller),

                    SizedBox(height: 20.h),

                    /// 1. Brand (Dropdown)
                    _buildLabel(context, 'brand'.tr),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.brandController,
                      hintText: "e.g., Surfline",
                      icon: Icons.storefront,
                      validator: (v) => AValidator.validateText(v, 'brand'.tr),
                      textAction: TextInputAction.next,
                    ),

                    SizedBox(height: 20.h),

                    /// 2. Size (Split Inputs)
                    _buildLabel(context, 'size'.tr),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        // Feet Input
                        Expanded(
                          child: _buildTextField(
                            context,
                            controller: controller.sizeFeetController,
                            hintText: "6 ${'feet'.tr}",
                            validator: (v) =>
                                AValidator.validateNumber(v, 'feet'.tr),
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
                            hintText: "2 ${'inches'.tr}",
                            validator: (v) =>
                                AValidator.validateNumber(v, 'inches'.tr),
                            icon: Icons.straighten,
                            inputType: TextInputType.number,
                            textAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 20.h),

                    /// Volume
                    _buildLabel(context, 'volume'.tr),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.volumeController,
                      validator: (v) => AValidator.validateNumber(v, 'volume'.tr),
                      icon: Icons.water_drop,
                      hintText: "e.g., 34L",
                      inputType: TextInputType.number,
                      textAction: TextInputAction.next,
                    ),

                    SizedBox(height: 20.h),

                    /// 4. Color
                    _buildLabel(context, 'color'.tr),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.colorController,
                      icon: Icons.color_lens,
                      validator: (v) => AValidator.validateText(v, 'color'.tr),
                      hintText: "e.g., Blue with stripes",
                      textAction: TextInputAction.next,
                    ),

                    SizedBox(height: 20.h),

                    /// 5. Purchase Cost
                    _buildLabel(context, 'purchase_cost'.tr),
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
                          AValidator.validateAmount(v, 'purchase_cost'.tr),
                      textAction: TextInputAction.next,
                    ),

                    /// rental rate hour
                    SizedBox(height: 20.h),
                    _buildLabel(context, 'rental_rate_hourly'.tr),
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
                          AValidator.validateAmount(v, 'rental_rate_hourly'.tr),
                      textAction: TextInputAction.next,
                    ),

                    SizedBox(height: 20.h),

                    /// rental rate day
                    _buildLabel(context, 'rental_rate_daily'.tr),
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
                          AValidator.validateAmount(v, 'rental_rate_daily'.tr),
                      textAction: TextInputAction.next,
                    ),

                    SizedBox(height: 20.h),

                    /// Notes
                    _buildLabel(context, 'notes'.tr),
                    SizedBox(height: 8.h),
                    _buildTextField(
                      context,
                      controller: controller.notesController,
                      icon: Icons.note,
                      hintText: "additional_details_hint".tr,
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
                        ? "update_board_details".tr
                        : "add_board_details".tr,
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
      hintText: 'select_board_type'.tr,
      items: SurfBoardType.values,
      headerBuilder: (context, selectedItem, enabled) {
        return Text(
          selectedItem.name.tr,
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
                item.name.tr,
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
          return 'select_board_type_err'.tr;
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
