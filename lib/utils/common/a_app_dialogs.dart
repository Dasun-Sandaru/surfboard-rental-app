import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/a_sizes.dart';

void showOkAppDialog(
  String title,
  String message, {
  bool isDoubleBack = false,
  bool isDismissible = true,
}) {
  Get.defaultDialog(
    title: title.tr,
    middleText: message.tr,
    barrierDismissible: isDismissible,
    confirm: ElevatedButton(
      onPressed: () {
        if (isDoubleBack) {
          Get.back();
          Get.back(); // Close the dialog and go back to previous screen
        } else {
          Get.back(); // Close the dialog and go back to previous screen
        }
      },
      child: Text("OK".tr),
    ),
  );
}

void apiFailedWithErrors(String title, Map<String, dynamic> errors) {
  showDialog(
    context: Get.context!,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title.tr, style: Theme.of(context).textTheme.bodyLarge),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: errors.length,
            itemBuilder: (context, index) {
              // Get the key and value
              final key = errors.keys.elementAt(index);
              final messages = errors[key] as List;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    key, // Field name (e.g., 'email')
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...messages.map(
                    (message) => Text(
                      '- $message', // Error message
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const Divider(),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK".tr),
          ),
        ],
      );
    },
  );
}

void apiFailedWithUnauthorized(String title, List<String> errors) {
  showDialog(
    context: Get.context!,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title.tr, style: Theme.of(context).textTheme.bodyLarge),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: errors.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    errors[index],
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Divider(),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              // Get.offAllNamed(Routes.SIGNIN);
            },
            child: Text("Re-Login".tr),
          ),
        ],
      );
    },
  );
}

void _showCustomConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
  required String cancelText,
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  bool barrierDismissible = true,
  Color? buttonColor,
}) {
  showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      final colorScheme = Theme.of(context).colorScheme;
      final Color activeBtnColor = buttonColor ?? colorScheme.primary;

      return AlertDialog(
        backgroundColor: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
        ),
        titlePadding: EdgeInsets.only(left: 24.w, top: 24.h, right: 24.w, bottom: 12.h),
        contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        actionsPadding: EdgeInsets.only(left: 24.w, right: 16.w, bottom: 16.h, top: 8.h),
        title: Text(
          title.tr,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          message.tr,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 15.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onCancel != null) onCancel();
            },
            child: Text(
              cancelText.tr.toUpperCase(),
              style: TextStyle(
                color: activeBtnColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onConfirm();
            },
            child: Text(
              confirmText.tr.toUpperCase(),
              style: TextStyle(
                color: activeBtnColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      );
    },
  );
}

void showAppConfirmation({
  required BuildContext context,
  required String title,
  required String message,
  String confirmText = 'OK',
  String cancelText = 'CANCEL',
  required VoidCallback onConfirm,
  VoidCallback? onCancel,
  bool barrierDismissible = true,
  Color? buttonColor,
}) {
  _showCustomConfirmationDialog(
    context: context,
    title: title,
    message: message,
    confirmText: confirmText,
    cancelText: cancelText,
    onConfirm: onConfirm,
    onCancel: onCancel,
    barrierDismissible: barrierDismissible,
    buttonColor: buttonColor,
  );
}

void showYesNoAppDialog(String title, String message, {Color? buttonColor}) {
  _showCustomConfirmationDialog(
    context: Get.context!,
    title: title,
    message: message,
    confirmText: 'YES'.tr,
    cancelText: 'NO'.tr,
    onConfirm: () {},
    buttonColor: buttonColor,
  );
}

void showYesNoRoutineAppDialog(
  String title,
  String message, {
  VoidCallback? onYes,
  VoidCallback? onNo,
  Color? buttonColor,
}) {
  _showCustomConfirmationDialog(
    context: Get.context!,
    title: title,
    message: message,
    confirmText: 'YES'.tr,
    cancelText: 'NO'.tr,
    onConfirm: () => onYes?.call(),
    onCancel: onNo,
    buttonColor: buttonColor,
  );
}

// void showAppExitDialog() {
//   showDialog(
//     barrierDismissible: false,
//     context: Get.context!,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         // title: Text('Exit Application'),
//         content: Text(
//           'Are you sure you want to close the application?',
//           style: Theme.of(context).textTheme.bodyLarge,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//             child: const Text("NO"),
//           ),
//           TextButton(
//             onPressed: () {
//               // Platform-specific exit handling
// if (Platform.isAndroid) {
//   SystemNavigator.pop(); // Close the app on Android
// } else if (Platform.isIOS) {
//   exit(0); // Close the app on iOS (not recommended for iOS)
// }
//             },
//             child: const Text("YES"),
//           ),
//         ],
//       );
//     },
//   );
// }

