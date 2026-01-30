import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:surfboard_rental_app/app/models/damage_report_model.dart';
import 'package:surfboard_rental_app/app/models/payment_model.dart';
import 'package:surfboard_rental_app/app/models/damage_photo_model.dart';
import 'package:surfboard_rental_app/utils/constants/a_enums.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';
import '../controllers/rental_detail_controller.dart';

class RentalDetailView extends GetView<RentalDetailController> {
  const RentalDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rental = controller.rental;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Rental details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
        scrolledUnderElevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        child: Column(
          children: [
            // 1. Status Card
            _buildStatusCard(context, rental),
            SizedBox(height: 16.h),

            // 2. Main Details (Item & Type)
            _buildSection(
              context,
              title: "Rental Info",
              icon: Iconsax.box,
              children: [
                _buildInfoRow(
                  context,
                  "Item",
                  rental.cachedItemName ?? "Unknown Item",
                  icon: Iconsax.code_circle,
                ),
                _buildInfoRow(
                  context,
                  "Rent Type",
                  rental.rentType.toString().split('.').last.capitalizeFirst!,
                  icon: Iconsax.timer_1,
                ),
                _buildInfoRow(
                  context,
                  "Rental ID",
                  "#${rental.id?.substring(0, 8) ?? '---'}",
                  icon: Iconsax.hashtag,
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // 3. Participants (Customer & Staff)
            _buildSection(
              context,
              title: "People",
              icon: Iconsax.people,
              children: [
                _buildInfoRow(
                  context,
                  "Customer",
                  rental.cachedCustomerName ?? "Unknown",
                  icon: Iconsax.user,
                ),
                _buildInfoRow(
                  context,
                  "Staff Member",
                  rental.cachedStaffName ?? "Unknown",
                  icon: Iconsax.personalcard,
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // 4. Timings
            _buildSection(
              context,
              title: "Timings",
              icon: Iconsax.calendar,
              children: [
                _buildInfoRow(
                  context,
                  "Start Time",
                  _formatDate(rental.startTime),
                  icon: Iconsax.calendar_add,
                ),
                _buildInfoRow(
                  context,
                  "Expected Return",
                  _formatDate(rental.expectedReturnTime),
                  icon: Iconsax.calendar_edit,
                ),
                if (rental.actualReturnTime != null)
                  _buildInfoRow(
                    context,
                    "Actual Return",
                    _formatDate(rental.actualReturnTime!),
                    icon: Iconsax.calendar_tick,
                    valueColor:
                        rental.actualReturnTime!.isAfter(
                          rental.expectedReturnTime,
                        )
                        ? Colors.red
                        : Colors.green,
                  ),
                if (rental.overdueTime != null)
                  _buildInfoRow(
                    context,
                    "Overdue Duration",
                    rental.overdueTime!,
                    icon: Iconsax.clock,
                    valueColor: Colors.red,
                  ),
              ],
            ),
            SizedBox(height: 16.h),

            // 5. Financials
            _buildSection(
              context,
              title: "Financials",
              icon: Iconsax.money_3,
              children: [
                _buildInfoRow(
                  context,
                  "Rate",
                  "${rental.rate}/ ${rental.rentType.toString().split('.').last == 'hourly' ? 'hr' : 'day'}",
                  icon: Iconsax.tag,
                ),
                _buildInfoRow(
                  context,
                  "Total Expected",
                  "${rental.amountExpected}",
                  icon: Iconsax.money_tick,
                  isBold: true,
                ),
                _buildInfoRow(
                  context,
                  "Amount Paid",
                  "${rental.amountPaid}",
                  icon: Iconsax.wallet_2,
                  valueColor: rental.paymentStatus == PaymentStatus.paid
                      ? Colors.green
                      : colorScheme.primary,
                ),
                Divider(),
                _buildInfoRow(
                  context,
                  "Security Deposit",
                  rental.securityDeposit.amount.toString(),
                  icon: Iconsax.shield_tick,
                ),
                _buildInfoRow(
                  context,
                  "Deposit Status",
                  rental.securityDeposit.refunded > 0
                      ? "Refunded"
                      : (rental.securityDeposit.paid > 0 ? "Held" : "Not Paid"),
                  icon: Iconsax.info_circle,
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // 6. Payment History
            Obx(() {
              if (controller.payments.isEmpty) return SizedBox.shrink();
              return _buildSection(
                context,
                title: "Payment History",
                icon: Iconsax.receipt,
                children: controller.payments
                    .map((payment) => _buildPaymentRow(context, payment))
                    .toList(),
              );
            }),

            // 7. Damage Reports
            Obx(() {
              if (controller.damageReports.isEmpty) return SizedBox.shrink();
              return Padding(
                padding: EdgeInsets.only(top: 16.h),
                child: _buildSection(
                  context,
                  title: "Damage Reports",
                  icon: Iconsax.warning_2,
                  children: controller.damageReports
                      .map((report) => _buildDamageRow(context, report))
                      .toList(),
                ),
              );
            }),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(BuildContext context, PaymentModel payment) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payment.category.name.capitalizeFirst!,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
              ),
              Text(
                _formatDate(payment.timestamp),
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11.sp,
                ),
              ),
            ],
          ),
          Text(
            "+ ${payment.amount}",
            style: TextStyle(
              color: Colors.green,
              fontWeight: FontWeight.bold,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDamageRow(BuildContext context, DamageReportModel report) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                report.damageType.replaceAll('_', ' ').capitalizeFirst!,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.sp,
                  color: Colors.red,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  report.status.toString().split('.').last.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (report.note != null && report.note!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                report.note!,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12.sp,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

          // Photos Section
          StreamBuilder<List<DamagePhotoModel>>(
            stream: controller.getDamagePhotos(report.id!),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return Container(
                  height: 80.h,
                  margin: EdgeInsets.only(top: 8.h),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8.w),
                    itemBuilder: (context, index) {
                      final photo = snapshot.data![index];
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          photo.photoUrl,
                          width: 80.h,
                          height: 80.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 80.h,
                                height: 80.h,
                                color: Colors.grey[300],
                                child: Icon(Iconsax.image, color: Colors.grey),
                              ),
                        ),
                      );
                    },
                  ),
                );
              }
              return SizedBox.shrink();
            },
          ),

          if (report.finalCost != null && report.finalCost! > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Cost: ${report.finalCost}",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, dynamic rental) {
    final colorScheme = Theme.of(context).colorScheme;
    Color statusColor;
    IconData statusIcon;

    switch (rental.status) {
      case RentalStatus.active:
        statusColor = Colors.blue;
        statusIcon = Iconsax.play;
        break;
      case RentalStatus.completed:
        statusColor = Colors.green;
        statusIcon = Iconsax.tick_circle;
        break;
      case RentalStatus.overdue:
        statusColor = Colors.red;
        statusIcon = Iconsax.warning_2;
        break;
      case RentalStatus.cancelled:
        statusColor = Colors.grey;
        statusIcon = Iconsax.close_circle;
        break;
      default:
        statusColor = colorScheme.primary;
        statusIcon = Iconsax.info_circle;
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rental.status.toString().split('.').last.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "Payment: ${rental.paymentStatus.toString().split('.').last.toUpperCase()}",
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                Icon(icon, size: 18, color: colorScheme.primary),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: colorScheme.outline.withOpacity(0.3), height: 1),
          SizedBox(height: 8.h),
          ...children,
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    IconData? icon,
    Color? valueColor,
    bool isBold = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
            SizedBox(width: 8.w),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13.sp,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? colorScheme.onSurface,
                fontSize: 13.sp,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
  }
}
