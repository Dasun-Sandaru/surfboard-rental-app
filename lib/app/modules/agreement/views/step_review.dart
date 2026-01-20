import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/agreement_controller.dart';

class StepReview extends GetView<AgreementController> {
  const StepReview({super.key});

  @override
  Widget build(BuildContext context) {
    final Color cardDark = const Color(0xFF182c30);
    final Color borderDark = const Color(0xFF334155);
    final Color textWhite = const Color(0xFFf0f4f4);
    final Color textGrey = const Color(0xFF94a3b8);
    final Color primaryBlue = const Color(0xFF4A90E2);

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Review Agreement", style: TextStyle(color: textWhite, fontSize: 24.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text("Review details and sign below.", style: TextStyle(color: textGrey, fontSize: 16.sp)),
          
          SizedBox(height: 24.h),

          // -- Summary Card --
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow("Board", "Channel Islands Fish 6'2\"", textWhite, textGrey),
                SizedBox(height: 12.h),
                
                Obx(() => _buildSummaryRow("Accessories", controller.selectedAccessories.join(", "), textWhite, textGrey)),
                SizedBox(height: 12.h),
                
                Obx(() => _buildSummaryRow("Duration", controller.rentalDuration.value, textWhite, textGrey)),
                
                Divider(color: borderDark, height: 32.h),
                
                _buildSummaryRow("Rental Price", "\$${controller.rentalPriceController.text}", primaryBlue, textGrey, isBold: true),
                
                Obx(() {
                  if (controller.requireDeposit.value) {
                    return Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: _buildSummaryRow("Security Deposit", "\$${controller.depositController.text}", const Color(0xFFF59E0B), textGrey),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // -- Damage Fee Summary (Only Enabled ones) --
          Text("Damage Policy Agreement", style: TextStyle(color: textWhite, fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: cardDark.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderDark),
            ),
            child: Obx(() {
              // Filter only enabled fees
              final activeFees = controller.damageFees.entries.where((e) => e.value['enabled'] == true).toList();
              
              if (activeFees.isEmpty) return Text("No specific damage fees applied.", style: TextStyle(color: textGrey, fontStyle: FontStyle.italic));

              return Column(
                children: activeFees.map((e) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e.key, style: TextStyle(color: textWhite)),
                        Text("\$${e.value['price']}", style: TextStyle(color: const Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }).toList(),
              );
            }),
          ),

          SizedBox(height: 32.h),

          // -- Signature Area --
          Text("Customer Signature", style: TextStyle(color: textWhite, fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Container(
            height: 150.h,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFf0f4f4), // Light background for signature contrast
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Center(child: Text("Sign Here", style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 24.sp, fontWeight: FontWeight.bold))),
                // Use 'signature' package widget here in real app
                // Signature(controller: _controller, backgroundColor: Colors.transparent),
              ],
            ),
          ),
          
          SizedBox(height: 16.h),
          
          // Terms Checkbox
          Row(
            children: [
              Checkbox(
                value: true, 
                onChanged: (v){},
                activeColor: primaryBlue,
                checkColor: textWhite,
              ),
              Expanded(
                child: Text(
                  "I agree to the terms and conditions stated above.",
                  style: TextStyle(color: textGrey, fontSize: 12.sp),
                ),
              )
            ],
          ),
          
          // Bottom padding to ensure button visibility
          SizedBox(height: 80.h),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor, Color labelColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: labelColor, fontSize: 14.sp)),
        Text(value, style: TextStyle(color: valueColor, fontSize: 16.sp, fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
      ],
    );
  }
}