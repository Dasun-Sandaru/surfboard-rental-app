import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../models/new_rental_pass_model.dart';
import '../controllers/agreement_controller.dart';

class StepReview extends GetView<AgreementController> {
  const StepReview({super.key});

  // --- Theme Colors ---
  static const Color cardDark = Color(0xFF182c30);
  static const Color borderDark = Color(0xFF334155);
  static const Color textWhite = Color(0xFFf0f4f4);
  static const Color textGrey = Color(0xFF94a3b8);
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color warningYellow = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    // This Obx will wrap the main content to react to data model changes
    return Obx(() {
      final rentalData = controller.newRentalPassData.value;
      if (rentalData == null) {
        return const Center(
          child: Text("No rental data available.",
              style: TextStyle(color: textGrey)),
        );
      }

      return SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Review Agreement",
              style: TextStyle(
                color: textWhite,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Review details and sign below.",
              style: TextStyle(color: textGrey, fontSize: 16.sp),
            ),
            SizedBox(height: 24.h),
            _buildCustomerInfo(rentalData),
            SizedBox(height: 16.h),
            _buildRentalDetails(rentalData),
            SizedBox(height: 16.h),
            _buildPricingDetails(),
            SizedBox(height: 24.h),
            _buildDamageFeeSection(),
            SizedBox(height: 32.h),
            _buildSignatureSection(),
            SizedBox(height: 16.h),
            _buildTermsCheckbox(),
            SizedBox(height: 80.h), // Bottom padding
          ],
        ),
      );
    });
  }

  // --- Section Widgets ---

  Widget _buildCustomerInfo(NewRentalPassModel rentalData) {
    final customer = rentalData.customer;
    return _buildSectionCard([
      _buildSectionHeader("Renter Information"),
      _buildSummaryRow("Name", "${customer.firstName} ${customer.lastName}"),
      _buildSummaryRow("Email", customer.email),
      if (customer.phone.isNotEmpty)
        _buildSummaryRow("Phone", customer.phone),
    ]);
  }

  Widget _buildRentalDetails(NewRentalPassModel rentalData) {
    final board = rentalData.items.first;
    return _buildSectionCard([
      _buildSectionHeader("Rental Details"),
      _buildSummaryRow("Item", "${board.brand} ${board.name}"),
      _buildSummaryRow("Size", "${board.sizeFeet}' ${board.sizeInches}\""),
      SizedBox(height: 8.h),
      _buildSummaryRow("Start Time", rentalData.startDateTimeString),
      _buildSummaryRow("Due Time", rentalData.dueDateTimeString),
    ]);
  }

  Widget _buildPricingDetails() {
    final rentalPrice =
        double.tryParse(controller.rentalPriceController.text) ?? 0.0;
    final deposit = controller.requireDeposit.value
        ? (double.tryParse(controller.depositController.text) ?? 0.0)
        : 0.0;
    final totalDamageFees = controller.getTotalDamageFees();
    final grandTotal = rentalPrice + deposit;

    return _buildSectionCard([
      _buildSectionHeader("Pricing Summary"),
      _buildSummaryRow(
        "Rental Price",
        "\$${rentalPrice.toStringAsFixed(2)}",
        valueColor: primaryBlue,
      ),
      if (controller.requireDeposit.value)
        _buildSummaryRow(
          "Security Deposit",
          "\$${deposit.toStringAsFixed(2)}",
          valueColor: warningYellow,
        ),
      _buildSummaryRow(
        "Max Damage Liability",
        "\$${totalDamageFees.toStringAsFixed(2)}",
        valueColor: errorRed,
      ),
      Divider(color: borderDark, height: 24.h),
      _buildSummaryRow(
        "Total Due Today",
        "\$${grandTotal.toStringAsFixed(2)}",
        isBold: true,
        valueColor: textWhite,
      ),
    ]);
  }

  Widget _buildDamageFeeSection() {
    final selectedFees = controller.getSelectedDamageFees();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Damage Policy Agreement",
          style: TextStyle(
              color: textWhite, fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        _buildSectionCard(
          selectedFees.isEmpty
              ? [
                  Text(
                    "No specific damage fees applied. General wear and tear is expected.",
                    style:
                        TextStyle(color: textGrey, fontStyle: FontStyle.italic),
                  )
                ]
              : selectedFees
                  .map((fee) => _buildSummaryRow(
                        fee.damageType,
                        "\$${fee.feeAmount.toStringAsFixed(2)}",
                        valueColor: errorRed,
                      ))
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildSignatureSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Customer Signature",
          style: TextStyle(
            color: textWhite,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          height: 150.h,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFFf0f4f4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              Center(
                child: Text(
                  "Sign Here",
                  style: TextStyle(
                    color: Colors.grey.withOpacity(0.5),
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: true,
          onChanged: (v) {},
          activeColor: primaryBlue,
          checkColor: textWhite,
          side: BorderSide(color: borderDark),
        ),
        Expanded(
          child: Text(
            "I agree to the terms and conditions stated above.",
            style: TextStyle(color: textGrey, fontSize: 12.sp),
          ),
        ),
      ],
    );
  }

  // --- Generic Helper Widgets ---

  Widget _buildSectionCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: TextStyle(
            color: primaryBlue, fontSize: 16.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
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
              color: valueColor ?? textWhite,
              fontSize: 16.sp,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

