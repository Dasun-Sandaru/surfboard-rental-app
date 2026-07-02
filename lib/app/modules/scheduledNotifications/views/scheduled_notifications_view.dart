import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/common/a_app_dialogs.dart';
import '../controllers/scheduled_notifications_controller.dart';

class ScheduledNotificationsView extends GetView<ScheduledNotificationsController> {
  const ScheduledNotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        title: Text(
          'scheduled_notifications'.tr,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Iconsax.trash, color: colorScheme.error),
            onPressed: () {
              showAppConfirmation(
                context: context,
                title: 'cancel_all'.tr,
                message: 'cancel_all_notifications_confirm'.tr,
                confirmText: 'yes'.tr,
                cancelText: 'no'.tr,
                onConfirm: () {
                  controller.cancelAllNotifications();
                },
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.pendingNotifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_active, size: 48.sp, color: colorScheme.outline),
                SizedBox(height: 16.h),
                Text(
                  'no_scheduled_notifications'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchPendingNotifications,
          child: ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.pendingNotifications.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final req = controller.pendingNotifications[index];
              return Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha:0.3),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: colorScheme.outlineVariant.withValues(alpha:0.5)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Iconsax.timer_1, color: colorScheme.primary, size: 20.sp),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  req.title ?? 'no_title'.tr,
                                  style: TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Text(
                                '${'id'.tr}: ${req.id}',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                           Text(
                            req.body ?? 'no_body'.tr,
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Icon(Iconsax.calendar_1, size: 12.sp, color: colorScheme.onSurfaceVariant),
                              SizedBox(width: 4.w),
                              Text(
                                () {
                                  final date = controller.getScheduledTimeForNotification(req.id);
                                  if (date != null) {
                                    return DateFormat('MMM d, y, h:mm a').format(date);
                                  }
                                  // Fallback to payload just in case it works later
                                  try {
                                    if (req.payload != null && req.payload!.isNotEmpty) {
                                      final payloadDate = DateTime.parse(req.payload!);
                                      return DateFormat('MMM d, y, h:mm a').format(payloadDate);
                                    }
                                  } catch (_) {}
                                  return 'unknown_time'.tr;
                                }(),
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      icon: Icon(Iconsax.close_circle, color: colorScheme.error, size: 20.sp),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        showAppConfirmation(
                          context: context,
                          title: 'cancel_notification'.tr,
                          message: 'cancel_notification_confirm'.tr,
                          confirmText: 'yes'.tr,
                          cancelText: 'no'.tr,
                          onConfirm: () {
                            controller.cancelNotification(req.id);
                          },
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
