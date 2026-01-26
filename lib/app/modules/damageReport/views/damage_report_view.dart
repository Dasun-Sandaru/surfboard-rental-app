import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../controllers/damage_report_controller.dart';

class DamageReportView extends StatelessWidget {
  const DamageReportView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DamageReportController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "Damage Report",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ASizes.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// 1. Damage Details Section
                  _buildSectionTitle(context, "Damage Details"),
                  SizedBox(height: 12.h),

                  Obx(
                    () => Column(
                      children: controller.availableDamageFees.map((fee) {
                        final name = fee.damageType;
                        final isSelected =
                            controller.selectedDamageFees[fee.id] ?? false;
                        final description = fee.description;
                        final feeAmount = fee.feeAmount;
                        final isLostItem = name.toLowerCase().contains("lost");

                        return Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header Row: Name and Toggle
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: TextStyle(
                                            color: colorScheme.onSurface,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        if (description.isNotEmpty)
                                          SizedBox(height: 4.h),
                                        if (description.isNotEmpty)
                                          Text(
                                            description,
                                            style: TextStyle(
                                              color:
                                                  colorScheme.onSurfaceVariant,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: isSelected,
                                    onChanged: (val) {
                                      if (fee.id != null) {
                                        controller.toggleDamage(fee.id!, val);
                                      }
                                    },
                                    activeColor: colorScheme.primary,
                                  ),
                                ],
                              ),
                              // Price Row
                              Divider(color: colorScheme.outline),
                              SizedBox(height: 8.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Replacement Cost:",
                                    style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                  Text(
                                    "\$${feeAmount.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),

                              // Photos Section (Inline)
                              if (isSelected &&
                                  !isLostItem &&
                                  fee.id != null) ...[
                                SizedBox(height: 12.h),
                                Text(
                                  "Photos (Max 3)",
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                SizedBox(
                                  height: 80.h,
                                  child: Obx(() {
                                    final photos =
                                        controller.damagePhotos[fee.id] ?? [];
                                    return ListView.separated(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: photos.length < 3
                                          ? photos.length + 1
                                          : photos.length,
                                      separatorBuilder: (c, i) =>
                                          SizedBox(width: 8.w),
                                      itemBuilder: (context, index) {
                                        // Add Button
                                        if (index == photos.length) {
                                          return InkWell(
                                            onTap: () =>
                                                controller.pickPhoto(fee.id!),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Container(
                                              width: 80.h,
                                              decoration: BoxDecoration(
                                                color: colorScheme.surface,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: colorScheme.outline,
                                                  style: BorderStyle.solid,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Icon(
                                                    Iconsax.camera,
                                                    color: colorScheme
                                                        .onSurfaceVariant,
                                                    size: 20.w,
                                                  ),
                                                  Text(
                                                    "Add",
                                                    style: TextStyle(
                                                      color: colorScheme
                                                          .onSurfaceVariant,
                                                      fontSize: 10.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }

                                        // Thumbnail
                                        return Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Container(
                                              width: 80.h,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                image: DecorationImage(
                                                  image: FileImage(
                                                    photos[index],
                                                  ),
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                            ),
                                            Positioned(
                                              top: -4.h,
                                              right: -4.h,
                                              child: InkWell(
                                                onTap: () =>
                                                    controller.removePhoto(
                                                      fee.id!,
                                                      index,
                                                    ),
                                                child: Container(
                                                  padding: EdgeInsets.all(2.w),
                                                  decoration: BoxDecoration(
                                                    color: colorScheme.error,
                                                    shape: BoxShape.circle,
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Colors.black26,
                                                        blurRadius: 4,
                                                      ),
                                                    ],
                                                  ),
                                                  child: Icon(
                                                    Icons.close,
                                                    color: colorScheme.onError,
                                                    size: 12.w,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }),
                                ),
                              ],

                              // Note Field (Inline)
                              if (isSelected && fee.id != null) ...[
                                SizedBox(height: 12.h),
                                Text(
                                  "Notes",
                                  style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: 12.sp,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                TextFormField(
                                  controller: controller.damageNotes[fee.id],
                                  maxLines: 2,
                                  style: TextStyle(
                                    color: colorScheme.onSurface,
                                  ),
                                  decoration: InputDecoration(
                                    hintText:
                                        "Describe the damage details here...",
                                    hintStyle: TextStyle(
                                      color: colorScheme.onSurfaceVariant
                                          .withOpacity(0.5),
                                      fontSize: 12.sp,
                                    ),
                                    filled: true,
                                    fillColor: colorScheme.surface,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: colorScheme.outline,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: colorScheme.outline,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.all(12.w),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: 24.h),

                  /// 3. Notes Section (Removed)
                  SizedBox(height: 24.h),

                  // Total Damage Fees Summary
                  Obx(() {
                    return Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: colorScheme.primary),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Total Damage Fees:",
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "\$${controller.totalFee.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),

          /// 4. Save Button
          Container(
            padding: EdgeInsets.all(ASizes.defaultPadding),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(top: BorderSide(color: colorScheme.outline)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: controller.saveReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  "Damage Report",
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
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
