import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../utils/theme/app_material_theme.dart';
import '../../../models/init_rental_model.dart';
import '../../signature/views/signature_view.dart';
import '../controllers/agreement_controller.dart';
import '../../../../utils/helper/a_formatter.dart';

class StepReview extends GetView<AgreementController> {
  const StepReview({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // This Obx will wrap the main content to react to data model changes
    return Obx(() {
      final rentalData = controller.initRentalModel.value;
      if (rentalData == null) {
        return Center(
          child: Text(
            'no_rental_data_available'.tr,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'review_agreement'.tr,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'review_details_sign'.tr,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 16.sp,
              ),
            ),
            SizedBox(height: 24.h),
            _buildCustomerInfo(context, rentalData),
            SizedBox(height: 16.h),
            _buildRentalDetails(context, rentalData),
            SizedBox(height: 16.h),
            _buildPricingDetails(context),
            SizedBox(height: 24.h),
            _buildDamageFeeSection(context),
            SizedBox(height: 32.h),
            _buildSignatureSection(context),
            SizedBox(height: 16.h),
            _buildTermsCheckbox(context),
            SizedBox(height: 80.h), // Bottom padding
          ],
        ),
      );
    });
  }

  // --- Section Widgets ---

  Widget _buildCustomerInfo(BuildContext context, InitRentalModel rentalData) {
    final customer = rentalData.customer;
    return _buildSectionCard(context, [
      _buildSectionHeader(context, 'renter_information'.tr),
      _buildSummaryRow(
        context,
        'name'.tr,
        "${customer.firstName} ${customer.lastName}",
      ),
      _buildSummaryRow(context, 'email'.tr, customer.email),
      if (customer.phone.isNotEmpty)
        _buildSummaryRow(context, 'phone'.tr, customer.phone),
    ]);
  }

  Widget _buildRentalDetails(BuildContext context, InitRentalModel rentalData) {
    final board = rentalData.items.first;
    return _buildSectionCard(context, [
      _buildSectionHeader(context, 'rental_details'.tr),
      _buildSummaryRow(context, 'item'.tr, "${board.brand} ${board.name}"),
      _buildSummaryRow(
        context,
        'size'.tr,
        "${board.sizeFeet}' ${board.sizeInches}\"",
      ),
      SizedBox(height: 8.h),
      _buildSummaryRow(context, 'start_time'.tr, rentalData.startDateTimeString),
      _buildSummaryRow(context, 'due_time'.tr, rentalData.dueDateTimeString),
    ]);
  }

  Widget _buildPricingDetails(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>();
    final rentalPrice =
        double.tryParse(controller.rentalPriceController.text) ?? 0.0;
    final deposit = controller.requireDeposit.value
        ? (double.tryParse(controller.depositController.text) ?? 0.0)
        : 0.0;
    final totalDamageFees = controller.getTotalDamageFees();
    final grandTotal = rentalPrice + deposit;

    return _buildSectionCard(context, [
      _buildSectionHeader(context, 'pricing_summary'.tr),
      _buildSummaryRow(
        context,
        'rental_price'.tr,
        AFormatter.formatCurrency(rentalPrice),
        valueColor: colorScheme.primary,
      ),
      if (controller.requireDeposit.value)
        _buildSummaryRow(
          context,
          'security_deposit'.tr,
          AFormatter.formatCurrency(deposit),
          valueColor: statusColors?.warning ?? Colors.orange,
        ),
      _buildSummaryRow(
        context,
        'max_damage_liability'.tr,
        AFormatter.formatCurrency(totalDamageFees),
        valueColor: statusColors?.error ?? Colors.red,
      ),
      Divider(color: colorScheme.outline, height: 24.h),
      _buildSummaryRow(
        context,
        'total_due_today'.tr,
        AFormatter.formatCurrency(grandTotal),
        isBold: true,
        valueColor: colorScheme.onSurface,
      ),
    ]);
  }

  Widget _buildDamageFeeSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>();
    final selectedFees = controller.getSelectedDamageFees();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'damage_policy_agreement'.tr,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        _buildSectionCard(
          context,
          selectedFees.isEmpty
              ? [
                  Text(
                    'no_specific_damage_fees'.tr,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ]
              : selectedFees
                    .map(
                      (fee) => _buildSummaryRow(
                        context,
                        fee.damageType,
                        AFormatter.formatCurrency(fee.feeAmount),
                        valueColor: statusColors?.error ?? Colors.red,
                      ),
                    )
                    .toList(),
        ),
      ],
    );
  }

  Widget _buildSignatureSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'customer_signature'.tr,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        // Inside StepReview widget
        InkWell(
          onTap: () async {
            // Open Signature Screen and wait for result
            final result = await Get.to(() => const SignaturePadView());

            if (result != null && result is Uint8List) {
              // Update controller with the signature image bytes
              controller.customerSignature.value = result;
            }
          },
          child: Container(
            height: 150.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Obx(() {
              if (controller.customerSignature.value != null) {
                // Show Signed Image
                return Image.memory(controller.customerSignature.value!);
              } else {
                // Show Placeholder
                return Center(
                  child: Text(
                    'tap_to_sign'.tr,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Checkbox(
          value: controller.isAgree.value,
          onChanged: (v) {
            controller.isAgree.value = v ?? false;
          },
          activeColor: colorScheme.primary,
          checkColor: colorScheme.onPrimary,
          side: BorderSide(color: colorScheme.outline),
        ),
        Expanded(
          child: Text(
            'agree_to_terms'.tr,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12.sp,
            ),
          ),
        ),
      ],
    );
  }

  // --- Generic Helper Widgets ---

  Widget _buildSectionCard(BuildContext context, List<Widget> children) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
    bool isBold = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: valueColor ?? colorScheme.onSurface,
                fontSize: 16.sp,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
