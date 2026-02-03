import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/helper/a_formatter.dart';
import '../../../models/damage_report_model.dart';
import '../../../models/payment_model.dart';
import '../../../models/damage_photo_model.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../controllers/rental_detail_controller.dart';

class RentalDetailView extends GetView<RentalDetailController> {
  const RentalDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final rental = controller.rental;

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'rental_details'.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp),
          ),
          centerTitle: true,
          backgroundColor: colorScheme.surface,
          scrolledUnderElevation: 0,
          bottom: TabBar(
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: colorScheme.primary,
            dividerColor: Colors.transparent,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            padding: EdgeInsets.zero,
            labelPadding: EdgeInsets.symmetric(horizontal: 16.w),
            tabs: [
              Tab(text: "overview".tr),
              Tab(text: "financials".tr),
              Tab(text: "damages".tr),
              Tab(text: "documents".tr),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // ---------------- TAB 1: OVERVIEW ----------------
            SingleChildScrollView(
              padding: EdgeInsets.all(ASizes.defaultPadding),
              child: Column(
                children: [
                  _buildStatusCard(context, rental),
                  SizedBox(height: 16.h),
                  _buildSection(
                    context,
                    title: "rental_info".tr,
                    icon: Iconsax.box,
                    children: [
                      _buildInfoRow(
                        context,
                        "item".tr,
                        rental.cachedItemName ?? "unknown".tr,
                        icon: Iconsax.code_circle,
                      ),
                      _buildInfoRow(
                        context,
                        "rent_type".tr,
                        rental.rentType
                            .toString()
                            .split('.')
                            .last
                            .capitalizeFirst!,
                        icon: Iconsax.timer_1,
                      ),
                      _buildInfoRow(
                        context,
                        "rental_id".tr,
                        "#${rental.id?.substring(0, 8) ?? '---'}",
                        icon: Iconsax.hashtag,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildSection(
                    context,
                    title: "people".tr,
                    icon: Iconsax.people,
                    children: [
                      _buildInfoRow(
                        context,
                        "customer".tr,
                        rental.cachedCustomerName ?? "unknown".tr,
                        icon: Iconsax.user,
                      ),
                      _buildInfoRow(
                        context,
                        "staff_member".tr,
                        rental.cachedStaffName ?? "Unknown",
                        icon: Iconsax.personalcard,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  _buildSection(
                    context,
                    title: "timings".tr,
                    icon: Iconsax.calendar,
                    children: [
                      _buildInfoRow(
                        context,
                        "start_time".tr,
                        _formatDate(rental.startTime),
                        icon: Iconsax.calendar_add,
                      ),
                      _buildInfoRow(
                        context,
                        "expected_return".tr,
                        _formatDate(rental.expectedReturnTime),
                        icon: Iconsax.calendar_edit,
                      ),
                      if (rental.actualReturnTime != null)
                        _buildInfoRow(
                          context,
                          "actual_return".tr,
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
                          "overdue_duration".tr,
                          rental.overdueTime!,
                          icon: Iconsax.clock,
                          valueColor: Colors.red,
                        ),
                    ],
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),

            // ---------------- TAB 2: FINANCIALS ----------------
            SingleChildScrollView(
              padding: EdgeInsets.all(ASizes.defaultPadding),
              child: Column(
                children: [
                  _buildSection(
                    context,
                    title: "financials".tr,
                    icon: Iconsax.money_3,
                    children: [
                      _buildInfoRow(
                        context,
                        "rate".tr,
                        "${AFormatter.formatCurrency(rental.rate)}/ ${rental.rentType.toString().split('.').last == 'hourly' ? 'hourly'.tr : 'daily'.tr}",
                        icon: Iconsax.tag,
                      ),
                      _buildInfoRow(
                        context,
                        "total_expected".tr,
                        AFormatter.formatCurrency(rental.amountExpected),
                        icon: Iconsax.money_tick,
                        isBold: true,
                      ),
                      _buildInfoRow(
                        context,
                        "amount_paid".tr,
                        AFormatter.formatCurrency(rental.amountPaid),
                        icon: Iconsax.wallet_2,
                        valueColor: rental.paymentStatus == PaymentStatus.paid
                            ? Colors.green
                            : colorScheme.primary,
                      ),
                      Divider(),
                      _buildInfoRow(
                        context,
                        "security_deposit".tr,
                        AFormatter.formatCurrency(
                          rental.securityDeposit.amount,
                        ),
                        icon: Iconsax.shield_tick,
                      ),
                      _buildInfoRow(
                        context,
                        "deposit_status".tr,
                        rental.securityDeposit.refunded > 0
                            ? "refunded".tr
                            : (rental.securityDeposit.paid > 0
                                  ? "held".tr
                                  : "not_paid".tr),
                        icon: Iconsax.info_circle,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Obx(() {
                    if (controller.payments.isEmpty) {
                      return _buildEmptyState(
                        context,
                        "no_payments".tr,
                        Iconsax.receipt_item,
                      );
                    }
                    return _buildSection(
                      context,
                      title: "payment_history".tr,
                      icon: Iconsax.receipt,
                      children: controller.payments
                          .map((payment) => _buildPaymentRow(context, payment))
                          .toList(),
                    );
                  }),
                  SizedBox(height: 32.h),
                ],
              ),
            ),

            // ---------------- TAB 3: DAMAGES ----------------
            SingleChildScrollView(
              padding: EdgeInsets.all(ASizes.defaultPadding),
              child: Obx(() {
                if (controller.damageReports.isEmpty) {
                  return Container(
                    margin: EdgeInsets.only(top: 50.h),
                    child: _buildEmptyState(
                      context,
                      "no_damages".tr,
                      Iconsax.shield_tick,
                    ),
                  );
                }
                return Column(
                  children: controller.damageReports
                      .map((report) => _buildDamageRow(context, report))
                      .toList(),
                );
              }),
            ),

            // ---------------- TAB 4: DOCUMENTS ----------------
            SingleChildScrollView(
              padding: EdgeInsets.all(ASizes.defaultPadding),
              child: Column(
                children: [
                  _buildDocumentCard(
                    context,
                    title: "rental_agreement".tr,
                    subtitle: "signed_agreement_msg".tr,
                    icon: Iconsax.document_text,
                    onTap: () => controller.openDocument(rental.agreementLink),
                    isAvailable: rental.agreementLink != null,
                  ),
                  SizedBox(height: 16.h),
                  _buildDocumentCard(
                    context,
                    title: "invoice".tr,
                    subtitle: "rental_invoice_msg".tr,
                    icon: Iconsax.receipt_2,
                    onTap: () => controller.openDocument(rental.invoiceLink),
                    isAvailable: rental.invoiceLink != null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isAvailable,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: isAvailable ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withValues(
              alpha: isAvailable ? 0.5 : 0.2,
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isAvailable ? colorScheme.primary : Colors.grey)
                    .withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isAvailable ? colorScheme.primary : Colors.grey,
                size: 24,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.sp,
                      color: isAvailable ? colorScheme.onSurface : Colors.grey,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    isAvailable ? subtitle : "not_available".tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Iconsax.arrow_right_3,
              size: 18,
              color: isAvailable ? colorScheme.primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: colorScheme.outline.withValues(alpha: 0.5),
          ),
          SizedBox(height: 12.h),
          Text(message, style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ],
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
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                payment.category.toString().split('.').last.capitalizeFirst!,
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
            "+ ${AFormatter.formatCurrency(payment.amount)}",
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
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
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
                  color: Colors.red.withValues(alpha: 0.1),
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
                    separatorBuilder: (_, _) => SizedBox(width: 8.w),
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
                    "${"cost".tr}: ${AFormatter.formatCurrency(report.finalCost)}",
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
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(statusIcon, color: statusColor, size: 24),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                rental.status.toString().split('.').last.tr.toUpperCase(),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                  letterSpacing: 1.2,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                "${"payment".tr}: ${rental.paymentStatus.toString().split('.').last.tr.toUpperCase()}",
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
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
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
          Divider(color: colorScheme.outline.withValues(alpha: 0.3), height: 1),
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
    return AFormatter.formatDate(date);
  }
}