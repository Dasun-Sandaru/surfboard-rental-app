import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';
import 'package:surfboard_rental_app/app/models/customer_model.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/theme/app_material_theme.dart';
import '../controllers/customer_details_controller.dart';

class CustomerDetailsView extends GetView<CustomerDetailsController> {
  const CustomerDetailsView({super.key});

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
          "Customer Profile",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: controller.editCustomer,
            child: Text(
              "Edit",
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final customer = controller.customer.value;
        if (customer == null) {
          return const Center(child: Text('Customer not found'));
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
              _buildSectionHeader(context, "Rental History"),
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
              _buildActionButton(
                context,
                icon: Iconsax.call,
                label: "Call",
                onTap: controller.makeCall,
              ),
              SizedBox(width: 16.w),
              _buildActionButton(
                context,
                icon: Iconsax.sms,
                label: "Message",
                onTap: controller.makeCall,
              ),
              SizedBox(width: 16.w),
              _buildActionButton(
                context,
                icon: Iconsax.direct,
                label: "Email",
                onTap: controller.sendEmail,
              ),
              SizedBox(width: 16.w),
              _buildActionButton(
                context,
                icon: Iconsax.scan_barcode4,
                label: "My QR",
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
        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildDetailRow(context, "Phone", customer.phone, Iconsax.call),
          Divider(color: colorScheme.outline, height: 24.h),
          _buildDetailRow(context, "Email", customer.email, Iconsax.sms),
          Divider(color: colorScheme.outline, height: 24.h),
          _buildDetailRow(
            context,
            "NIC / Passport",
            customer.nic,
            Iconsax.card,
          ),
          Divider(color: colorScheme.outline, height: 24.h),
          _buildDetailRow(
            context,
            "Notes",
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

    return Obx(
      () => ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: controller.history.length,
        separatorBuilder: (c, i) => SizedBox(height: 12.h),
        itemBuilder: (context, index) {
          final item = controller.history[index];
          final bool isLate = item['status'] == "Late Return";
          final Color statusColor = isLate
              ? (statusColors?.warning ?? Colors.orange)
              : (statusColors?.success ?? Colors.green);

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
                        item['date'].split(' ')[0], // Day
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        item['date'].split(' ')[1], // Month
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
                        item['items'],
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
                            "${item['duration']} • ${item['cost']}",
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
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['status'],
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
      ),
    );
  }
}
