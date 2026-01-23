import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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
          "Inspection & Return",
          style: TextStyle(
            color: textWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: StreamBuilder<dynamic>(
        stream: controller.rentalStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No rental data found.'));
          }

          final rental = snapshot.data!;

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(ASizes.defaultPadding),
                  child: Column(
                    children: [
                      // Show real Time Remaining / Overdue Card
                      Obx(() {
                        return Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: cardDark,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: controller.timeColor.value.withOpacity(0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: controller.timeColor.value.withOpacity(
                                  0.1,
                                ),
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

                      /// 2. Vital Return Info (Deposit & Balance)
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: cardDark,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryBlue.withOpacity(0.5)),
                        ),
                        child: Obx(
                          () => Column(
                            children: [
                              _buildHighlightRow(
                                "Security Deposit",
                                "\$${rental.securityDeposit.amount.toStringAsFixed(2)}",
                                Iconsax.lock,
                                warningYellow,
                              ),
                              Divider(color: borderDark, height: 24.h),
                              _buildHighlightRow(
                                "Balance Due",
                                "\$${controller.balanceDue.toStringAsFixed(2)}",
                                Iconsax.money_tick,
                                controller.balanceDue > 0 ? errorRed : successGreen,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      /// 3. Rental Details (From Model)
                      _buildSectionCard(
                        title: "Rental Details",
                        children: [
                          _buildDetailRow("Rental ID", rental.id ?? "N/A"),
                          Obx(() => _buildDetailRow("Customer", controller.customerName)),
                          Obx(() => _buildDetailRow("Item", controller.boardName)),
                          _buildDetailRow(
                            "Start Time",
                            rental.startTime.toString(),
                          ),
                          _buildDetailRow(
                            "Expected Return",
                            rental.expectedReturnTime.toString(),
                          ),
                          _buildDetailRow(
                            "Rate",
                            "\$${rental.rate}/hr",
                            isLast: true,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              /// 4. Action Footer
              Container(
                padding: EdgeInsets.all(ASizes.defaultPadding),
                decoration: BoxDecoration(
                  color: bgDark,
                  border: Border(top: BorderSide(color: borderDark)),
                ),
                child: Column(
                  children: [
                    // No Damage Button
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: controller.reportNoDamage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.tick_circle, color: textWhite),
                            SizedBox(width: 8.w),
                            Text(
                              "Confirm Return (No Damage)",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: textWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // Report Damage Button
                    SizedBox(
                      width: double.infinity,
                      height: 54.h,
                      child: ElevatedButton(
                        onPressed: controller.reportDamage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: cardDark,
                          foregroundColor: warningYellow,
                          side: BorderSide(color: warningYellow),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Iconsax.warning_2, size: 20.w),
                            SizedBox(width: 8.w),
                            Text(
                              "Report Damage",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

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

  // Highlight Row for Deposit and Payment
  Widget _buildHighlightRow(
    String label,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: bgDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: textGrey, size: 20.w),
            ),
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(color: textGrey, fontSize: 14.sp),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: accentColor,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isLast = false,
    Color? valueColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: borderDark.withOpacity(0.5)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(color: textGrey, fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? textWhite,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
