import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/agreement_controller.dart';

class StepBoardDetails extends GetView<AgreementController> {
  const StepBoardDetails({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'what_are_they_renting'.tr,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'select_board_accessories'.tr,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16.sp,
            ),
          ),

          SizedBox(height: 32.h),

          // Board Dropdown (Simulated)
          // In real app use your Inventory List here
          Obx(
            () => _buildSelectionCard(
              context,
              'selected_board'.tr,
              Iconsax.box,
              controller.board?.name ?? 'no_board_selected'.tr,
            ),
          ),

          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildSelectionCard(
    BuildContext context,
    String title,
    IconData icon,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12.sp,
                  ),
                ),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Icon(Iconsax.arrow_down_1, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
