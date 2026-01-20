import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/agreement_controller.dart';

class StepBoardDetails extends GetView<AgreementController> {
  const StepBoardDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final Color textWhite = const Color(0xFFf0f4f4);
    final Color textGrey = const Color(0xFF94a3b8);
    
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What are they renting?", style: TextStyle(color: textWhite, fontSize: 24.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text("Select the board and accessories.", style: TextStyle(color: textGrey, fontSize: 16.sp)),
          
          SizedBox(height: 32.h),

          // Board Dropdown (Simulated)
          // In real app use your Inventory List here
          _buildSelectionCard("Select Board", Iconsax.box, "Channel Islands Fish 6'2\""),

          SizedBox(height: 24.h),
          
          Text("Accessories", style: TextStyle(color: textWhite, fontSize: 18.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: ["Leash", "Fins", "Wax", "Board Bag"].map((item) {
              return Obx(() {
                final isSelected = controller.selectedAccessories.contains(item);
                return ChoiceChip(
                  label: Text(item),
                  selected: isSelected,
                  onSelected: (selected) {
                    if(selected) controller.selectedAccessories.add(item);
                    else controller.selectedAccessories.remove(item);
                  },
                  selectedColor: const Color(0xFF4A90E2),
                  backgroundColor: const Color(0xFF182c30),
                  labelStyle: TextStyle(color: isSelected ? Colors.white : textGrey),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                );
              });
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildSelectionCard(String title, IconData icon, String value) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF182c30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4A90E2)),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: const Color(0xFF94a3b8), fontSize: 12.sp)),
              Text(value, style: TextStyle(color: const Color(0xFFf0f4f4), fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          const Spacer(),
          Icon(Iconsax.arrow_down_1, color: const Color(0xFF94a3b8)),
        ],
      ),
    );
  }
}