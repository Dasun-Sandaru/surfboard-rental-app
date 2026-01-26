import 'dart:developer';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../../../../utils/constants/a_enums.dart';

import '../controllers/user_detail_controller.dart';

class UserDetailView extends GetView<UserDetailController> {
  const UserDetailView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "Staff Details",
          style: TextStyle(color: textWhite, fontSize: 18.sp),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: Icon(Iconsax.edit, color: textWhite),
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        child: Column(
          children: [
            /// Profile Header
            Obx(() => _buildProfileHeader(controller)),

            SizedBox(height: 24.h),

            /// Management Control (Active/Verify)
            _buildManagementControlCard(controller),

            SizedBox(height: 24.h),

            /// Contact Info
            _buildSectionTitle("Contact Information"),
            SizedBox(height: 12.h),
            _buildContactInfoCard(controller),

            SizedBox(height: 24.h),

            /// Performance Stats
            _buildSectionTitle("Performance"),
            SizedBox(height: 12.h),
            _buildPerformanceRow(),

            SizedBox(height: 24.h),

            /// History
            _buildSectionTitle("Recent Activity"),
            SizedBox(height: 12.h),
            _buildHistoryList(),

            SizedBox(height: 40.h),

            /// Delete Button
            Opacity(
              opacity: controller.user.value?.role == UserRole.admin
                  ? 0.5
                  : 1.0,
              child: SizedBox(
                width: double.infinity,
                height: 54.h,
                child: OutlinedButton(
                  onPressed: controller.user.value?.role == UserRole.admin
                      ? null
                      : controller.deleteUser,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: borderDark),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: Text(
                    "Delete User",
                    style: TextStyle(
                      color: errorRed,
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
      ),
    );
  }

  // WIDGET BUILDERS
  Widget _buildProfileHeader(UserDetailController controller) {
    log("Building profile header for user: ${controller.user.value?.name}");
    return Column(
      children: [
        CircleAvatar(
          radius: 40.w,
          backgroundColor: primaryBlue.withOpacity(0.2),
          child: Text(
            (controller.user.value?.name != null &&
                    controller.user.value!.name!.toString().isNotEmpty)
                ? controller.user.value!.name!
                      .toString()
                      .substring(0, 1)
                      .toUpperCase()
                : '',
            style: TextStyle(
              fontSize: 32.sp,
              fontWeight: FontWeight.bold,
              color: primaryBlue,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          controller.user.value?.name?.toString() ?? 'N/A',
          style: TextStyle(
            color: textWhite,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: primaryBlue.withOpacity(0.3)),
          ),
          child: Text(
            controller.user.value?.role.name.toUpperCase() ?? 'N/A',
            style: TextStyle(
              color: primaryBlue,
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
  Widget _buildManagementControlCard(UserDetailController controller) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderDark),
      ),
      child: Column(
        children: [
          // Account Status
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.shield_tick, color: textGrey, size: 20.w),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Account Status",
                          style: TextStyle(
                            color: textWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          controller.isActive.value
                              ? "User can access app"
                              : "Access denied",
                          style: TextStyle(color: textGrey, fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ],
                ),
                Switch(
                  value: controller.isActive.value,
                  activeColor: successGreen,
                  inactiveTrackColor: bgDark,
                  onChanged: controller.user.value!.role == UserRole.admin
                      ? null
                      : controller.toggleActiveStatus,
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            child: Divider(color: borderDark),
          ),

          // Verification
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.verify, color: textGrey, size: 20.w),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Verification",
                          style: TextStyle(
                            color: textWhite,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          controller.isVerified.value
                              ? "Identity confirmed"
                              : "Pending verification",
                          style: TextStyle(color: textGrey, fontSize: 12.sp),
                        ),
                      ],
                    ),
                  ],
                ),

                // Custom Verify Button
                Opacity(
                  opacity: controller.user.value!.role == UserRole.admin
                      ? 0.5
                      : 1.0,
                  child: InkWell(
                    onTap: controller.user.value!.role == UserRole.admin
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
                            ? successGreen.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: controller.isVerified.value
                              ? successGreen
                              : textGrey,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text(
                            controller.isVerified.value
                                ? "Verified"
                                : "Approve",
                            style: TextStyle(
                              color: controller.isVerified.value
                                  ? successGreen
                                  : textGrey,
                              fontWeight: FontWeight.bold,
                              fontSize: 12.sp,
                            ),
                          ),
                          if (controller.isVerified.value) ...[
                            SizedBox(width: 4.w),
                            Icon(Icons.check, size: 14.w, color: successGreen),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(UserDetailController controller) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderDark.withOpacity(0.5)),
      ),
      child: Obx(
        () => Column(
          children: [
            _buildInfoRow(
              Iconsax.sms,
              "Email",
              controller.user.value!.email.toString(),
            ),
            SizedBox(height: 16.h),
            _buildInfoRow(
              Iconsax.call,
              "Phone",
              controller.user.value!.phone.toString(),
            ),
            SizedBox(height: 16.h),
            _buildInfoRow(
              Iconsax.calendar,
              "Joined",
              controller.user.value!.createdAt != null
                  ? DateFormat.yMMMd().format(controller.user.value!.createdAt!)
                  : 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: bgDark,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: textGrey, size: 18.w),
        ),
        SizedBox(width: 16.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: textGrey, fontSize: 12.sp),
            ),
            Text(
              value,
              style: TextStyle(color: textWhite, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPerformanceRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard("Rentals", "142", Iconsax.receipt)),
        SizedBox(width: 12.w),
        Expanded(child: _buildStatCard("Revenue", "\$4.2k", Iconsax.money)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderDark.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryBlue, size: 24.w),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              color: textWhite,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: textGrey, fontSize: 12.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 3, // Mock items
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(Iconsax.activity, color: textGrey, size: 20.w),
            title: Text(
              "Processed Rental #284$index",
              style: TextStyle(color: textWhite, fontSize: 14.sp),
            ),
            subtitle: Text(
              "2 hours ago",
              style: TextStyle(color: textGrey, fontSize: 12.sp),
            ),
            trailing: Text(
              "+ \$45",
              style: TextStyle(
                color: successGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: textWhite,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// -- Theme Colors --
final Color bgDark = const Color(0xFF101f22);
final Color cardDark = const Color(0xFF182c30);
final Color primaryBlue = const Color(0xFF4A90E2);
final Color textWhite = const Color(0xFFf0f4f4);
final Color textGrey = const Color(0xFF94a3b8);
final Color borderDark = const Color(0xFF334155);
final Color successGreen = const Color(0xFF34C759);
final Color errorRed = const Color(0xFFEF4444);
