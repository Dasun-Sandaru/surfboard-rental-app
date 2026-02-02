import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_enums.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/validators/a_validator.dart';
import '../controllers/settings_controller.dart';

class RentalConfigView extends GetView<SettingsController> {
  const RentalConfigView({super.key});

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
          "Rental & Pricing",
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(context, "Default Pricing"),
              SizedBox(height: 12.h),
              _buildTextField(
                context,
                controller: controller.defaultHourlyRateController,
                label: "Default Hourly Rate",
                hintText: "0.00",
                icon: Iconsax.timer_1,
                inputType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    AValidator.validateNumber(value, "Hourly Rate"),
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                context,
                controller: controller.defaultDailyRateController,
                label: "Default Daily Rate",
                hintText: "0.00",
                icon: Iconsax.calendar_1,
                inputType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) =>
                    AValidator.validateNumber(value, "Daily Rate"),
              ),

              SizedBox(height: 16.h),
              _buildTextField(
                context,
                controller: controller.hourlyGracePeriodController,
                label: "Hourly Grace Period (Minutes)",
                hintText: "e.g. 15",
                icon: Iconsax.clock,
                inputType: TextInputType.number,
                validator: (value) =>
                    AValidator.validateNumber(value, "Hourly Grace Period"),
              ),
              SizedBox(height: 16.h),
              _buildTextField(
                context,
                controller: controller.dailyGracePeriodController,
                label: "Daily Grace Period (Hours)",
                hintText: "e.g. 1",
                icon: Iconsax.clock,
                inputType: TextInputType.number,
                validator: (value) =>
                    AValidator.validateNumber(value, "Daily Grace Period"),
              ),

              SizedBox(height: 32.h),
              _buildSectionHeader(context, "Tax & Fees"),
              SizedBox(height: 12.h),

              // Tax Toggle
              Obx(
                () => SwitchListTile(
                  title: Text(
                    "Enable Tax Calculation",
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  value: controller.isTaxEnabled.value,
                  onChanged: (val) => controller.isTaxEnabled.value = val,
                  activeThumbColor: colorScheme.primary,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              SizedBox(height: 8.h),
              Obx(
                () => controller.isTaxEnabled.value
                    ? _buildTextField(
                        context,
                        controller: controller.taxRateController,
                        label: "Tax Rate (%)",
                        hintText: "e.g. 5.0",
                        icon: Iconsax.percentage_square,
                        inputType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) =>
                            AValidator.validateNumber(value, "Tax Rate"),
                      )
                    : SizedBox.shrink(),
              ),

              SizedBox(height: 32.h),

              _buildSectionHeader(context, "Pricing Simulator"),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Test your pricing logic before saving:",
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    // Simulator Controls
                    Row(
                      children: [
                        // Rent Type Dropdown
                        Expanded(
                          child: Obx(
                            () => CustomDropdown<RentType>(
                              hintText: 'Select Type',
                              items: RentType.values,
                              initialItem: controller.simRentType.value,
                              onChanged: (val) {
                                if (val != null) {
                                  controller.simRentType.value = val;
                                }
                              },

                              decoration: CustomDropdownDecoration(
                                closedFillColor: colorScheme.surface,
                                expandedFillColor: colorScheme.surface,
                                closedBorder: Border.all(
                                  color: colorScheme.outline,
                                ),
                                closedBorderRadius: BorderRadius.circular(8),
                              ),
                              listItemBuilder:
                                  (context, item, isSelected, onItemSelect) {
                                    return Text(item.name.capitalizeFirst!);
                                  },
                              headerBuilder: (context, selectedItem, enabled) {
                                return Text(selectedItem.name.capitalizeFirst!);
                              },
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        // Calculate Button
                        ElevatedButton(
                          onPressed: () {
                            if (controller.rentalConfigFormKey.currentState!
                                .validate()) {
                              controller.calculateSimulatedPrice();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 24,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text("Calculate"),
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
                                label: "Extra Hours",
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
                          "Simulated Price:",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Obx(
                          () => Text(
                            "${controller.currency.value} ${controller.simulatedPrice.value.toStringAsFixed(2)}",
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
              ),
              SizedBox(height: 40.h), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimulatorInput(
    BuildContext context, {
    required String label,
    required RxInt value,
  }) {
    // Helper to build small number inputs for simulator
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
          initialValue: value.value.toString(),
          keyboardType: TextInputType.number,
          validator: (val) => AValidator.validateNumber(val, label),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.all(12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            fillColor: Theme.of(context).colorScheme.surface,
            filled: true,
          ),
          onChanged: (val) {
            // Only update if valid number
            if (val.isNotEmpty) {
              value.value = int.tryParse(val) ?? 0;
            }
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.primary,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
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
    String? Function(String?)? validator,
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
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant),
            filled: true,
            fillColor: colorScheme.surfaceContainer,
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
}
