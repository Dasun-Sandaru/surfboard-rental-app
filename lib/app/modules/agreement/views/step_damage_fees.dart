import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';
import '../controllers/agreement_controller.dart';

class StepDamageFees extends GetView<AgreementController> {
  const StepDamageFees({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: ListView(
        children: [
          Text(
            "Damage Policy",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Select damage fees to include in the agreement. Replacement costs will be charged if items are damaged.",
            style: TextStyle(color: Colors.grey, fontSize: 14.sp),
          ),
          SizedBox(height: 24.h),

          // Dynamic List of Damage Fees
          Obx(
            () => controller.availableDamageFees.isEmpty
                ? Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF182c30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        "No damage fees available for this item.",
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
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
                          color: const Color(0xFF182c30),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF4A90E2)
                                : const Color(0xFF334155),
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
                                          color: Colors.white,
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
                                            color: Colors.grey,
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
                                  activeColor: const Color(0xFF4A90E2),
                                ),
                              ],
                            ),
                            // Price Row
                            Divider(color: const Color(0xFF334155)),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Replacement Cost:",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                Text(
                                  "\$${fee.feeAmount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: Colors.white,
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
                          Get.toNamed(
                            Routes.ITEM_DETAILS,
                            arguments: {'itemId': controller.board?.id},
                          );
                        },
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
                color: const Color(0xFF0f3a3f),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF4A90E2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Total Damage Fees:",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "\$${total.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: const Color(0xFF4A90E2),
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
