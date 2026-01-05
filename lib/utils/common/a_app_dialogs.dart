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

void showYesNoAppDialog(String title, String message) {
  Get.defaultDialog(
    title: title.tr,
    middleText: message.tr,
    barrierDismissible: true,
    confirm: ElevatedButton(
      onPressed: () {
        Get.back();
      },
      child: Text("YES".tr),
    ),
    cancel: ElevatedButton(
      onPressed: () {
        Get.back();
      },
      child: Text("NO".tr),
    ),
  );
}

void showYesNoRoutineAppDialog(
  String title,
  String message, {
  VoidCallback? onYes,
  VoidCallback? onNo,
}) {
  Get.defaultDialog(
    title: title.tr,
    middleText: message.tr,
    barrierDismissible: true,
    confirm: ElevatedButton(
      onPressed: () {
        onYes?.call();
      },
      child: Text("YES".tr),
    ),
    cancel: ElevatedButton(
      onPressed: () {
        onNo?.call();
      },
      child: Text("NO".tr),
    ),
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
  final shouldExit = await showDialog(
    context: Get.context!,
    builder: (context) => AlertDialog(
      title: Text('Exit App'.tr, style: Theme.of(context).textTheme.bodyLarge),
      content: Text('Are you sure you want to exit?'.tr),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('NO'.tr),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('YES'.tr),
        ),
      ],
    ),
  );

  return shouldExit ?? false; // Default to false if the user doesn't confirm
}

void showLogoutFromAppDialog(void Function()? onPressed) {
  showDialog(
    barrierDismissible: false,
    context: Get.context!,
    builder: (BuildContext context) {
      return AlertDialog(
        content: Text(
          'Are you sure you want to logout?'.tr,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text("NO".tr),
          ),
          TextButton(onPressed: onPressed, child: Text("YES".tr)),
        ],
      );
    },
  );
}

void showDeleteWarningDialog(VoidCallback? onYes) {
  showDialog(
    barrierDismissible: true,
    context: Get.context!,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Delete'.tr, style: Theme.of(context).textTheme.bodyLarge),
        content: Text(
          'Are you sure you want to delete this item?'.tr,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("NO".tr),
          ),
          TextButton(
            onPressed: () async {
              // Close the dialog immediately before performing logout
              Navigator.of(context).pop();
              onYes?.call();
            },
            child: Text("YES".tr),
          ),
        ],
      );
    },
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
        // Image.network(
        //   'https://i.ibb.co/680r20H/congratulations-illustration.png',
        //   height: 150,
        //   fit: BoxFit.contain,
        // ),
        SizedBox(height: 20.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Congratulations',
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
          'Your account is ready to use',
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
              'Back to Home',
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
