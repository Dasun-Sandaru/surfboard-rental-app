import 'package:flutter/material.dart';
import 'package:surfboard_rental_app/utils/common/app_snack_bar.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/rental_payment_controller.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../../utils/theme/app_material_theme.dart';

class CollectPaymentTip extends StatelessWidget {
  final RentalPaymentController controller;

  const CollectPaymentTip({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>();
    // Use Scaffold backgroundColor for overlay effect
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Center(
        child: Container(
          width: 340.w,
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.outline),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Icon
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.receipt,
                  size: 32.w,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 16.h),

              // Title
              Text(
                "Collect Payment",
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Final settlement breakdown",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 14.sp,
                ),
              ),

              SizedBox(height: 24.h),

              // Breakdown List
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      "Rental Fee",
                      "\$${controller.rentalFee.toStringAsFixed(2)}",
                    ),
                    SizedBox(height: 8.h),
                    _buildDetailRow(
                      context,
                      "Late Fee",
                      "\$${controller.lateFee.toStringAsFixed(2)}",
                      color: statusColors?.warning,
                    ),
                    SizedBox(height: 8.h),
                    _buildDetailRow(
                      context,
                      "Damage Fee",
                      "\$${controller.damageFee.toStringAsFixed(2)}",
                      color: statusColors?.error ?? Colors.red,
                    ),
                    SizedBox(height: 12.h),
                    Divider(color: colorScheme.outline),
                    SizedBox(height: 12.h),
                    _buildDetailRow(
                      context,
                      "Total Due",
                      "\$${controller.totalAmount.toStringAsFixed(2)}",
                      isTotal: true,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Tip Box
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: (statusColors?.warning ?? Colors.orange).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (statusColors?.warning ?? Colors.orange).withOpacity(
                      0.3,
                    ),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Iconsax.info_circle,
                      color: statusColors?.warning,
                      size: 20.w,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 13.sp,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: "Tip: Keep the "),
                            TextSpan(
                              text:
                                  "\$${controller.rental.value?.securityDeposit.amount.toStringAsFixed(2) ?? '0.00'}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const TextSpan(
                              text:
                                  " security deposit and collect the remaining ",
                            ),
                            TextSpan(
                              text:
                                  "\$${(controller.totalAmount - (controller.rental.value?.securityDeposit.amount ?? 0)).toStringAsFixed(2)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                            const TextSpan(text: " from the customer."),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: colorScheme.outline),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Get.back(); // Handled in controller if needed, or here?
                        // Controller logic calls Get.back() inside _processPayment usually
                        _processPayment();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        "Collect",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
    Color? color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal
                ? colorScheme.onSurface
                : colorScheme.onSurfaceVariant,
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color:
                color ??
                (isTotal ? colorScheme.primary : colorScheme.onSurface),
            fontSize: isTotal ? 20.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment() async {
    try {
      // 1. Add Payment Record
      await controller.paymentService.addPayment(
        shopId: controller.shopId,
        rentalId: controller.rentalId,
        category: PaymentCategory.rental,
        amount: controller.totalAmount,
        handledBy: controller.userService.currentUser?.uid ?? 'Staff',
        method: PaymentMethod.cash,
      );

      // 2. Determine inventory status based on damage
      // If there are damage fees, mark the board as damaged
      final bool hasDamage = controller.damageFee > 0;
      final InventoryStatus inventoryStatus = hasDamage
          ? InventoryStatus.mark_as_damaged
          : InventoryStatus.available;

      // 3. Finalize Return (update rental to completed and inventory status)
      if (controller.rental.value?.itemId != null) {
        await controller.rentalService.finalizeReturn(
          shopId: controller.shopId,
          rentalId: controller.rentalId,
          itemId: controller.rental.value!.itemId,
          status: RentalStatus.completed,
          inventoryStatus: inventoryStatus,
        );
      }

      Get.back(); // Close Payment Screen
      Get.back(); // Close Rental Payment Screen

      AppSnackBar.success(
        title: "Success",
        message: hasDamage
            ? "Payment collected. Board marked as damaged."
            : "Payment collected & Rental Closed",
      );
    } catch (e) {
      AppSnackBar.error(title: "Error", message: "Payment failed: $e");
    }
  }
}
