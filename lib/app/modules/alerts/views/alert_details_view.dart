import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/helper/a_formatter.dart';
import '../../../models/activity_log_model.dart';
import '../../../routes/app_pages.dart';
import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../../utils/constants/a_sizes.dart';

class AlertDetailsView extends StatelessWidget {
  const AlertDetailsView({super.key, required this.log});

  final ActivityLogModel log;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const AAppBar(
        showbackArrow: true,
        title: Text('Activity Details'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Center(
              child: Column(
                children: [
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: BoxDecoration(
                      color: _getActivityColor(
                        log.activityType,
                      ).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getActivityIcon(log.activityType),
                      color: _getActivityColor(log.activityType),
                      size: 40.w,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    log.activityType.name.replaceAll('_', ' ').capitalize!,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    AFormatter.formatDate(log.timestamp),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32.h),

            // Description Section
            _buildSection(
              context: context,
              title: "Description",
              content: log.description,
              icon: Iconsax.document_text,
            ),
            SizedBox(height: 20.h),

            // Actor Section
            _buildSection(
              context: context,
              title: "Performed By",
              content: "${log.actorName}\nID: ${log.actorId}",
              icon: Iconsax.user,
              onTap: () {
                // Navigate to User Details if actorId is valid
                if (log.actorId != 'SYSTEM') {
                  Get.toNamed(
                    Routes.USER_DETAIL,
                    arguments: {'userId': log.actorId},
                  );
                }
              },
            ),
            SizedBox(height: 20.h),

            // Entity Section
            _buildSection(
              context: context,
              title: "Related Entity",
              content: "${log.entityType}\nID: ${log.entityId}",
              icon: Iconsax.box,
              onTap: () {
                _navigateToEntity(log.entityType, log.entityId);
              },
            ),
            SizedBox(height: 20.h),

            // Metadata Section (if exists)
            if (log.metadata != null && log.metadata!.isNotEmpty) ...[
              Text(
                "Metadata",
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: log.metadata!.entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${entry.key.replaceAll('_', ' ').capitalize}: ",
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              entry.value.toString(),
                              style: TextStyle(
                                color: colorScheme.onSurface,
                                fontSize: 14.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToEntity(String type, String id) {
    switch (type) {
      case 'Rental':
        Get.toNamed(Routes.RENTAL_DETAIL, arguments: id);
        break;
      case 'Customer':
        Get.toNamed(Routes.CUSTOMER_DETAILS, arguments: id);
        break;
      case 'Inventory':
        Get.toNamed(Routes.ITEM_DETAILS, arguments: id);
        break;
      case 'User':
        Get.toNamed(Routes.USER_DETAIL, arguments: id);
        break;
      case 'Payment':
        // We might not have a dedicated payment detail view yet,
        // but usually payments are linked to rentals.
        // If metadata has rentalId, we could go there, otherwise just show snackbar
        Get.snackbar('Info', 'Payment details view not available yet');
        break;
      default:
        Get.snackbar('Info', 'Details view for $type not available');
    }
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required String content,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline.withValues(alpha: 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary, size: 24.w),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    content,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (onTap != null) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          'View Details',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Iconsax.arrow_right_3,
                          size: 14.w,
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
