import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../../../models/customer_model.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/theme/app_material_theme.dart';
import '../controllers/customer_details_controller.dart';
import '../../../../app/services/config_service.dart';

class CustomerDetailsView extends GetView<CustomerDetailsController> {
  CustomerDetailsView({super.key});

  final ConfigService _configService = Get.find<ConfigService>();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "customer_profile".tr,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Obx(() {
            final canEdit =
                _configService.staffAccessRules['customers_edit'] ?? false;

            if (!canEdit) return const SizedBox.shrink();

            return TextButton(
              onPressed: controller.editCustomer,
              child: Text(
                "edit".tr,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final customer = controller.customer.value;
        if (customer == null) {
          return Center(child: Text('customer_not_found'.tr));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(ASizes.defaultPadding),
          child: Column(
            children: [
              /// 1. Profile Header & Actions
              _buildProfileHeader(context, controller, customer),

              SizedBox(height: 24.h),

              /// 2. Personal Info Card
              _buildInfoCard(context, customer),

              SizedBox(height: 24.h),

              /// 3. History Section
              _buildSectionHeader(context, "rental_history".tr),
              SizedBox(height: 12.h),
              _buildHistoryList(context, controller),

              SizedBox(height: 40.h),
            ],
          ),
        );
      }),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildProfileHeader(
    BuildContext context,
    CustomerDetailsController controller,
    CustomerModel customer,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        // Avatar
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: colorScheme.primary, width: 2),
          ),
          child: CircleAvatar(
            radius: 40.w,
            backgroundColor: colorScheme.surfaceContainer,
            backgroundImage:
                customer.imageUrl != null && customer.imageUrl!.isNotEmpty
                ? NetworkImage(customer.imageUrl!)
                : null,
            child: customer.imageUrl == null || customer.imageUrl!.isEmpty
                ? Text(
                    customer.firstName.isNotEmpty ? customer.firstName[0] : 'C',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 32.sp,
                    ),
                  )
                : null,
          ),
        ),
        SizedBox(height: 12.h),

        // Name
        Text(
          "${customer.firstName} ${customer.lastName}",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),

        // Rating Stars
        if (customer.ratingCount > 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ...List.generate(5, (index) {
                final isFilled = index < customer.averageRating.round();
                return Icon(
                  isFilled ? Iconsax.star5 : Iconsax.star,
                  color: isFilled ? Colors.amber : colorScheme.outline,
                  size: 16.w,
                );
              }),
              SizedBox(width: 8.w),
              Text(
                "${customer.averageRating.toStringAsFixed(1)} (${customer.ratingCount})",
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
        ],

        // ID Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outline),
          ),
          child: Text(
            "ID: ${customer.id ?? 'N/A'}",
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),

        SizedBox(height: 20.h),

        // Action Buttons Row (Scrollable to prevent overflow)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(width: ASizes.defaultPadding),
              Obx(() {
                final canContact =
                    _configService.staffAccessRules['customer_contact'] ??
                    false;

                if (!canContact) return const SizedBox.shrink();

                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildActionButton(
                      context,
                      icon: Iconsax.call,
                      label: "call".tr,
                      onTap: controller.makeCall,
                    ),
                    SizedBox(width: 16.w),
                    _buildActionButton(
                      context,
                      icon: Iconsax.sms,
                      label: "message".tr,
                      onTap: controller.makeCall,
                    ),
                    SizedBox(width: 16.w),
                    _buildActionButton(
                      context,
                      icon: Iconsax.direct,
                      label: "email".tr,
                      onTap: controller.sendEmail,
                    ),
                    SizedBox(width: 16.w),
                  ],
                );
              }),
              _buildActionButton(
                context,
                icon: Iconsax.scan_barcode4,
                label: "my_qr".tr,
                onTap: controller.showQR,
              ),
              SizedBox(width: ASizes.defaultPadding),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80.w,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.primary, size: 24.w),
            SizedBox(height: 6.h),
            Text(
              label,
              style: TextStyle(color: colorScheme.onSurface, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, CustomerModel customer) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _buildDetailRow(context, "phone".tr, customer.phone, Iconsax.call),
          Divider(color: colorScheme.outline, height: 24.h),
          _buildDetailRow(context, "email".tr, customer.email, Iconsax.sms),
          Divider(color: colorScheme.outline, height: 24.h),
          _buildDetailRow(
            context,
            "nic_passport".tr,
            customer.nic,
            Iconsax.card,
          ),
          Divider(color: colorScheme.outline, height: 24.h),
          _buildDetailRow(
            context,
            "notes".tr,
            customer.notes,
            Iconsax.note,
            isMultiLine: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    bool isMultiLine = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: isMultiLine
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: colorScheme.onSurfaceVariant, size: 20.w),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    CustomerDetailsController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>();

    return Obx(() {
      if (controller.isLoadingRentals.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.recentRentals.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(16.h),
            child: Text("no_recent_activity".tr, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.recentRentals.length,
        separatorBuilder: (c, i) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final rental = controller.recentRentals[index];
          
          final isLate = rental.status == RentalStatus.overdue;
          final isReturned = rental.status == RentalStatus.completed;
          
          Color statusColor = statusColors?.info ?? Colors.blue;
          String statusText = "active_label".tr; // assuming this key exists or just fallback to Active
          
          if (isLate) {
             statusColor = statusColors?.warning ?? Colors.orange;
             statusText = "late_return".tr;
          } else if (isReturned) {
             statusColor = statusColors?.success ?? Colors.green;
             statusText = "returned_label".tr;
          }
          
          final date = rental.createdAt;
          final day = DateFormat('dd').format(date);
          final month = DateFormat('MMM').format(date);
          
          final itemName = rental.cachedItemName?.isNotEmpty == true 
              ? rental.cachedItemName! 
              : "Item #${(rental.itemId.length >= 5) ? rental.itemId.substring(0, 5) : rental.itemId}";
              
          final durationHours = rental.expectedReturnTime.difference(rental.startTime).inHours;
          final durationStr = rental.rentType == RentType.daily 
              ? "${(durationHours / 24).ceil()} Days"
              : "$durationHours Hours";

          return Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Row(
              children: [
                // Date Box
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        day,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        month,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemName,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Iconsax.clock,
                            size: 14.w,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "$durationStr • \$${rental.amountExpected.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontSize: 12.sp,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Status Pill
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    });
  }
}
