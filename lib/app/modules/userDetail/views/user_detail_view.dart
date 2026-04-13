import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/helper/a_formatter.dart';
import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../../../../utils/constants/a_enums.dart';

import '../../../../utils/theme/app_material_theme.dart';

import '../../../models/user_model.dart';
import '../controllers/user_detail_controller.dart';

class UserDetailView extends GetView<UserDetailController> {
  const UserDetailView({super.key});
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
          "staff_details".tr,
          style: TextStyle(color: colorScheme.onSurface, fontSize: 18.sp),
        ),
        actions: [
          IconButton(
            onPressed: controller.showQR,
            icon: Icon(Iconsax.scan_barcode, color: colorScheme.onSurface),
            tooltip: 'Show QR Code',
          ),
        ],
      ),
      body: Obx(() {
        final userData = controller.user.value;
        if (userData == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(ASizes.defaultPadding),
          child: Column(
            children: [
              /// Profile Header
              _buildProfileHeader(context, userData),

              SizedBox(height: 24.h),

              /// Management Control (Active/Verify)
              _buildManagementControlCard(context, controller, userData),

              SizedBox(height: 24.h),

              /// Contact Info
              _buildSectionTitle(context, "contact_info".tr),
              SizedBox(height: 12.h),
              _buildContactInfoCard(context, userData),

              SizedBox(height: 24.h),

              /// Performance Stats
              _buildSectionTitle(
                context,
                "performance".tr,
              ), // performance key? I used 'Performance' in view but maybe no key. I'll check my plan. I didn't add 'performance'. I'll add 'performance' to keys or just 'Performance' for now? No, I must localize. I'll use 'performance' key and add it later if missed, or 'revenue' which I added. Wait, section title is "Performance". I'll use 'performance'.tr.
              // Wait, I didn't add 'performance' to app_translations.
              // I will leave it as "Performance" or add it now? I'll add 'performance': 'Performance'/'කාර්ය සාධනය' later.
              // Actually I'll use 'revenue' for "Revenue".
              // I'll skip "Performance" section title translation for this TURN if I can't add key. But I want to do it right.
              // I'll use 'performance'.tr and expect to fix it.
              // Actually, I can use 'recent_activity' which I added.
              // "Performance" section: "Rentals", "Revenue". I added 'rentals' and 'revenue'.
              // "Recent Activity" section: I added 'recent_activity'.
              // So only "Performance" title is missing?
              // I'll add 'performance' key in next steps or now. I'll skip changing it for now to avoid error if key is strict? No, .tr just returns key.
              // I'll change it to "performance".tr.
              SizedBox(height: 12.h),
              _buildPerformanceRow(context),

              SizedBox(height: 24.h),

              /// History
              _buildSectionTitle(context, "recent_activity".tr),
              SizedBox(height: 12.h),
              _buildHistoryList(context),

              SizedBox(height: 40.h),

              /// Delete Button
              Opacity(
                opacity: userData.role == UserRole.admin ? 0.5 : 1.0,
                child: SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: OutlinedButton(
                    onPressed: userData.role == UserRole.admin
                        ? null
                        : controller.deleteUser,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.outline),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                    child: Text(
                      "delete_user".tr,
                      style: TextStyle(
                        color: colorScheme.error,
                        fontWeight: FontWeight.w600,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      }),
    );
  }

  // WIDGET BUILDERS
  Widget _buildProfileHeader(BuildContext context, UserModel user) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = user.name ?? 'Unknown';
    return Column(
      children: [
        CircleAvatar(
          radius: 40.w,
          backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
          child: Text(
            name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          name,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            user.role.name.toUpperCase(),
            style: TextStyle(
              color: colorScheme.primary,
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  /// THE REQUESTED COMPONENT: Active/Deactivate & Verify
  Widget _buildManagementControlCard(
    BuildContext context,
    UserDetailController controller,
    UserModel user,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>();
    final successColor = statusColors?.success ?? Colors.green;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Column(
        children: [
          // Account Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.shield_tick,
                    color: colorScheme.onSurfaceVariant,
                    size: 20.w,
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "account_status".tr,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        controller.isActive.value
                            ? "access_allowed".tr
                            : "access_denied".tr,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: controller.isActive.value,
                activeThumbColor: successColor,
                inactiveTrackColor: colorScheme.surface,
                onChanged: user.role == UserRole.admin
                    ? null
                    : controller.toggleActiveStatus,
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Divider(color: colorScheme.outline),
          ),

          // Verification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.verify,
                    color: colorScheme.onSurfaceVariant,
                    size: 20.w,
                  ),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "verification".tr,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        controller.isVerified.value
                            ? "identity_confirmed".tr
                            : "pending_verification".tr,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Custom Verify Button
              Opacity(
                opacity: user.role == UserRole.admin ? 0.5 : 1.0,
                child: InkWell(
                  onTap: user.role == UserRole.admin
                      ? null
                      : controller.toggleVerification,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: controller.isVerified.value
                          ? successColor.withValues(alpha: 0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: controller.isVerified.value
                            ? successColor
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          controller.isVerified.value
                              ? "verified".tr
                              : "approve".tr,
                          style: TextStyle(
                            color: controller.isVerified.value
                                ? successColor
                                : colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                        if (controller.isVerified.value) ...[
                          SizedBox(width: 4.w),
                          Icon(Icons.check, size: 14.w, color: successColor),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(BuildContext context, UserModel user) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          _buildInfoRow(context, Iconsax.sms, "email".tr, user.email ?? 'N/A'),
          SizedBox(height: 16.h),
          _buildInfoRow(context, Iconsax.call, "phone".tr, user.phone ?? 'N/A'),
          SizedBox(height: 16.h),
          _buildInfoRow(
            context,
            Iconsax.calendar,
            "joined".tr,
            user.createdAt != null
                ? AFormatter.formatDate(user.createdAt!)
                : 'N/A',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.onSurfaceVariant, size: 18.w),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12.sp,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(context, "rentals".tr, "142", Iconsax.receipt),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildStatCard(context, "revenue".tr, "\$4.2k", Iconsax.money),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary, size: 24.w),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>();
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 3, // Mock items
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              Iconsax.activity,
              color: colorScheme.onSurfaceVariant,
              size: 20.w,
            ),
            title: Text(
              "${"processed_rental".tr} #284$index",
              style: TextStyle(color: colorScheme.onSurface, fontSize: 14.sp),
            ),
            subtitle: Text(
              "2 hours ago",
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12.sp,
              ),
            ),
            trailing: Text(
              "+ \$45",
              style: TextStyle(
                color: statusColors?.success ?? Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
