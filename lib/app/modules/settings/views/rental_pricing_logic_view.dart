import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/app/services/config_service.dart';
import 'package:surfboard_rental_app/utils/common/a_app_bar.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../controllers/settings_controller.dart';

class RentalPricingLogicView extends GetView<SettingsController> {
  const RentalPricingLogicView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ConfigService configService = Get.find<ConfigService>();

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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        child: Column(
          children: [
            _buildExplanationCard(
              context,
              title: "Hourly Grace Period",
              description:
                  "The grace period allowed after an hour has passed before charging for the next hour.",
              example:
                  "Example: If set to 15 minutes.\nRent Start: 10:00 AM\nReturn: 11:14 AM -> Charged for 1 Hour\nReturn: 11:16 AM -> Charged for 2 Hours",
              child: Obx(
                () => _buildNumberInput(
                  context,
                  label: "Minutes",
                  value: configService.hourlyGracePeriodMinutes.value,
                  onChanged: (val) {
                    controller.updateConfig(newHourlyGrace: val);
                  },
                ),
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
              child: Obx(
                () => _buildNumberInput(
                  context,
                  label: "Hours",
                  value: configService.dailyGracePeriodHours.value,
                  onChanged: (val) {
                    controller.updateConfig(newDailyGrace: val);
                  },
                ),
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      value: configService.isTaxEnabled.value,
                      onChanged: (val) {
                        controller.updateConfig(newIsTaxEnabled: val);
                      },
                      activeColor: colorScheme.primary,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(
                    () => _buildNumberInput(
                      context,
                      label: "Tax Rate (%)",
                      value: configService.taxRate.value,
                      isDouble: true,
                      onChanged: (val) {
                        controller.updateConfig(newTaxRate: val.toDouble());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
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
              color: colorScheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
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

  Widget _buildNumberInput(
    BuildContext context, {
    required String label,
    required num value,
    required Function(dynamic) onChanged,
    bool isDouble = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          "$label:",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value.toString(),
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                InkWell(
                  onTap: () {
                    // Simple decrement
                    if (value > 0) {
                      onChanged(isDouble ? value - 0.5 : value - 1);
                    }
                  },
                  child: Icon(Icons.remove, size: 20.sp),
                ),
                SizedBox(width: 8.w),
                InkWell(
                  onTap: () {
                    // Simple increment
                    onChanged(isDouble ? value + 0.5 : value + 1);
                  },
                  child: Icon(Icons.add, size: 20.sp),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
