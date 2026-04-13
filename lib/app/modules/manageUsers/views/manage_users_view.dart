import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../models/user_model.dart';
import '../../../../utils/theme/app_material_theme.dart';
import '../controllers/manage_users_controller.dart';

class ManageUsersView extends GetView<ManageUsersController> {
  const ManageUsersView({super.key});

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
          'user_management'.tr,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        // actions: [
        //   TextButton.icon(
        //     onPressed: controller.addUser,
        //     icon: Icon(Iconsax.add, color: colorScheme.primary, size: 20.w),
        //     label: Text(
        //       "Add",
        //       style: TextStyle(
        //         color: colorScheme.primary,
        //         fontSize: 14.sp,
        //         fontWeight: FontWeight.w600,
        //       ),
        //     ),
        //   ),
        //   SizedBox(width: 8.w),
        // ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: ASizes.defaultPadding),
        child: Column(
          children: [
            SizedBox(height: 16.h),

            /// Search Bar
            TextFormField(
              controller: controller.searchTextController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Iconsax.search_normal,
                  size: 20.w,
                  color: colorScheme.onSurfaceVariant,
                ),
                hintText: 'search_user_hint'.tr,
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainer,
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
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.5),
                  ),
                ),
                child: Obx(() {
                  if (controller.filteredUsers.isEmpty) {
                    return _buildEmptyList(context);
                  }
                  return ListView.separated(
                    itemCount: controller.filteredUsers.length,
                    padding: EdgeInsets.zero,
                    separatorBuilder: (context, index) => Divider(
                      color: colorScheme.outline.withValues(alpha: 0.5),
                      height: 1,
                    ),
                    itemBuilder: (context, index) {
                      final user = controller.filteredUsers[index];
                      return _buildUserListItem(context, user);
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

  Widget _buildEmptyList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.user_search,
            size: 60.w,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'no_users_found'.tr,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserListItem(BuildContext context, UserModel user) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>();
    final successColor = statusColors?.success ?? Colors.green;

    final bool isAdmin = user.role == UserRole.admin;
    final bool isActive = user.isActive;

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
                color: controller
                    .avatarColor(user.name ?? 'User')
                    .withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  controller.getInitials(user.name ?? ''),
                  style: TextStyle(
                    color: controller.avatarColor(user.name ?? 'User'),
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
                    user.name ?? 'unknown'.tr,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    user.email ?? 'no_email'.tr,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13.sp,
                    ),
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
                              ? colorScheme.primary.withValues(alpha: 0.2)
                              : colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.2,
                                ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.role.name.tr,
                          style: TextStyle(
                            color: isAdmin
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      // Verified Badge
                      if (user.isVerified == true)
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: successColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'verified'.tr,
                            style: TextStyle(
                              color: successColor,
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
                              color: isActive
                                  ? successColor
                                  : colorScheme.outline,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            user.isActive ? 'active'.tr : 'inactive'.tr,
                            style: TextStyle(
                              color: isActive
                                  ? successColor
                                  : colorScheme.outline,
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
            Icon(
              Iconsax.arrow_right_3,
              color: colorScheme.onSurfaceVariant,
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }
}