Future<bool> showAppExitDialog() async {
  final shouldExit = await showDialog<bool>(
    context: Get.context!,
    builder: (context) {
      final colorScheme = Theme.of(context).colorScheme;
      return AlertDialog(
        backgroundColor: colorScheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4.r),
          side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.5)),
        ),
        titlePadding: EdgeInsets.only(left: 24.w, top: 24.h, right: 24.w, bottom: 12.h),
        contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        actionsPadding: EdgeInsets.only(left: 24.w, right: 16.w, bottom: 16.h, top: 8.h),
        title: Text(
          'Exit App'.tr,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to exit?'.tr,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 15.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'NO'.tr.toUpperCase(),
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'YES'.tr.toUpperCase(),
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
              ),
            ),
          ),
        ],
      );
    },
  );

  return shouldExit ?? false;
}

void showLogoutFromAppDialog(void Function()? onPressed) {
  _showCustomConfirmationDialog(
    context: Get.context!,
    title: 'confirmation'.tr,
    message: 'logout_confirm_msg'.tr,
    confirmText: 'YES'.tr,
    cancelText: 'NO'.tr,
    onConfirm: () => onPressed?.call(),
    barrierDismissible: false,
  );
}

void showDeleteWarningDialog(VoidCallback? onYes) {
  final context = Get.context;
  _showCustomConfirmationDialog(
    context: context ?? Get.context!,
    title: 'delete'.tr,
    message: 'delete_confirm_msg'.tr,
    confirmText: 'YES'.tr,
    cancelText: 'NO'.tr,
    onConfirm: () => onYes?.call(),
    buttonColor: context != null ? Theme.of(context).colorScheme.error : null,
  );
}

// void showUploadFailedDialog(Future<void> Function() retry) {
//   showDialog(
//     context: Get.context!,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text(
//           "Submission Failed",
//           style: Theme.of(context).textTheme.bodyLarge,
//         ),
//         content: Text(
//           'Do you want to retry?',
//           style: Theme.of(context).textTheme.bodyMedium,
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop(); // Close the dialog
//               Get.back();
//             },
//             child: const Text("SUBMIT LATER"),
//           ),
//           TextButton(
//             onPressed: () async {
//               Navigator.of(context).pop(); // Close the dialog
//               await retry(); // Call the retry function
//             },
//             child: const Text("YES"),
//           ),
//         ],
//       );
//     },
//   );
// }

void showUploadFailedDialog(Map<String, dynamic> errors) {
  showDialog(
    context: Get.context!,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          "Submission Failed".tr,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: errors.length,
            itemBuilder: (context, index) {
              // Get the key and value
              final key = errors.keys.elementAt(index);
              final messages = errors[key]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    key,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ...messages.map(
                    (message) => Text(
                      '- $message',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const Divider(),
                ],
              );
            },
          ),
        ),
        actions: [
          // TextButton(
          //   onPressed: () {
          //     Navigator.of(context).pop(); // Close the dialog
          //     Get.back();
          //   },
          //   child: const Text("SUBMIT LATER"),
          // ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("EDIT".tr),
          ),
        ],
      );
    },
  );
}

// Future<void> chnageImgQuality(BuildContext context) async {
//   await showDialog<void>(
//     context: context,
//     builder: (BuildContext context) {
//       return SimpleDialog(
//         title: const Text('Select Image Quality'),
//         children: <Widget>[
//           SimpleDialogOption(
//             onPressed: () async {
//               Navigator.of(context).pop();
//             },
//             child: const Text('High'),
//           ),
//           SimpleDialogOption(
//             onPressed: () async {
//               Navigator.of(context).pop();
//             },
//             child: const Text('Medium'),
//           ),
//           SimpleDialogOption(
//             onPressed: () async {
//               Navigator.of(context).pop();
//             },
//             child: const Text('Low'),
//           ),
//         ],
//       );
//     },
//   );
// }

void showChangeLanguageDialog() {
  showDialog(
    context: Get.context!,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        title: Text(
          'Change Language'.tr,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('English'.tr),
              onTap: () {
                onLanguageSelected('en');
              },
            ),
            ListTile(
              title: Text('Sinhala'.tr),
              onTap: () {
                onLanguageSelected('si');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CANCEL'.tr),
          ),
        ],
      );
    },
  );
}

void onLanguageSelected(String langCode) {
  final box = GetStorage();
  box.write('selected_language', langCode);
  Get.updateLocale(Locale(langCode));
  if (Get.context != null) Navigator.of(Get.context!).pop();
}

void showCongratulationsDialog(BuildContext context) {
  Get.defaultDialog(
    title: '',
    titlePadding: EdgeInsets.zero,
    contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
    radius: 20.r,
    barrierDismissible: false,
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'congratulations'.tr,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 8.w),
            Text('🎉', style: TextStyle(fontSize: 24.sp)),
          ],
        ),
        SizedBox(height: ASizes.smallPadding),

        Text(
          'account_ready'.tr,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 24.h),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              padding: EdgeInsets.symmetric(vertical: 16.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ASizes.largeRadius),
              ),
            ),
            child: Text(
              'back_to_home'.tr,
              style: Theme.of(
                context,
              ).textTheme.titleMedium!.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}
