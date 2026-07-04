import 'package:flutter/material.dart';
import '../../../../utils/common/app_snack_bar.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../routes/app_pages.dart';
import '../controllers/rental_payment_controller.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../../utils/theme/app_material_theme.dart';
import 'customer_rating_dialog.dart';
import '../../../../utils/helper/a_formatter.dart';

class CollectPaymentTip extends StatefulWidget {
  final RentalPaymentController controller;

  const CollectPaymentTip({super.key, required this.controller});

  @override
  State<CollectPaymentTip> createState() => _CollectPaymentTipState();
}

class _CollectPaymentTipState extends State<CollectPaymentTip> {
  final ValueNotifier<bool> _isProcessing = ValueNotifier(false);

  RentalPaymentController get controller => widget.controller;

  @override
  void dispose() {
    _isProcessing.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>();

    return Obx(() {
      final rental = controller.rental.value;
      if (rental == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final double balance = controller.totalAmount;
      final double deposit = controller.depositHeld;
      final double netCollect = controller.netCashToCollect;

      return Scaffold(
        backgroundColor: Colors.black.withValues(alpha: 0.8),
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
                  color: Colors.black.withValues(alpha: 0.5),
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
                    color: colorScheme.primary.withValues(alpha: 0.1),
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
                  "collect_payment".tr,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "final_settlement".tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14.sp,
                  ),
                ),

                SizedBox(height: 20.h),

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
                        "rentals".tr,
                        AFormatter.formatCurrency(controller.rentalFee, currencyCodeOverride: rental.currency),
                      ),
                      if (controller.lateFee > 0) ...[
                        SizedBox(height: 8.h),
                        _buildDetailRow(
                          context,
                          "late_fee".tr,
                          AFormatter.formatCurrency(controller.lateFee, currencyCodeOverride: rental.currency),
                          color: statusColors?.warning,
                        ),
                      ],
                      if (controller.damageFee > 0) ...[
                        SizedBox(height: 8.h),
                        _buildDetailRow(
                          context,
                          "damage_fee".tr,
                          AFormatter.formatCurrency(controller.damageFee, currencyCodeOverride: rental.currency),
                          color: statusColors?.error,
                        ),
                      ],
                      if (controller.totalPaid > 0) ...[
                        SizedBox(height: 8.h),
                        _buildDetailRow(
                          context,
                          "amount_paid".tr,
                          "-${AFormatter.formatCurrency(controller.totalPaid, currencyCodeOverride: rental.currency)}",
                          color: Colors.green,
                        ),
                      ],
                      SizedBox(height: 12.h),
                      Divider(color: colorScheme.outline, thickness: 1),
                      SizedBox(height: 12.h),
                      _buildDetailRow(
                        context,
                        "total_due".tr,
                        AFormatter.formatCurrency(balance, currencyCodeOverride: rental.currency),
                        isTotal: true,
                      ),
                      if (deposit > 0) ...[
                        SizedBox(height: 12.h),
                        _buildDetailRow(
                          context,
                          "${"security_deposit".tr} (${"held".tr})",
                          "-${AFormatter.formatCurrency(deposit, currencyCodeOverride: rental.currency)}",
                          color: colorScheme.secondary,
                        ),
                        SizedBox(height: 12.h),
                        _buildDetailRow(
                          context,
                          netCollect >= 0 ? "To Collect" : "To Refund",
                          AFormatter.formatCurrency(netCollect.abs(), currencyCodeOverride: rental.currency),
                          isTotal: true,
                          color: netCollect >= 0
                              ? colorScheme.primary
                              : Colors.orange,
                        ),
                      ],
                    ],
                  ),
                ),

                SizedBox(height: 20.h),

                // Dynamic Tip Box
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: (statusColors?.warning ?? Colors.orange).withValues(
                      alpha: 0.1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (statusColors?.warning ?? Colors.orange)
                          .withValues(alpha: 0.3),
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
                        child: Text(
                          _getTipMessage(balance, deposit, netCollect, rental.currency),
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 13.sp,
                            height: 1.4,
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
                          "cancel".tr,
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
                      child: ValueListenableBuilder<bool>(
                        valueListenable: _isProcessing,
                        builder: (context, isProcessing, _) {
                          return ElevatedButton(
                            onPressed: isProcessing ? null : _processPayment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                              disabledBackgroundColor: colorScheme.primary
                                  .withValues(alpha: 0.5),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: isProcessing
                                ? SizedBox(
                                    height: 20.w,
                                    width: 20.w,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: colorScheme.onPrimary,
                                    ),
                                  )
                                : Text(
                                    balance > 0
                                        ? "collect_payment".tr
                                        : "complete".tr,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  String _getTipMessage(double balance, double deposit, double netCollect, String? currency) {
    if (deposit > 0) {
      if (netCollect > 0) {
        return "Keep the full ${AFormatter.formatCurrency(deposit, currencyCodeOverride: currency)} deposit and collect an additional ${AFormatter.formatCurrency(netCollect, currencyCodeOverride: currency)} in cash.";
      } else if (netCollect < 0) {
        return "Apply ${AFormatter.formatCurrency(balance, currencyCodeOverride: currency)} from the deposit to cover the balance, and refund the remaining ${AFormatter.formatCurrency(netCollect.abs(), currencyCodeOverride: currency)} to the customer.";
      } else {
        return "The security deposit of ${AFormatter.formatCurrency(deposit, currencyCodeOverride: currency)} exactly covers the remaining balance. No additional payment needed.";
      }
    } else {
      if (balance > 0) {
        return "Collect ${AFormatter.formatCurrency(balance, currencyCodeOverride: currency)} in cash from the customer.";
      } else if (balance < 0) {
        return "Refund ${AFormatter.formatCurrency(balance.abs(), currencyCodeOverride: currency)} to the customer.";
      } else {
        return "All payments are settled. No additional collection required.";
      }
    }
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
    if (_isProcessing.value) return; // Prevent double-tap
    _isProcessing.value = true;

    try {
      final double totalBalance = controller.totalBalance;
      final double deposit = controller.depositHeld;
      final double netCash = controller.netCashToCollect;

      // Fetch Staff name
      final staffUser = await controller.userService.getUser(
        controller.userService.currentUid ?? "",
      );
      final staffName = staffUser?.name ?? 'Staff';

      // Calculate how much of the deposit covers the balance
      final double depositApplied = totalBalance > 0
          ? (totalBalance < deposit ? totalBalance : deposit)
          : 0.0;

      // Calculate the refund (remaining deposit after covering balance)
      final double refundAmount = (deposit - totalBalance).clamp(0.0, deposit);

      // 1. Record ONLY actual cash collection (real money changing hands)
      if (netCash > 0) {
        await controller.paymentService.addPayment(
          shopId: controller.shopId,
          rentalId: controller.rentalId,
          category: PaymentCategory.partialPayment,
          amount: netCash,
          handledBy: staffName,
          method: PaymentMethod.cash,
          note: "Cash collected at settlement",
        );
      }

      // 2. Record refund if deposit exceeds the balance (real money handed back)
      if (refundAmount > 0) {
        await controller.paymentService.addPayment(
          shopId: controller.shopId,
          rentalId: controller.rentalId,
          category: PaymentCategory.refund,
          amount: refundAmount,
          handledBy: staffName,
          method: PaymentMethod.cash,
          note:
              "Deposit held: ${AFormatter.formatCurrency(deposit)}, "
              "Applied to balance: ${AFormatter.formatCurrency(depositApplied)}, "
              "Refunded: ${AFormatter.formatCurrency(refundAmount)}",
        );
      }

      // 3. Settle the rental balance directly
      // This applies the deposit towards amountPaid without creating a fake payment entry.
      // depositApplied is an internal transfer, not new cash, so we just update the rental fields.
      await controller.rentalService.settleRentalBalance(
        shopId: controller.shopId,
        rentalId: controller.rentalId,
        depositApplied: depositApplied,
        refundedAmount: refundAmount,
      );

      // 4. Determine inventory status based on damage
      final bool hasDamage = controller.damageFee > 0;
      final InventoryStatus inventoryStatus = hasDamage
          ? InventoryStatus.damaged
          : InventoryStatus.available;

      // 5. Finalize Return (Updates Rental Status)
      if (controller.rental.value?.itemId != null) {
        await controller.rentalService.finalizeReturn(
          shopId: controller.shopId,
          rentalId: controller.rentalId,
          itemId: controller.rental.value!.itemId,
          status: RentalStatus.completed,
          inventoryStatus: inventoryStatus,
        );
      }

      if (!mounted) return;

      // 6. Show Rating Dialog
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => CustomerRatingDialog(
          customerName: controller.customerName,
          onSubmit: (rating, comment) {
            controller.submitRating(rating, comment);
          },
        ),
      );

      // 7. Success & Navigation
      Get.offAllNamed(Routes.ADMIN_HOME);

      AppSnackBar.success(
        title: "success".tr,
        message: totalBalance > 0
            ? "payment_collected_finalized".tr
            : "rental_concluded_successfully".tr,
      );
    } catch (e) {
      _isProcessing.value = false;
      AppSnackBar.error(title: 'error'.tr, message: 'payment_failed'.trParams({'error': e.toString()}));
    }
  }
}
