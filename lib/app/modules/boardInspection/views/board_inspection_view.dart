import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../../utils/theme/app_material_theme.dart';
import '../../../routes/app_pages.dart';
import '../../../../utils/helper/a_formatter.dart';
import '../controllers/board_inspection_controller.dart';

class BoardInspectionView extends StatelessWidget {
  const BoardInspectionView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(BoardInspectionController());
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "Inspection & Return",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.status.value.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.status.value.isError) {
          return Center(
            child: Text(
              'Error: ${controller.status.value.errorMessage}',
              style: TextStyle(color: colorScheme.error),
            ),
          );
        }

        final rental = controller.rental.value;
        if (rental == null) {
          return Center(
            child: Text(
              'No rental data found.',
              style: TextStyle(color: colorScheme.onSurface),
            ),
          );
        }

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
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: controller.timeColor.value.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: controller.timeColor.value.withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              controller.timeLabel.value,
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 16.sp,
                              ),
                            ),
                            Text(
                              controller.timeRemaining.value,
                              style: TextStyle(
                                color: controller.timeColor.value,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    SizedBox(height: 24.h),

                    /// 3. Rental Details (From Model)
                    _buildSectionCard(
                      context,
                      title: "Rental Details",
                      children: [
                        _buildDetailRow(
                          context,
                          "Rental ID",
                          rental.id ?? "N/A",
                        ),
                        Obx(
                          () => _buildDetailRow(
                            context,
                            "Customer",
                            controller.customerName,
                            onTap: controller.goToCustomerDetails,
                            valueColor: colorScheme.primary,
                          ),
                        ),
                        Obx(
                          () => _buildDetailRow(
                            context,
                            "Item",
                            controller.boardName,
                            onTap: controller.goToItemDetails,
                            valueColor: colorScheme.primary,
                          ),
                        ),
                        _buildDetailRow(
                          context,
                          "Start Time",
                          AFormatter.formatDateWithFormat(rental.startTime, outputFormat: '${rental.dateFormat ?? "yyyy-MM-dd"} - hh:mm a'),
                        ),
                        _buildDetailRow(
                          context,
                          "Expected Return",
                          AFormatter.formatDateWithFormat(rental.expectedReturnTime, outputFormat: '${rental.dateFormat ?? "yyyy-MM-dd"} - hh:mm a'),
                        ),
                        _buildDetailRow(
                          context,
                          "Rate",
                          "${AFormatter.formatCurrency(rental.rate, currencyCodeOverride: rental.currency)}/hr",
                          isLast: true,
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),

                    /// 2. Payment Info
                    _buildSectionCard(
                      context,
                      title: "Payment Info",
                      navigateTo: Routes.PAYMENTS,
                      arguments: {
                        'rentalId': rental.id,
                        'shopId': rental.shopId,
                      },
                      children: [
                        Column(
                          children: [
                            _buildHighlightRow(
                              context,
                              "Security Deposit",
                              AFormatter.formatCurrency(rental.securityDeposit.amount, currencyCodeOverride: rental.currency),
                              Iconsax.lock,
                              statusColors?.warning ?? Colors.orange,
                            ),
                            Divider(color: colorScheme.outline, height: 24.h),
                            Obx(() => _buildHighlightRow(
                              context,
                              "Balance Due",
                              AFormatter.formatCurrency(controller.balanceDue, currencyCodeOverride: rental.currency),
                              Iconsax.money_tick,
                              controller.balanceDue > 0
                                  ? colorScheme.error
                                  : (statusColors?.success ?? Colors.green),
                            )),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),

            /// 4. Action Footer
            Container(
              padding: EdgeInsets.all(ASizes.defaultPadding),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                border: Border(top: BorderSide(color: colorScheme.outline)),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    // Report Damage Button
                    if (controller.rental.value?.status !=
                        RentalStatus.mark_as_damaged) ...[
                      Expanded(
                        child: SizedBox(
                          height: 54.h,
                          child: ElevatedButton(
                            onPressed: controller.reportDamage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.surfaceContainer,
                              foregroundColor:
                                  statusColors?.warning ?? Colors.orange,
                              side: BorderSide(
                                color: statusColors?.warning ?? Colors.orange,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              "Report Damage",
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                    ],
                    // No Damage Button
                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        height: 54.h,
                        child: ElevatedButton(
                          onPressed: controller.reportNoDamage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            "Confirm Return",
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
              ),
            ),
          ],
        );
      }),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    String? navigateTo,
    dynamic arguments,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (navigateTo != null)
                InkWell(
                  onTap: () => Get.toNamed(navigateTo, arguments: arguments),
                  child: Text(
                    'View Details',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
            ],
          ),
          SizedBox(height: 12.h),
          ...children,
        ],
      ),
    );
  }

  // Highlight Row for Deposit and Payment
  Widget _buildHighlightRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: colorScheme.onSurfaceVariant,
                size: 20.w,
              ),
            ),
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
    BuildContext context,
    String label,
    String value, {
    bool isLast = false,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: InkWell(
              onTap: onTap,
              child: Text(
                value,
                style: TextStyle(
                  color: valueColor ?? colorScheme.onSurface,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  decoration: onTap != null ? TextDecoration.underline : null,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
