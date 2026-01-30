import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../controllers/settings_controller.dart';
import 'rental_config_view.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        centerTitle: true,
        title: Text(
          "Settings",
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
            _buildSectionHeader(context, "Shop Management"),
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
                    icon: Iconsax.shop,
                    title: "Shop Details",
                    subtitle: "Name, Location, Contact",
                    onTap: controller.editShopDetails,
                  ),
                  _buildDivider(context),
                  _buildSettingsTile(
                    context,
                    icon: Iconsax.box,
                    title: "Inventory Configuration",
                    subtitle: "Manage Brands & Board Types",
                    onTap: controller.navigateToInventorySettings,
                    trailingIcon: Iconsax.arrow_right_3,
                    iconColor: colorScheme.primary,
                  ),
                  _buildDivider(context),
                  Obx(
                    () => _buildSettingsTile(
                      context,
                      icon: Iconsax.money,
                      title: "Currency",
                      subtitle: controller.currency.value,
                      onTap: controller.showCurrencyPicker,
                      trailingIcon: Iconsax.arrow_right_3,
                      iconColor: Colors.green,
                    ),
                  ),
                  _buildDivider(context),
                  Obx(
                    () => _buildSettingsTile(
                      context,
                      icon: Iconsax.calendar_1,
                      title: "Date Format",
                      subtitle: controller.dateFormat.value,
                      onTap: controller.showDateFormatPicker,
                      trailingIcon: Iconsax.arrow_right_3,
                      iconColor: Colors.purple,
                    ),
                  ),
                  _buildDivider(context),
                  Obx(
                    () => _buildSettingsTile(
                      context,
                      icon: Iconsax.clock,
                      title: "Time Zone",
                      subtitle: controller.timeZone.value,
                      onTap: controller.showTimeZonePicker,
                      trailingIcon: Iconsax.arrow_right_3,
                      iconColor: Colors.blue,
                    ),
                  ),

                  _buildDivider(context),
                  _buildSettingsTile(
                    context,
                    icon: Iconsax.setting_2,
                    title: "Rental Pricing Logic",
                    subtitle: "Rates, Tax",
                    onTap: () => Get.to(() => const RentalConfigView()),
                    trailingIcon: Iconsax.arrow_right_3,
                    iconColor: Colors.orange,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            /// 3. App Settings Section
            _buildSectionHeader(context, "App Settings"),
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
                    title: "Notifications",
                    onTap: () {},
                  ),
                  _buildDivider(context),
                  Obx(
                    () => _buildSettingsTile(
                      context,
                      icon: Iconsax.language_square,
                      title: "Language",
                      subtitle:
                          controller.supportedLanguages[controller
                              .currentLanguage
                              .value] ??
                          "English",
                      onTap: controller.showLanguagePicker,
                    ),
                  ),
                  _buildDivider(context),
                  _buildSettingsTile(
                    context,
                    icon: Iconsax.moon,
                    title: "Dark Mode",
                    trailing: Switch(
                      value: Get.isDarkMode,
                      onChanged: (v) {
                        Get.changeThemeMode(
                          v ? ThemeMode.dark : ThemeMode.light,
                        );
                      },
                      activeColor: colorScheme.primary,
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
                  "Log Out",
                  style: TextStyle(
                    color: colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: colorScheme.error.withOpacity(0.5)),
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
    final String name = profile[FirestoreFields.name] ?? 'Guest';
    final String email = profile[FirestoreFields.email] ?? 'Not logged in';

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
