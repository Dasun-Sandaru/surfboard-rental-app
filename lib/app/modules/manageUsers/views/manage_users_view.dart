import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../controllers/manage_users_controller.dart';

class ManageUsersView extends GetView<ManageUsersController> {
  const ManageUsersView({super.key});

  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22);
  final Color cardDark = const Color(0xFF182c30);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color borderDark = const Color(0xFF334155);
  final Color successGreen = const Color(0xFF34C759);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          'User Management',
          style: TextStyle(
            color: textWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: controller.addUser,
            icon: Icon(Iconsax.add, color: primaryBlue, size: 20.w),
            label: Text(
              "Add",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: ASizes.defaultPadding),
        child: Column(
          children: [
            SizedBox(height: 16.h),

            /// Search Bar
            TextFormField(
              controller: controller.searchTextController,
              style: TextStyle(color: textWhite),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Iconsax.search_normal,
                  size: 20.w,
                  color: textGrey,
                ),
                hintText: 'Search by name or email',
                hintStyle: TextStyle(color: textGrey.withOpacity(0.5)),
                filled: true,
                fillColor: cardDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),

            SizedBox(height: 20.h),

            /// User List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderDark.withOpacity(0.5)),
                ),
              
                child: Obx(() {
                  if (controller.users.isEmpty) {
                    return _buildEmptyList();
                  }
                  return ListView.separated(
                    itemCount: controller.users.length,
                    padding: EdgeInsets.zero,
                    separatorBuilder: (context, index) =>
                        Divider(color: borderDark.withOpacity(0.5), height: 1),
                    itemBuilder: (context, index) {
                      final user = controller.users[index];
                      return _buildUserListItem(user);
                    },
                  );
                }),
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  // HELPER WIDGETS

  Widget _buildEmptyList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.user_search,
            size: 60.w,
            color: textGrey.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'No users found',
            style: TextStyle(color: textGrey, fontSize: 16.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListItem(Map<String, dynamic> user) {
    final bool isAdmin = user['role'] == 'Admin';
    final bool isActive = user['is_active'];
    final Color avatarColor = user['color'];

    return InkWell(
      onTap: () => controller.viewUserDetails(user),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          children: [
            /// Avatar
            Container(
              height: 48.w,
              width: 48.w,
              decoration: BoxDecoration(
                color: avatarColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  user['initials'],
                  style: TextStyle(
                    color: avatarColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ),
            ),

            SizedBox(width: 16.w),

            /// Info Column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'],
                    style: TextStyle(
                      color: textWhite,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    user['email'],
                    style: TextStyle(color: textGrey, fontSize: 13.sp),
                  ),
                  SizedBox(height: 8.h),

                  /// Tags Row
                  Row(
                    children: [
                      // Role Badge
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? primaryBlue.withOpacity(0.2)
                              : textGrey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user['role'],
                          style: TextStyle(
                            color: isAdmin ? primaryBlue : textGrey,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      // Verified Badge
                      if (user['verified'] == true)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: successGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Verified',
                            style: TextStyle(
                              color: successGreen,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                      SizedBox(width: 8.w),

                      // Status Badge
                      Row(
                        children: [
                          Container(
                            height: 6.w,
                            width: 6.w,
                            decoration: BoxDecoration(
                              color: isActive ? successGreen : textGrey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            user['is_active'] ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: isActive ? successGreen : textGrey,
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /// Arrow Icon
            Icon(Iconsax.arrow_right_3, color: textGrey, size: 20.w),
          ],
        ),
      ),
    );
  }
}
