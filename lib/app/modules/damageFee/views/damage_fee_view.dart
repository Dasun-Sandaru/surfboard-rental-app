import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/app/models/damage_fee_model.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../controllers/damage_fee_controller.dart';

class DamageFeeView extends GetView<DamageFeeController> {
  const DamageFeeView({super.key});

  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22);
  final Color cardDark = const Color(0xFF182c30);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color borderDark = const Color(0xFF334155);
  final Color errorRed = const Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "Damage Fee Rules",
          style: TextStyle(
            color: textWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Loading State
          Obx(() {
            if (controller.isLoading.value) {
              return Center(
                child: CircularProgressIndicator(color: primaryBlue),
              );
            }

            // Empty State
            if (controller.damageRules.isEmpty) {
              return _buildEmptyList();
            }

            // List Content
            return Obx(
              () => ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  ASizes.defaultPadding,
                  ASizes.defaultPadding,
                  ASizes.defaultPadding,
                  100.h,
                ),
                itemCount: controller.damageRules.length,
                separatorBuilder: (context, index) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final rule = controller.damageRules[index];
                  return _buildDamageRuleCard(rule, controller);
                },
              ),
            );
          }),

          // Floating Action Button (Centered at bottom like HTML)
          Positioned(
            bottom: 30.h,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                height: 50.h,
                child: ElevatedButton(
                  onPressed: () => controller.openAddEditDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    foregroundColor: textWhite,
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.add, size: 24.w),
                      SizedBox(width: 8.w),
                      Text(
                        "Add Damage Rule",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDamageRuleCard(
    DamageFeeModel rule,
    DamageFeeController controller,
  ) {
    final bool isActive = rule.activeStatus;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive
              ? borderDark.withOpacity(0.5)
              : borderDark.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Info Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rule.damageType,
                  style: TextStyle(
                    color: isActive ? textWhite : textGrey,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "\$${rule.feeAmount.toStringAsFixed(2)}",
                  style: TextStyle(color: textGrey, fontSize: 14.sp),
                ),
                if (rule.description.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    rule.description,
                    style: TextStyle(
                      color: textGrey.withOpacity(0.6),
                      fontSize: 12.sp,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              // Edit Button
              _buildIconButton(
                icon: Iconsax.edit,
                color: textGrey,
                bgColor: bgDark,
                onTap: () => controller.openAddEditDialog(rule: rule),
              ),

              SizedBox(width: 8.w),

              // Delete Button
              _buildIconButton(
                icon: Iconsax.trash,
                color: errorRed,
                bgColor: errorRed.withOpacity(0.1),
                onTap: () => controller.deleteRule(rule.id!),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 40.w,
        width: 40.w,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 20.w),
      ),
    );
  }

  Widget _buildEmptyList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2, size: 64.w, color: textGrey),
          SizedBox(height: 16.h),
          Text(
            "No damage fee rules found.",
            style: TextStyle(color: textGrey, fontSize: 16.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            "Tap the button below to add a new rule.",
            style: TextStyle(color: textGrey.withOpacity(0.7), fontSize: 14.sp),
          ),
        ],
      ),
    );
  }
}
