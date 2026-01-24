import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';
import '../../../../utils/constants/a_enums.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../controllers/rental_payment_controller.dart';

class RentalPaymentView extends StatelessWidget {
  const RentalPaymentView({super.key});

  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22);
  final Color cardDark = const Color(0xFF182c30);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color borderDark = const Color(0xFF334155);
  final Color warningYellow = const Color(0xFFFFC107);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RentalPaymentController());

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "Payment Summary",
          style: TextStyle(
            color: textWhite,
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
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderDark),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28.w,
                          backgroundImage: NetworkImage(
                            controller.customerImage,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              controller.customerName,
                              style: TextStyle(
                                color: textWhite,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              "Rental #${controller.rentalId}",
                              style: TextStyle(
                                color: textGrey,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  /// 2. Payment Summary Card
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: borderDark),
                    ),
                    child: Column(
                      children: [
                        _buildFeeRow(
                          "Remaining Rental Fee",
                          controller.rentalFee.value,
                          Iconsax.receipt,
                          textGrey,
                        ),
                        SizedBox(height: 16.h),

                        _buildFeeRow(
                          "Late Fee",
                          controller.lateFee.value,
                          Iconsax.clock,
                          warningYellow,
                        ),
                        SizedBox(height: 16.h),

                        _buildFeeRow(
                          "Damage Fee",
                          controller.damageFee.value,
                          Iconsax.setting_2, // Or Tool icon
                          warningYellow,
                        ),

                        SizedBox(height: 16.h),
                        Divider(color: borderDark),
                        SizedBox(height: 16.h),

                        // Total Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Final Total",
                              style: TextStyle(
                                color: textWhite,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "\$${controller.totalAmount.toStringAsFixed(2)}",
                              style: TextStyle(
                                color: textWhite,
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24.h),

                  /// 3. Payment History List
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Payment History",
                      style: TextStyle(
                        color: textWhite,
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
                              color: borderDark,
                            ),
                            SizedBox(height: 12.h),
                            Text(
                              "No payments recorded yet",
                              style: TextStyle(
                                color: textGrey,
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

                        return Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: cardDark,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: borderDark),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: isRefund
                                      ? Colors.green.withOpacity(0.1)
                                      : primaryBlue.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isRefund
                                      ? Iconsax.money_send
                                      : Iconsax.money_recive,
                                  color: isRefund ? Colors.green : primaryBlue,
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
                                        color: textWhite,
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      "${payment.method.name.capitalizeFirst} • ${payment.timestamp.toString().substring(0, 10)}",
                                      style: TextStyle(
                                        color: textGrey,
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
                                          ? Colors.green
                                          : textWhite,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (payment.note != null) ...[
                                    SizedBox(height: 4.h),
                                    Text(
                                      payment.note!,
                                      style: TextStyle(
                                        color: textGrey,
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
              color: bgDark,
              border: Border(top: BorderSide(color: borderDark)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: controller.collectPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
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
                    color: textWhite,
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
    String label,
    double amount,
    IconData icon,
    Color iconColor,
  ) {
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
              style: TextStyle(color: textGrey, fontSize: 14.sp),
            ),
          ],
        ),
        Text(
          "\$${amount.toStringAsFixed(2)}",
          style: TextStyle(
            color: textWhite,
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
