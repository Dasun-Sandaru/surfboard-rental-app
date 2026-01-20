import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/agreement_controller.dart';

class StepPricing extends GetView<AgreementController> {
  const StepPricing({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme colors
    final Color cardDark = const Color(0xFF182c30);
    final Color borderDark = const Color(0xFF334155);
    final Color textWhite = const Color(0xFFf0f4f4);
    final Color textGrey = const Color(0xFF94a3b8);
    final Color primaryBlue = const Color(0xFF4A90E2);

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Rental Details", style: TextStyle(color: textWhite, fontSize: 24.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text("Set the duration and total price.", style: TextStyle(color: textGrey, fontSize: 16.sp)),
          
          SizedBox(height: 32.h),

          // Duration Selector
          Text("Duration", style: TextStyle(color: textWhite, fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildDurationOption("4 Hours", controller),
              SizedBox(width: 12.w),
              _buildDurationOption("1 Day", controller),
              SizedBox(width: 12.w),
              _buildDurationOption("Custom", controller),
            ],
          ),

          SizedBox(height: 32.h),

          // Rental Price Input
          _buildMoneyInput(
            label: "Total Rental Price", 
            controller: controller.rentalPriceController,
            icon: Iconsax.money_tick,
            cardDark: cardDark, 
            borderDark: borderDark,
            textWhite: textWhite
          ),

          SizedBox(height: 32.h),

          // Deposit Section
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderDark),
            ),
            child: Column(
              children: [
                Obx(() => SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text("Require Security Deposit", style: TextStyle(color: textWhite, fontWeight: FontWeight.bold)),
                  subtitle: Text("Hold an ID or Cash", style: TextStyle(color: textGrey, fontSize: 12.sp)),
                  value: controller.requireDeposit.value,
                  onChanged: (val) => controller.requireDeposit.value = val,
                  activeColor: primaryBlue,
                )),
                
                // Show input only if enabled
                Obx(() {
                  if (controller.requireDeposit.value) {
                    return Column(
                      children: [
                        Divider(color: borderDark),
                        SizedBox(height: 12.h),
                         _buildMoneyInput(
                            label: "Deposit Amount", 
                            controller: controller.depositController,
                            icon: Iconsax.lock,
                            cardDark: const Color(0xFF101f22), // Slightly darker for inner input
                            borderDark: borderDark,
                            textWhite: textWhite
                          ),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationOption(String label, AgreementController controller) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.rentalDuration.value == label;
        return InkWell(
          onTap: () => controller.rentalDuration.value = label,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4A90E2) : const Color(0xFF182c30),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? const Color(0xFF4A90E2) : const Color(0xFF334155)),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFF94a3b8),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMoneyInput({
    required String label, 
    required TextEditingController controller, 
    required IconData icon,
    required Color cardDark,
    required Color borderDark,
    required Color textWhite,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(color: textWhite, fontSize: 18.sp, fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            prefixText: "\$ ",
            prefixStyle: TextStyle(color: textWhite, fontSize: 18.sp),
            filled: true,
            fillColor: cardDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderDark)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderDark)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF4A90E2))),
            contentPadding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
          ),
        ),
      ],
    );
  }
}