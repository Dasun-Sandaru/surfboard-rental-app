import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/a_enums.dart';
import '../controllers/agreement_controller.dart';

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
              "Rental Details",
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Set the duration and total price.",
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 16.sp,
              ),
            ),

            SizedBox(height: 32.h),

            // Duration Selector
            Text(
              "Duration",
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
                  "No duration data",
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
                              "Start",
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
                              "Due",
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
              "Rental Price",
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
                  "No rental data",
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
                              "Hourly Rate",
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "\$${item.rentalRateHour}",
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
                              "Daily Rate",
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 12.sp,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "\$${item.rentalRateDay}",
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
                              "Duration",
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
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Suggested Price",
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 12.sp,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "\$$suggestedPriceString",
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
                              "Use",
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
              label: "Total Rental Price",
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
                        "Require Security Deposit",
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        "Hold an ID or Cash",
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12.sp,
                        ),
                      ),
                      value: controller.requireDeposit.value,
                      onChanged: (val) => controller.requireDeposit.value = val,
                      activeColor: colorScheme.primary,
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
                            label: "Deposit Amount",
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
            prefixText: "\$ ",
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
