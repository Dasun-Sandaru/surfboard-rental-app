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
    final canEdit = controller.hasPermission('settings_edit_rental_logic');

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        title: Text(
          'rental_pricing'.tr,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: canEdit
            ? [
                TextButton(
                  onPressed: controller.saveRentalConfig,
                  child: Text(
                    'save'.tr,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        child: Form(
          key: controller.rentalConfigFormKey,
          child: Column(
            children: [
              _buildExplanationCard(
                context,
                title: 'hourly_grace_period_title'.tr,
                description:
                    'hourly_grace_description'.tr,
                example:
                    'hourly_grace_example'.tr,
                child: _buildTextField(
                  context,
                  controller: controller.hourlyGracePeriodController,
                  label: 'minutes'.tr,
                  hintText: "e.g. 15",
                  icon: Iconsax.clock,
                  inputType: TextInputType.number,
                  enabled: canEdit,
                ),
              ),
              SizedBox(height: 16.h),
              _buildExplanationCard(
                context,
                title: 'daily_grace_period_title'.tr,
                description:
                    'daily_grace_description'.tr,
                example:
                    'daily_grace_example'.tr,
                child: _buildTextField(
                  context,
                  controller: controller.dailyGracePeriodController,
                  label: 'hours'.tr,
                  hintText: "e.g. 1",
                  icon: Iconsax.clock,
                  inputType: TextInputType.number,
                  enabled: canEdit,
                ),
              ),
              SizedBox(height: 16.h),
              _buildExplanationCard(
                context,
                title: 'tax_config'.tr,
                description: 'tax_description'.tr,
                example:
                    'tax_example'.tr,
                child: Column(
                  children: [
                    Obx(
                      () => SwitchListTile(
                        title: Text(
                          'enable_tax_label'.tr,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        value: controller.isTaxEnabled.value,
                        onChanged: canEdit
                            ? (val) => controller.isTaxEnabled.value = val
                            : null,
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
                                label: 'tax_rate'.tr,
                                hintText: "e.g. 5.0",
                                icon: Iconsax.percentage_square,
                                inputType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                enabled: canEdit,
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
    bool enabled = true,
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
          enabled: enabled,
          style: TextStyle(
            color: enabled ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          ),
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
            'pricing_simulator'.tr,
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
                    hintText: 'select_type'.tr,
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
                child: Text('test'.tr),
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
                      label: 'days'.tr,
                      value: controller.simDurationDays,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildSimulatorInput(
                      context,
                      label: 'hours'.tr,
                      value: controller.simDurationHours,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: _buildSimulatorInput(
                      context,
                      label: 'minutes'.tr,
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
                      label: 'hours'.tr,
                      value: controller.simDurationHours,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildSimulatorInput(
                      context,
                      label: 'minutes'.tr,
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
                'estimated_total'.tr,
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
