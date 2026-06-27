import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../../../../utils/helper/a_formatter.dart';
import '../controllers/settings_controller.dart';

class RentalPricingLogicView extends GetView<SettingsController> {
  const RentalPricingLogicView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        title: Text(
          "Rental Pricing Logic",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: controller.saveRentalConfig,
            child: Text(
              "Save",
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        child: Form(
          key: controller.rentalConfigFormKey,
          child: Column(
            children: [
              _buildExplanationCard(
                context,
                title: "Hourly Grace Period",
                description:
                    "The grace period allowed after an hour has passed before charging for the next hour.",
                example:
                    "Example: If set to 15 minutes.\nRent Start: 10:00 AM\nReturn: 11:14 AM -> Charged for 1 Hour\nReturn: 11:16 AM -> Charged for 2 Hours",
                child: _buildTextField(
                  context,
                  controller: controller.hourlyGracePeriodController,
                  label: "Minutes",
                  hintText: "e.g. 15",
                  icon: Iconsax.clock,
                  inputType: TextInputType.number,
                ),
              ),
              SizedBox(height: 16.h),
              _buildExplanationCard(
                context,
                title: "Daily Grace Period",
                description:
                    "The grace period allowed after a 24-hour cycle before charging for the next day.",
                example:
                    "Example: If set to 1 hour.\nRent Start: Today 10:00 AM\nReturn: Tomorrow 11:00 AM -> Charged for 1 Day\nReturn: Tomorrow 11:01 AM -> Charged for 2 Days",
                child: _buildTextField(
                  context,
                  controller: controller.dailyGracePeriodController,
                  label: "Hours",
                  hintText: "e.g. 1",
                  icon: Iconsax.clock,
                  inputType: TextInputType.number,
                ),
              ),
              SizedBox(height: 16.h),
              _buildExplanationCard(
                context,
                title: "Tax Configuration",
                description: "Apply a percentage tax to the final rental total.",
                example:
                    "Example: If rate = 10% and Total = \$100\nFinal Amount = \$110",
                child: Column(
                  children: [
                    Obx(
                      () => SwitchListTile(
                        title: Text(
                          "Enable Tax",
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: controller.isTaxEnabled.value,
                        onChanged: (val) => controller.isTaxEnabled.value = val,
                        activeColor: colorScheme.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    Obx(
                      () => controller.isTaxEnabled.value
                          ? Padding(
                            padding: EdgeInsets.only(top: 8.h),
                            child: _buildTextField(
                              context,
                              controller: controller.taxRateController,
                              label: "Tax Rate (%)",
                              hintText: "e.g. 5.0",
                              icon: Iconsax.percentage_square,
                              inputType: TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                            ),
                          )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),

              /// Pricing Simulator
              _buildPricingSimulator(context),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExplanationCard(
    BuildContext context, {
    required String title,
    required String description,
    required String example,
    required Widget child,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.info_circle,
                color: colorScheme.primary,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            description,
            style: TextStyle(color: colorScheme.onSurface, fontSize: 14.sp),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(12.w),
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            child: Text(
              example,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12.sp,
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: inputType,
          style: TextStyle(color: colorScheme.onSurface),
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSimulator(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pricing Simulator",
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // Rent Type Dropdown
          Row(
            children: [
              Expanded(
                child: Obx(
                  () => CustomDropdown<RentType>(
                    hintText: 'Select Type',
                    items: RentType.values,
                    initialItem: controller.simRentType.value,
                    onChanged: (val) {
                      if (val != null) {
                        controller.resetSimulator(val);
                      }
                    },
                    decoration: CustomDropdownDecoration(
                      closedFillColor: colorScheme.surface,
                      expandedFillColor: colorScheme.surface,
                      closedBorder: Border.all(color: colorScheme.outline),
                      closedBorderRadius: BorderRadius.circular(8),
                    ),
                    listItemBuilder: (context, item, isSelected, onItemSelect) {
                      return Text(item.name.capitalizeFirst!);
                    },
                    headerBuilder: (context, selectedItem, enabled) {
                      return Text(selectedItem.name.capitalizeFirst!);
                    },
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              ElevatedButton(
                onPressed: () {
                  if (controller.rentalConfigFormKey.currentState!.validate()) {
                    controller.calculateSimulatedPrice();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text("Test"),
              ),
            ],
          ),
          SizedBox(height: 16.h),

          // Duration Inputs
          Obx(() {
            if (controller.simRentType.value == RentType.daily) {
              return Row(
                children: [
                  Expanded(
                    child: _buildSimulatorInput(
                      context,
                      label: "Days",
                      value: controller.simDurationDays,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildSimulatorInput(
                      context,
                      label: "Hours",
                      value: controller.simDurationHours,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildSimulatorInput(
                      context,
                      label: "Minutes",
                      value: controller.simDurationMinutes,
                    ),
                  ),
                ],
              );
            } else {
              return Row(
                children: [
                  Expanded(
                    child: _buildSimulatorInput(
                      context,
                      label: "Hours",
                      value: controller.simDurationHours,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildSimulatorInput(
                      context,
                      label: "Minutes",
                      value: controller.simDurationMinutes,
                    ),
                  ),
                ],
              );
            }
          }),

          SizedBox(height: 24.h),
          Divider(color: colorScheme.outline),
          SizedBox(height: 12.h),

          // Result
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Estimated Total:",
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Obx(
                () => Text(
                  AFormatter.formatCurrency(controller.simulatedPrice.value),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatorInput(
    BuildContext context, {
    required String label,
    required RxInt value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 4.h),
        TextFormField(
          key: ValueKey('${label}_${value.value}'), // Force rebuild on reset
          initialValue: value.value.toString(),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.all(12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
          ),
          onChanged: (val) {
            if (val.isNotEmpty) {
              value.value = int.tryParse(val) ?? 0;
            }
          },
        ),
      ],
    );
  }
}
