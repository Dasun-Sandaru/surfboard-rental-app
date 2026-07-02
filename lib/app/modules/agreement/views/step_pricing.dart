import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/agreement_controller.dart';
import '../../../../utils/helper/a_formatter.dart';

class StepPricing extends GetView<AgreementController> {
  const StepPricing({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'rental_details'.tr,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'set_duration_price'.tr,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 16.sp,
              ),
            ),

            SizedBox(height: 32.h),

            // Duration Selector
            Text(
              'duration'.tr,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),

            // Display passed duration from InitRentalModel
            Obx(() {
              final rentalData = controller.initRentalModel.value;
              if (rentalData == null) {
                return Text(
                  'no_duration_data'.tr,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                );
              }

              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'start'.tr,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              rentalData.startDateTimeString,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          Iconsax.arrow_right,
                          color: colorScheme.primary,
                          size: 20.w,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'due'.tr,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              rentalData.dueDateTimeString,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(color: colorScheme.outline, height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          controller.formattedDuration,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 32.h),

            // Rental Price Section
            Text(
              'rental_price'.tr,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12.h),

            Obx(() {
              final rentalData = controller.initRentalModel.value;
              if (rentalData == null || rentalData.items.isEmpty) {
                return Text(
                  'no_rental_data'.tr,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                );
              }

              final item = rentalData.items.first;
              final suggestedPriceString = controller.suggestedPrice
                  .toStringAsFixed(2);
              controller.rentalPriceController.text = suggestedPriceString;

              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item Rate Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'hourly_rate'.tr,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              AFormatter.formatCurrency(item.rentalRateHour),
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'daily_rate'.tr,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              AFormatter.formatCurrency(item.rentalRateDay),
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'duration'.tr,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              controller.formattedDuration,
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(color: colorScheme.outline, height: 24.h),
                    // Suggested Price
                    Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'suggested_price'.tr,
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                AFormatter.formatCurrency(controller.suggestedPrice),
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              controller.rentalPriceController.text =
                                  suggestedPriceString;
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'use'.tr,
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),

            SizedBox(height: 16.h),

            // Total Rental Price Input
            _buildMoneyInput(
              context: context,
              label: 'total_rental_price'.tr,
              controller: controller.rentalPriceController,
              icon: Iconsax.money_tick,
            ),

            SizedBox(height: 32.h),

            // Deposit Section
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Column(
                children: [
                  Obx(
                    () => SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'require_security_deposit'.tr,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'hold_id_cash'.tr,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12.sp,
                        ),
                      ),
                      value: controller.requireDeposit.value,
                      onChanged: (val) => controller.requireDeposit.value = val,
                      activeThumbColor: colorScheme.primary,
                    ),
                  ),

                  // Show input only if enabled
                  Obx(() {
                    if (controller.requireDeposit.value) {
                      return Column(
                        children: [
                          Divider(color: colorScheme.outline),
                          SizedBox(height: 12.h),
                          _buildMoneyInput(
                            context: context,
                            label: 'deposit_amount'.tr,
                            controller: controller.depositController,
                            icon: Iconsax.lock,
                          ),
                        ],
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoneyInput({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 14.sp,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: colorScheme.onSurfaceVariant),
            prefixText: "${AFormatter.currencySymbol()} ",
            prefixStyle: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18.sp,
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
            contentPadding: EdgeInsets.symmetric(
              vertical: 16.h,
              horizontal: 16.w,
            ),
          ),
        ),
      ],
    );
  }
}
