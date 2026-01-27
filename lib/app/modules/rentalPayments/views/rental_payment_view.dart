import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';
import '../../../../utils/constants/a_enums.dart';

import 'package:surfboard_rental_app/utils/theme/app_material_theme.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../controllers/rental_payment_controller.dart';

class RentalPaymentView extends StatelessWidget {
  const RentalPaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RentalPaymentController());
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "Payment Summary",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ASizes.defaultPadding),
              child: Column(
                children: [
                  /// 1. Customer Card
                  Obx(
                    () => Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 28.w,
                            backgroundImage: NetworkImage(
                              controller.customerImage,
                            ),
                            onBackgroundImageError: (exception, stackTrace) {
                              // Fallback handled by using a default icon over it or just plain color
                            },
                            child: controller.customerImage.isEmpty
                                ? Icon(
                                    Iconsax.user,
                                    color: colorScheme.onSurface,
                                  )
                                : null,
                          ),
                          SizedBox(width: 16.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: controller.goToCustomerDetails,
                                child: Text(
                                  controller.customerName,
                                  style: TextStyle(
                                    color: colorScheme.primary,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "Rental #${controller.rentalId}",
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 14.sp,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  /// 2. Payment Summary Card
                  Obx(
                    () => Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainer,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colorScheme.outline),
                      ),
                      child: Column(
                        children: [
                          _buildFeeRow(
                            context,
                            "Remaining Rental Fee",
                            controller.rentalFee,
                            Iconsax.receipt,
                            colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(height: 16.h),

                          _buildFeeRow(
                            context,
                            "Late Fee",
                            controller.lateFee,
                            Iconsax.clock,
                            statusColors?.warning ?? Colors.orange,
                          ),
                          SizedBox(height: 16.h),

                          _buildFeeRow(
                            context,
                            "Damage Fee",
                            controller.damageFee,
                            Iconsax.setting_2, // Or Tool icon
                            statusColors?.warning ?? Colors.orange,
                          ),

                          SizedBox(height: 16.h),
                          Divider(color: colorScheme.outline),
                          SizedBox(height: 16.h),

                          // Total Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Final Total",
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "\$${controller.totalAmount.toStringAsFixed(2)}",
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  /// 3. Payment History List
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Payment History",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),

                  Obx(() {
                    if (controller.payments.isEmpty) {
                      return Center(
                        child: Column(
                          children: [
                            SizedBox(height: 24.h),
                            Icon(
                              Iconsax.receipt,
                              size: 48.w,
                              color: colorScheme.outline,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              "No payments recorded yet",
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.payments.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final payment = controller.payments[index];
                        final isRefund =
                            payment.category == PaymentCategory.refund;
                        final successColor =
                            statusColors?.success ?? Colors.green;

                        return Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: colorScheme.outline),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: isRefund
                                      ? successColor.withOpacity(0.1)
                                      : colorScheme.primary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isRefund
                                      ? Iconsax.money_send
                                      : Iconsax.money_recive,
                                  color: isRefund
                                      ? successColor
                                      : colorScheme.primary,
                                  size: 20.w,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      payment.category.name.capitalizeFirst ??
                                          payment.category.name,
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      "${payment.method.name.capitalizeFirst} • ${payment.timestamp.toString().substring(0, 10)}",
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${isRefund ? '-' : '+'}\$${payment.amount.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: isRefund
                                          ? successColor
                                          : colorScheme.onSurface,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (payment.note != null) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      payment.note!,
                                      style: TextStyle(
                                        color: colorScheme.onSurfaceVariant,
                                        fontSize: 10.sp,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            ),
          ),

          /// 3. Bottom Action Button
          Container(
            padding: EdgeInsets.all(ASizes.defaultPadding),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(top: BorderSide(color: colorScheme.outline)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: controller.collectPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  "Collect Payment",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildFeeRow(
    BuildContext context,
    String label,
    double amount,
    IconData icon,
    Color iconColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    // Hide row if amount is 0 to keep UI clean
    if (amount <= 0) return const SizedBox.shrink();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: iconColor, size: 20.w),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        Text(
          "\$${amount.toStringAsFixed(2)}",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
