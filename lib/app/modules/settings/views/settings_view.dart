import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../data/firestore/firestore_fields.dart';
import '../../../../utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../controllers/settings_controller.dart';
import '../../../../app/routes/app_pages.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        centerTitle: true,
        title: Text(
          "settings_title".tr,
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
            /// 1. Profile Card
            Obx(() => _buildProfileCard(context, controller)),
            SizedBox(height: 24.h),

            /// 2. Shop Management Section
            _buildSectionHeader(context, "shop_management".tr),
            SizedBox(height: 8.h),

            // Shop Details & Inventory Config
            Obx(() {
              final canViewShop = controller.hasPermission(
                'settings_view_shop',
              );
              final canEditInventoryConfig = controller.hasPermission(
                'shop_setup',
              );

              if (!canViewShop && !canEditInventoryConfig) {
                return const SizedBox.shrink();
              }

              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    if (canViewShop)
                      _buildSettingsTile(
                        context,
                        icon: Iconsax.shop,
                        title: "shop_details".tr,
                        subtitle: "shop_details_sub".tr,
                        onTap: controller.editShopDetails,
                      ),

                    if (canViewShop && canEditInventoryConfig)
                      _buildDivider(context),

                    if (canEditInventoryConfig)
                      _buildSettingsTile(
                        context,
                        icon: Iconsax.box,
                        title:
                            "inventory_config".tr, // "Inventory Configuration"
                        subtitle: "inventory_config_sub".tr,
                        onTap: controller.navigateToInventorySettings,
                        trailingIcon: Iconsax.arrow_right_3,
                        iconColor: colorScheme.primary,
                      ),
                  ],
                ),
              );
            }),

            SizedBox(height: 24.h),

            // Configurations (Currency, Date, TZ, Rental Logic)
            Obx(() {
              final canEditCurrency = controller.hasPermission(
                'settings_edit_currency',
              );
              final canEditDate = controller.hasPermission(
                'settings_edit_date_format',
              );
              final canEditTimeZone = controller.hasPermission(
                'settings_edit_timezone',
              );
              final canEditRentalLogic = controller.hasPermission(
                'settings_edit_rental_logic',
              );

              final List<Widget> items = [];

              if (canEditCurrency) {
                items.add(
                  Obx(
                    () => _buildSettingsTile(
                      context,
                      icon: Iconsax.money,
                      title: "currency".tr,
                      subtitle: controller.currency.value,
                      onTap: controller.showCurrencyPicker,
                      trailingIcon: Iconsax.arrow_right_3,
                      iconColor: Colors.green,
                    ),
                  ),
                );
                items.add(_buildDivider(context));
              }

              if (canEditDate) {
                items.add(
                  Obx(
                    () => _buildSettingsTile(
                      context,
                      icon: Iconsax.calendar_1,
                      title: "date_format".tr,
                      subtitle: controller.dateFormat.value,
                      onTap: controller.showDateFormatPicker,
                      trailingIcon: Iconsax.arrow_right_3,
                      iconColor: Colors.purple,
                    ),
                  ),
                );
                items.add(_buildDivider(context));
              }

              if (canEditTimeZone) {
                items.add(
                  Obx(
                    () => _buildSettingsTile(
                      context,
                      icon: Iconsax.clock,
                      title: "time_zone".tr,
                      subtitle: controller.timeZone.value,
                      onTap: controller.showTimeZonePicker,
                      trailingIcon: Iconsax.arrow_right_3,
                      iconColor: Colors.blue,
                    ),
                  ),
                );
                items.add(_buildDivider(context));
              }

              // Rental Pricing - Admin gets full config, Staff gets pricing logic only
              final isAdmin =
                  controller.userProfile.value[FirestoreFields.role] == 'admin';

              if (isAdmin) {
                // Admin gets full Rental Config View
                items.add(
                  _buildSettingsTile(
                    context,
                    icon: Iconsax.setting_2,
                    title: "rental_pricing".tr,
                    subtitle: "rental_pricing_sub".tr,
                    onTap: () => Get.toNamed(Routes.RENTAL_CONFIG),
                    trailingIcon: Iconsax.arrow_right_3,
                    iconColor: Colors.orange,
                  ),
                );
              } else if (canEditRentalLogic) {
                // Staff with permission gets Rental Pricing Logic View
                items.add(
                  _buildSettingsTile(
                    context,
                    icon: Iconsax.setting_2,
                    title: "rental_pricing".tr,
                    subtitle: "rental_pricing_sub".tr,
                    onTap: () => Get.toNamed(Routes.RENTAL_PRICING_LOGIC),
                    trailingIcon: Iconsax.arrow_right_3,
                    iconColor: Colors.orange,
                  ),
                );
              }

              if (items.isEmpty) return const SizedBox.shrink();
              if (items.last is Divider) {
                items
                    .removeLast(); // Logic to remove last divider if present isn't straightforward with generic Widgets, but assuming layout for now.
              }

              // Remove the last divider manually if the last item added was a divider
              if (items.isNotEmpty && items.last is Divider) {
                // Wait, can't verify runtime type easily if it's wrapped.
                // I'll just rely on the fact that I add a divider AFTER each item.
                // So removing the last one is correct.
                items.removeLast();
              }

              return Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(children: items),
              );
            }),

            SizedBox(height: 24.h),

            /// 2.5 Access Control Section (Admin Only)
            Obx(() {
              final isOwnerAdmin =
                  controller.userProfile.value[FirestoreFields.role] == 'admin';
              final canManageAccess = controller.hasPermission(
                'settings_manage_access',
              );

              if (!isOwnerAdmin || !canManageAccess) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  _buildSectionHeader(context, "staff_access_control".tr),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _buildSettingsTile(
                      context,
                      icon: Iconsax.lock,
                      title: "manage_staff_access".tr,
                      onTap: controller.navigateToAccessControl,
                      trailingIcon: Iconsax.arrow_right_3,
                    ),
                  ),
                ],
              );
            }),

            SizedBox(height: 24.h),

            /// 3. App Settings Section
            _buildSectionHeader(context, "app_settings".tr),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildSettingsTile(
                    context,
                    icon: Iconsax.notification,
                    title: "notifications".tr,
                    onTap: () => Get.toNamed(Routes.SCHEDULED_NOTIFICATIONS),
                  ),
                  _buildDivider(context),
                  Obx(
                    () => _buildSettingsTile(
                      context,
                      icon: Iconsax.language_square,
                      title: "language".tr,
                      subtitle:
                          controller.supportedLanguages[controller
                              .currentLanguage
                              .value] ??
                          "english".tr,
                      onTap: controller.showLanguagePicker,
                    ),
                  ),
                  _buildDivider(context),
                  _buildSettingsTile(
                    context,
                    icon: Iconsax.moon,
                    title: "dark_mode".tr,
                    trailing: Switch(
                      value: Get.isDarkMode,
                      onChanged: (v) {
                        Get.changeThemeMode(
                          v ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                      activeThumbColor: colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            /// 4. Logout
            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: OutlinedButton.icon(
                onPressed: controller.logout,
                icon: Icon(Iconsax.logout, color: colorScheme.error),
                label: Text(
                  "logout".tr,
                  style: TextStyle(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: colorScheme.error.withValues(alpha: 0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildProfileCard(
    BuildContext context,
    SettingsController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final profile = controller.userProfile.value;
    final String name = profile[FirestoreFields.name] ?? 'guest'.tr;
    final String email = profile[FirestoreFields.email] ?? 'not_logged_in'.tr;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.w,
            backgroundColor: colorScheme.primary,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  email,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              controller.editPersonalInfo();
            },
            icon: Icon(Iconsax.edit, color: colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(bottom: 8.h),
        child: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    IconData? trailingIcon,
    Color? iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: iconColor ?? colorScheme.onSurface,
          size: 20.w,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 12.sp,
              ),
            )
          : null,
      trailing:
          trailing ??
          Icon(
            trailingIcon ?? Iconsax.arrow_right_3,
            color: colorScheme.onSurfaceVariant,
            size: 18.w,
          ),
    );
  }

  Widget _buildDivider(BuildContext context) =>
      Divider(color: Theme.of(context).colorScheme.outline, height: 1);
}
