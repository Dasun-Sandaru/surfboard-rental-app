import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/agreement_controller.dart';

class StepDamageFees extends GetView<AgreementController> {
  const StepDamageFees({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: ListView(
        children: [
          Text(
            "Damage Policy",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Select damage fees to include in the agreement. Replacement costs will be charged if items are damaged.",
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 24.h),

          // Dynamic List of Damage Fees
          Obx(
            () => controller.availableDamageFees.isEmpty
                ? Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "No damage fees available for this item.",
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  )
                : Column(
                    children: controller.availableDamageFees.map((fee) {
                      final isSelected =
                          controller.selectedDamageFees[fee.id] ?? false;

                      return Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? colorScheme.primary
                                : colorScheme.outline,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Header Row: Name and Toggle
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        fee.damageType,
                                        style: TextStyle(
                                          color: colorScheme.onSurface,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (fee.description.isNotEmpty)
                                        SizedBox(height: 4.h),
                                      if (fee.description.isNotEmpty)
                                        Text(
                                          fee.description,
                                          style: TextStyle(
                                            color: colorScheme.onSurfaceVariant,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: isSelected,
                                  onChanged: (val) {
                                    controller.toggleDamageFee(fee.id!, val);
                                  },
                                  activeColor: colorScheme.primary,
                                ),
                              ],
                            ),
                            // Price Row
                            Divider(color: colorScheme.outline),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Replacement Cost:",
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Text(
                                  "\$${fee.feeAmount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),

          // Button outside Obx to avoid build phase issues
          Obx(
            () => controller.availableDamageFees.isEmpty
                ? Column(
                    children: [
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            Get.toNamed(
                              Routes.ITEM_DETAILS,
                              arguments: {'itemId': controller.board?.id},
                            );
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          elevation: 0,
                        ),
                        child: Text("Add Damage Fees"),
                      ),
                    ],
                  )
                : SizedBox.shrink(),
          ),
          SizedBox(height: 24.h),

          // Total Damage Fees Summary
          Obx(() {
            final total = controller.getTotalDamageFees();
            return Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.primary),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Damage Fees:",
                    style: TextStyle(
                      color: colorScheme.onPrimaryContainer,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "\$${total.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
