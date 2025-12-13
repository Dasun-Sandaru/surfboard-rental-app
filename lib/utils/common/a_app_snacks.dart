import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

void appSnackBarM(String message) {
  ScaffoldMessenger.of(Get.context!).showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(fontSize: 16.sp)),
    ),
  );
}

void appSnackBarTM(String title, String message) {
  Get.snackbar(title, message, snackPosition: SnackPosition.BOTTOM);
}

void appRoutineSnackBar(String title, String message, {String? routeName}) {
  Get.snackbar(
    title,
    message,
    snackPosition: SnackPosition.BOTTOM,
    duration: const Duration(seconds: 3),
    onTap: (snack) {
      if (routeName != null) {
        // Navigate to the specified route when the snackbar is tapped
        Get.toNamed(routeName);
      }
    },
  );
}

void appSnackBarSuccessAndFailure(String message, {bool isSuccess = true}) {
  ScaffoldMessenger.of(Get.context!).showSnackBar(
    SnackBar(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      content: Row(
        children: [
          Icon(
            isSuccess
                ? Icons.check_circle
                : Icons.error, // Success or Error Icon
            color: isSuccess ? Colors.green : Colors.red,
            size: 20.sp,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: Theme.of(Get.context!).textTheme.bodyMedium!.copyWith(
                color: isSuccess ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: isSuccess ? Colors.green[100] : Colors.red[100],
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 5),
    ),
  );
}

Future<void> appSnackBarWithResult(String message, {bool isSuccess = true}) {
  final future = ScaffoldMessenger.of(Get.context!)
      .showSnackBar(
        SnackBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          content: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(Get.context!).textTheme.bodyMedium!.copyWith(
                    color: isSuccess ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isSuccess ? Colors.green[100] : Colors.red[100],
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
        ),
      )
      .closed;
  return future;
}
