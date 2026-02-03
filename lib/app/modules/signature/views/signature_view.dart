import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:signature/signature.dart';
import '../../../../utils/constants/a_sizes.dart';

import '../../../../utils/theme/app_material_theme.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../controllers/signature_pad_controller.dart';

class SignaturePadView extends StatelessWidget {
  const SignaturePadView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignaturePadController());
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>();
    final paperWhite = statusColors?.paperWhite ?? Colors.white;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon:
            Iconsax.close_circle, // "Close" icon instead of back for modals
        centerTitle: true,
        title: Text(
          "Customer Signature",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Clear Button
          TextButton.icon(
            onPressed: controller.clearSignature,
            icon: Icon(Iconsax.eraser, size: 18.w, color: colorScheme.error),
            label: Text(
              "Clear",
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 16.h),

          // -- Instructions --
          Padding(
            padding: EdgeInsets.symmetric(horizontal: ASizes.defaultPadding),
            child: Text(
              "Please sign within the box below to accept the rental agreement.",
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 16.h),

          // -- Signature Pad --
          Expanded(
            child: Container(
              margin: EdgeInsets.all(ASizes.defaultPadding),
              decoration: BoxDecoration(
                color: paperWhite,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Signature(
                  controller: controller.signaturePadController,
                  backgroundColor: paperWhite,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),

          // -- Bottom Confirm Button --
          Container(
            padding: EdgeInsets.all(ASizes.defaultPadding),
            child: SizedBox(
              width: double.infinity,
              height: 54.h,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isEmpty.value
                      ? null
                      : controller.saveSignature,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    disabledBackgroundColor: colorScheme.primary.withValues(
                      alpha: 0.3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    "Confirm Signature",
                    style: TextStyle(
                      color: controller.isEmpty.value
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}