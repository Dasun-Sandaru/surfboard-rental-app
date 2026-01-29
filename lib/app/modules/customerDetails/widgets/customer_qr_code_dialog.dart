import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../models/customer_model.dart';

class CustomerQrCodeDialog extends StatelessWidget {
  final CustomerModel customer;

  const CustomerQrCodeDialog({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 350),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Customer QR',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Icons.close,
                    color: colorScheme.onSurfaceVariant,
                    size: 20.w,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Customer Info - Simplified
            // Container(
            //   padding: EdgeInsets.all(12.w),
            //   decoration: BoxDecoration(
            //     color: colorScheme.surface,
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            //   child: Row(
            //     children: [
            //       CircleAvatar(
            //         radius: 20.w,
            //         backgroundColor: colorScheme.primary.withOpacity(0.1),
            //         backgroundImage:
            //             customer.imageUrl != null &&
            //                 customer.imageUrl!.isNotEmpty
            //             ? NetworkImage(customer.imageUrl!)
            //             : null,
            //         child:
            //             customer.imageUrl == null || customer.imageUrl!.isEmpty
            //             ? Text(
            //                 customer.firstName.isNotEmpty
            //                     ? customer.firstName[0]
            //                     : 'C',
            //                 style: TextStyle(
            //                   color: colorScheme.primary,
            //                   fontSize: 16.sp,
            //                   fontWeight: FontWeight.bold,
            //                 ),
            //               )
            //             : null,
            //       ),
            //       SizedBox(width: 10.w),
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               '${customer.firstName} ${customer.lastName}',
            //               style: TextStyle(
            //                 color: colorScheme.onSurface,
            //                 fontSize: 14.sp,
            //                 fontWeight: FontWeight.bold,
            //               ),
            //               maxLines: 1,
            //               overflow: TextOverflow.ellipsis,
            //             ),
            //             Text(
            //               customer.email,
            //               style: TextStyle(
            //                 color: colorScheme.onSurfaceVariant,
            //                 fontSize: 11.sp,
            //               ),
            //               maxLines: 1,
            //               overflow: TextOverflow.ellipsis,
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),

            // SizedBox(height: 16.h),

            // QR Code
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline),
              ),
              child: QrImageView(
                data: customer.id ?? 'unknown',
                version: QrVersions.auto,
                size: 180.w,
                backgroundColor: Colors.white,
                errorStateBuilder: (context, error) {
                  return Center(
                    child: Text(
                      'QR Code Error',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
            ),

            SizedBox(height: 12.h),

            // Customer ID
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Iconsax.card,
                    size: 14.w,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      customer.id ?? 'N/A',
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'monospace',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),

            // Info Text
            Text(
              'Scan to view customer',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
