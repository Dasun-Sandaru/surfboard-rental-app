import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../../../../utils/helper/a_formatter.dart';

import '../../../../utils/constants/a_enums.dart';
import '../../../../utils/common/a_app_bar.dart';
import '../../../models/activity_log_model.dart';
import '../controllers/alerts_controller.dart';
import 'alert_details_view.dart';

class AlertsView extends GetView<AlertsController> {
  const AlertsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: false,
        centerTitle: true,
        title: Text(
          'activity_logs'.tr,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => controller.refreshLogs(),
        child: PagedListView<DocumentSnapshot?, ActivityLogModel>(
          pagingController: controller.pagingController,
          padding: EdgeInsets.symmetric(
            horizontal: ASizes.defaultPadding,
            vertical: 16.h,
          ),
          builderDelegate: PagedChildBuilderDelegate<ActivityLogModel>(
            itemBuilder: (context, log, index) =>
                _buildActivityLogCard(context, log, index),
            firstPageErrorIndicatorBuilder: (context) =>
                _buildErrorState(context),
            newPageErrorIndicatorBuilder: (context) =>
                _buildErrorState(context),
            noItemsFoundIndicatorBuilder: (context) =>
                _buildEmptyState(context),
            firstPageProgressIndicatorBuilder: (context) =>
                _buildLoadingState(),
            newPageProgressIndicatorBuilder: (context) =>
                _buildLoadingIndicator(context),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityLogCard(
    BuildContext context,
    ActivityLogModel log,
    int index,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        Get.to(() => AlertDetailsView(log: log));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: _getActivityColor(
                  log.activityType,
                ).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getActivityIcon(log.activityType),
                color: _getActivityColor(log.activityType),
                size: 20.w,
              ),
            ),
            SizedBox(width: 12.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  Text(
                    log.description,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Actor and entity type
                  Row(
                    children: [
                      Icon(
                        Iconsax.user,
                        size: 12.w,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text(
                          log.actorName,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12.sp,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          log.entityType,
                          style: TextStyle(
                            color: colorScheme.onSecondaryContainer,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),

                  // Timestamp
                  Row(
                    children: [
                      Icon(
                        Iconsax.clock,
                        size: 12.w,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        AFormatter.formatDate(log.timestamp),
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.document_text,
            size: 64.w,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            'no_activity_logs'.tr,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'activity_logs_sub'.tr,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.info_circle, size: 64.w, color: colorScheme.error),
          SizedBox(height: 16.h),
          Text(
            'error_loading_logs'.tr,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'retry_sub'.tr,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: controller.refreshLogs,
            icon: Icon(Iconsax.refresh, size: 16.w),
            label: Text('retry'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildLoadingIndicator(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  IconData _getActivityIcon(ActivityType type) {
    switch (type) {
      case ActivityType.create_rental:
        return Iconsax.add_circle;
      case ActivityType.start_rental:
        return Iconsax.play;
      case ActivityType.return_rental:
        return Iconsax.tick_circle;
      case ActivityType.add_payment:
        return Iconsax.wallet_money;
      case ActivityType.delete_payment:
        return Iconsax.wallet_remove;
      case ActivityType.add_customer:
        return Iconsax.user_add;
      case ActivityType.update_customer:
        return Icons.person_outline;
      case ActivityType.add_inventory:
        return Iconsax.box_add;
      case ActivityType.update_inventory:
        return Iconsax.box;
      case ActivityType.delete_inventory:
        return Iconsax.box_remove;
      case ActivityType.report_damage:
        return Iconsax.danger;
      case ActivityType.create_user:
        return Iconsax.profile_add;
      case ActivityType.update_user:
        return Iconsax.profile_tick;
      case ActivityType.login:
        return Iconsax.login;
      case ActivityType.logout:
        return Iconsax.logout;
      default:
        return Iconsax.document_text;
    }
  }

  Color _getActivityColor(ActivityType type) {
    switch (type) {
      case ActivityType.create_rental:
      case ActivityType.start_rental:
        return const Color(0xFF4A90E2);
      case ActivityType.return_rental:
        return const Color(0xFF10B981);
      case ActivityType.add_payment:
        return const Color(0xFFF59E0B);
      case ActivityType.delete_payment:
        return const Color(0xFFEF4444);
      case ActivityType.add_customer:
      case ActivityType.update_customer:
        return const Color(0xFF6366F1);
      case ActivityType.add_inventory:
      case ActivityType.update_inventory:
        return const Color(0xFF8B5CF6);
      case ActivityType.delete_inventory:
      case ActivityType.report_damage:
        return const Color(0xFFEF4444);
      case ActivityType.create_user:
      case ActivityType.update_user:
      case ActivityType.login:
      case ActivityType.logout:
        return const Color(0xFF14B8A6);
      default:
        return const Color(0xFF6B7280);
    }
  }
}