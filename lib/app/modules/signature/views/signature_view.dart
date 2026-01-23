import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:signature/signature.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../controllers/signature_pad_controller.dart';

class SignaturePadView extends StatelessWidget {
  const SignaturePadView({super.key});

  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color paperWhite = const Color(0xFFF5F5F5); // Slightly off-white for the pad
  final Color errorRed = const Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignaturePadController());

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.close_circle, // "Close" icon instead of back for modals
        centerTitle: true,
        title: Text(
          "Customer Signature",
          style: TextStyle(color: textWhite, fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        actions: [
          // Clear Button
          TextButton.icon(
            onPressed: controller.clearSignature,
            icon: Icon(Iconsax.eraser, size: 18.w, color: errorRed),
            label: Text("Clear", style: TextStyle(color: errorRed, fontWeight: FontWeight.bold)),
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
              style: TextStyle(color: textGrey, fontSize: 14.sp),
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
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
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
              child: Obx(() => ElevatedButton(
                onPressed: controller.isEmpty.value ? null : controller.saveSignature,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  disabledBackgroundColor: primaryBlue.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  "Confirm Signature",
                  style: TextStyle(
                    color: controller.isEmpty.value ? textGrey : textWhite,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}