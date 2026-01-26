import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/rental_payment_controller.dart';
import '../../../../utils/constants/a_enums.dart';

class CollectPaymentTip extends StatelessWidget {
  final RentalPaymentController controller;

  const CollectPaymentTip({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    // Use Scaffold backgroundColor for overlay effect
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.8),
      body: Center(
        child: Container(
          width: 340.w,
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: const Color(0xFF182c30),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF334155)),
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
                  color: const Color(0xFF4A90E2).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.receipt,
                  size: 32.w,
                  color: const Color(0xFF4A90E2),
                ),
              ),
              SizedBox(height: 16.h),

              // Title
              Text(
                "Collect Payment",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                "Final settlement breakdown",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: const Color(0xFF94a3b8),
                  fontSize: 14.sp,
                ),
              ),

              SizedBox(height: 24.h),

              // Breakdown List
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF101f22),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      "Rental Fee",
                      "\$${controller.rentalFee.toStringAsFixed(2)}",
                    ),
                    SizedBox(height: 8.h),
                    _buildDetailRow(
                      "Late Fee",
                      "\$${controller.lateFee.toStringAsFixed(2)}",
                      color: const Color(0xFFFFC107),
                    ),
                    SizedBox(height: 8.h),
                    _buildDetailRow(
                      "Damage Fee",
                      "\$${controller.damageFee.toStringAsFixed(2)}",
                      color: const Color(0xFFFFC107),
                    ),
                    SizedBox(height: 12.h),
                    Divider(color: const Color(0xFF334155)),
                    SizedBox(height: 12.h),
                    _buildDetailRow(
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
                  color: const Color(0xFFFFC107).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFC107).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Iconsax.info_circle,
                      color: const Color(0xFFFFC107),
                      size: 20.w,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: const Color(0xFFf0f4f4),
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A90E2),
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
                        side: const BorderSide(color: Color(0xFF334155)),
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          color: const Color(0xFF94a3b8),
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
                        backgroundColor: const Color(0xFF4A90E2),
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
                          color: Colors.white,
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
    String label,
    String value, {
    bool isTotal = false,
    Color? color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isTotal ? Colors.white : const Color(0xFF94a3b8),
            fontSize: isTotal ? 16.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? (isTotal ? const Color(0xFF4A90E2) : Colors.white),
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

      // 2. Finalize Return (update inventory etc)
      if (controller.rental.value?.itemId != null) {
        await controller.rentalService.finalizeReturn(
          controller.shopId,
          controller.rentalId,
          controller.rental.value!.itemId,
        );
      }

      Get.back(); // Close Payment Screen
      Get.back(); // Close Inspection Screen

      Get.snackbar(
        "Success",
        "Payment collected & Rental Closed",
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      Get.snackbar("Error", "Payment failed: $e");
    }
  }
}
