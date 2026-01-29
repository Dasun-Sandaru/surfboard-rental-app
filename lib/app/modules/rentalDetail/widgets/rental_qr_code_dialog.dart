import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../models/rental_model.dart';

class RentalQrCodeDialog extends StatelessWidget {
  final RentalModel rental;

  const RentalQrCodeDialog({super.key, required this.rental});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('MMM dd');

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
                  'Rental QR',
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

            // Rental Info - Simplified
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Customer & Item
                  Row(
                    children: [
                      Icon(
                        Icons.surfing,
                        color: colorScheme.primary,
                        size: 20.w,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rental.cachedCustomerName ?? 'Customer',
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              rental.cachedItemName ?? 'Item',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 11.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  // Dates - Compact
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildDateChip(
                        context,
                        dateFormat.format(rental.startTime),
                        'Start',
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.w),
                        child: Icon(
                          Iconsax.arrow_right_3,
                          size: 14.w,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      _buildDateChip(
                        context,
                        dateFormat.format(rental.expectedReturnTime),
                        'Due',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // QR Code
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colorScheme.outline),
              ),
              child: QrImageView(
                data: rental.id ?? 'unknown',
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

            // Rental ID
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
                    Iconsax.receipt,
                    size: 14.w,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      rental.id ?? 'N/A',
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
              'Scan to view rental',
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

  Widget _buildDateChip(BuildContext context, String date, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 9.sp,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            date,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
