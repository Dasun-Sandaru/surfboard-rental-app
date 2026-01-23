import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart'; // Ensure intl package is added
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../controllers/board_inspection_controller.dart';

class BoardInspectionView extends StatelessWidget {
  const BoardInspectionView({super.key});

  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22);
  final Color cardDark = const Color(0xFF182c30);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color borderDark = const Color(0xFF334155);
  final Color successGreen = const Color(0xFF34C759);
  final Color warningYellow = const Color(0xFFFFC107);
  final Color errorRed = const Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BoardInspectionController());

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "Board Inspection",
          style: TextStyle(color: textWhite, fontSize: 18.sp),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ASizes.defaultPadding),
              child: Obx(() {
                final rental = controller.rental.value;
                return Column(
                  children: [
                    // Show real Time Remaining / Overdue Card
                    Obx(() {
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: controller.timeColor.value.withOpacity(0.5)),
                          boxShadow: [
                            BoxShadow(
                              color: controller.timeColor.value.withOpacity(0.1),
                              blurRadius: 10,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controller.timeLabel.value,
                              style: TextStyle(color: textWhite, fontSize: 16.sp),
                            ),
                            Text(
                              controller.timeRemaining.value,
                              style: TextStyle(
                                color: controller.timeColor.value,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    SizedBox(height: 24.h),

                    // 1. Item Details Card
                    _buildSectionCard(
                      title: "Item Details",
                      children: [
                        _buildDetailRow("Board ID", rental.itemId),
                        _buildDetailRow("Rate", "\$${rental.rate}/hr"),
                        _buildDetailRow(
                          "Start Time",
                          DateFormat(
                            'dd MMM, hh:mm a',
                          ).format(rental.startTime),
                          isLast: true,
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    // 2. Financial Summary (NEW SECTION)
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: cardDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderDark),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Iconsax.wallet_money,
                                color: primaryBlue,
                                size: 20.w,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Payment Status",
                                style: TextStyle(
                                  color: textWhite,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // Rows
                          _buildFinanceRow(
                            "Total Expected",
                            rental.amountExpected,
                            textGrey,
                          ),
                          _buildFinanceRow(
                            "Amount Paid",
                            rental.amountPaid,
                            successGreen,
                          ),
                          Divider(color: borderDark, height: 24.h),

                          // Dynamic Balance Display
                          Builder(
                            builder: (context) {
                              double balance = controller.balanceDue;
                              String label = balance > 0
                                  ? "Customer Owes"
                                  : (balance < 0 ? "Refund Due" : "Settled");
                              Color color = balance > 0
                                  ? errorRed
                                  : (balance < 0 ? warningYellow : textGrey);

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    label,
                                    style: TextStyle(
                                      color: textWhite,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  Text(
                                    "\$${balance.abs().toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: color,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20.sp,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),

                          // Deposit Indicator
                          SizedBox(height: 12.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: bgDark,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Security Deposit Held",
                                  style: TextStyle(
                                    color: textGrey,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                Text(
                                  "\$${rental.securityDeposit.amount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                    color: textWhite,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // 3. Rental Summary Card
                    _buildSectionCard(
                      title: "Rental Summary",
                      children: [
                        _buildIconRow(
                          Iconsax.user,
                          "Customer ID:",
                          rental.customerId,
                        ),
                        SizedBox(height: 16.h),
                        _buildIconRow(
                          Iconsax.receipt,
                          "Rental ID:",
                          rental.id ?? "N/A",
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),

          // 4. Bottom Action Buttons
          Container(
            padding: EdgeInsets.all(ASizes.defaultPadding),
            decoration: BoxDecoration(
              color: bgDark,
              border: Border(top: BorderSide(color: borderDark)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: controller.reportDamage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: warningYellow,
                        foregroundColor: Colors.black87,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        "Damage Found",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 54.h,
                    child: ElevatedButton(
                      onPressed: controller.reportNoDamage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        "Confirm Return",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: textWhite,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderDark.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: textWhite,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: borderDark)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: textGrey, fontSize: 14.sp),
          ),
          Text(
            value,
            style: TextStyle(
              color: textWhite,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinanceRow(String label, double amount, Color valueColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: textGrey, fontSize: 14.sp),
          ),
          Text(
            "\$${amount.toStringAsFixed(2)}",
            style: TextStyle(
              color: valueColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: textGrey, size: 20.w),
        SizedBox(width: 12.w),
        Text(
          label,
          style: TextStyle(color: textGrey, fontSize: 14.sp),
        ),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyle(
            color: textWhite,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
