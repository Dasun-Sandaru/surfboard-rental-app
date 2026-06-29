import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../../../../utils/common/a_app_bar.dart';
import '../controllers/settings_controller.dart';

class AccessControlView extends GetView<SettingsController> {
  const AccessControlView({super.key});

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
          "staff_access_control".tr,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        child: Column(
          children: [
            Obx(
              () => Column(
                children: controller.accessGroups.map((group) {
                  final title = group['title'] as String;
                  final keys = group['keys'] as List<String>;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 8.h,
                        ),
                        child: Text(
                          title.tr,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: keys.map((key) {
                            final canEdit =
                                controller.hasPermission('settings_manage_access');
                            final isAllowed =
                                controller.staffAccessRules[key] ?? false;
                            final label =
                                controller.accessRouteLabels[key] ?? key;
                            final isLast = key == keys.last;

                            return Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    padding: EdgeInsets.all(8.w),
                                    decoration: BoxDecoration(
                                      color: colorScheme.surface,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      Iconsax.lock,
                                      color: isAllowed
                                          ? colorScheme.primary
                                          : colorScheme.error,
                                      size: 20.w,
                                    ),
                                  ),
                                  title: Text(
                                    label,
                                    style: TextStyle(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: Switch(
                                    value: isAllowed,
                                    onChanged: canEdit
                                        ? (val) =>
                                            controller.toggleAccess(key, val)
                                        : null,
                                    activeThumbColor: colorScheme.primary,
                                  ),
                                  onTap: canEdit
                                      ? () =>
                                          controller.toggleAccess(key, !isAllowed)
                                      : null,
                                ),
                                if (!isLast)
                                  Divider(
                                    color: colorScheme.outline,
                                    height: 1,
                                  ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
