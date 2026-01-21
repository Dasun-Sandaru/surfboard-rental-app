import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// -- Theme Colors --
const Color bgDark = Color(0xFF101f22);
const Color cardDark = Color(0xFF182c30);
const Color primaryBlue = Color(0xFF4A90E2);
const Color textWhite = Color(0xFFf0f4f4);
const Color textGrey = Color(0xFF94a3b8);
const Color borderDark = Color(0xFF334155);

class AppDialogs {
  static void defaultDialog({
    required BuildContext context,
    required String title,
    required Widget contentWidget,
    String? confirmText,
    VoidCallback? onConfirm,
    String? cancelText,
    VoidCallback? onCancel,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: cardDark,
          title: Text(
            title,
            style: TextStyle(
              color: textWhite,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: contentWidget,
          actions: <Widget>[
            if (cancelText != null)
              TextButton(
                child: Text(
                  cancelText,
                  style: TextStyle(color: textGrey, fontSize: 14.sp),
                ),
                onPressed: onCancel ?? () => Get.back(),
              ),
            if (confirmText != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  confirmText,
                  style: TextStyle(color: textWhite, fontSize: 14.sp),
                ),
                onPressed: onConfirm,
              ),
          ],
        );
      },
    );
  }
}
