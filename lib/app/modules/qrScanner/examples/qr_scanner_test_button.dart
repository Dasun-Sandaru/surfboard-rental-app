// Example: Add this button anywhere in your app to test the QR scanner

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/app/routes/app_pages.dart';
import 'package:surfboard_rental_app/utils/common/app_snack_bar.dart';

class QrScannerTestButton extends StatelessWidget {
  const QrScannerTestButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ElevatedButton.icon(
      onPressed: () async {
        // Navigate to QR scanner and wait for result
        final result = await Get.toNamed(Routes.QR_SCANNER);

        if (result != null) {
          // Show the scanned value
          AppSnackBar.success(
            title: 'QR Code Scanned',
            message: 'Value: $result',
          );

          // You can use the result for your logic here
          log('Scanned QR Code: $result');

          // Examples:
          // - Navigate to a rental by ID: Get.toNamed(Routes.RENTAL_DETAIL, arguments: result);
          // - Load customer details: Get.toNamed(Routes.CUSTOMER_DETAILS, arguments: result);
          // - Load board details: Get.toNamed(Routes.ITEM_DETAILS, arguments: result);
        } else {
          // User closed scanner without scanning
          AppSnackBar.info(
            title: 'Cancelled',
            message: 'QR scan was cancelled',
          );
        }
      },
      icon: const Icon(Iconsax.scan_barcode),
      label: const Text('Scan QR Code'),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    );
  }
}

// Usage in any widget:
//
// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     body: Center(
//       child: QrScannerTestButton(),
//     ),
//   );
// }
