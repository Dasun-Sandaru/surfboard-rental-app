import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorScheme.surfaceContainer,
          title: Text(
            title,
            style: TextStyle(
              color: colorScheme.onSurface,
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
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14.sp,
                  ),
                ),
                onPressed: onCancel ?? () => Get.back(),
              ),
            if (confirmText != null)
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(confirmText, style: TextStyle(fontSize: 14.sp)),
                onPressed: onConfirm,
              ),
          ],
        );
      },
    );
  }
}
