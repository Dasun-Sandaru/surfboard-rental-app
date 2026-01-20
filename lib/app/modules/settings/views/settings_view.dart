import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../controllers/settings_controller.dart';
import 'inventory_config_view.dart'; // Import the sub-screen

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  // Theme Colors
  final Color bgDark = const Color(0xFF101f22);
  final Color cardDark = const Color(0xFF182c30);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color borderDark = const Color(0xFF334155);
  final Color errorRed = const Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        centerTitle: true,
        title: Text("Settings", style: TextStyle(color: textWhite, fontSize: 18.sp, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        child: Column(
          children: [
            
            /// 1. Profile Card
            _buildProfileCard(controller),
            SizedBox(height: 24.h),

            /// 2. Shop Settings Section
            _buildSectionHeader("Shop Management"),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Iconsax.shop, 
                    title: "Shop Details", 
                    subtitle: "Name, Location, Contact",
                    onTap: () {},
                  ),
                  _buildDivider(),
                  _buildSettingsTile(
                    icon: Iconsax.box, 
                    title: "Inventory Configuration", 
                    subtitle: "Manage Brands & Board Types",
                    onTap: controller.navigateToInventorySettings, // <--- GO TO CONFIG
                    trailingIcon: Iconsax.arrow_right_3,
                    iconColor: primaryBlue,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24.h),

            /// 3. App Settings Section
            _buildSectionHeader("App Settings"),
            SizedBox(height: 8.h),
            Container(
              decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  _buildSettingsTile(icon: Iconsax.notification, title: "Notifications", onTap: () {}),
                  _buildDivider(),
                  _buildSettingsTile(icon: Iconsax.language_square, title: "Language", subtitle: "English", onTap: () {}),
                  _buildDivider(),
                  _buildSettingsTile(icon: Iconsax.moon, title: "Dark Mode", trailing: Switch(value: true, onChanged: (v){}, activeColor: primaryBlue)),
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
                icon: Icon(Iconsax.logout, color: errorRed),
                label: Text("Log Out", style: TextStyle(color: errorRed, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: errorRed.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildProfileCard(SettingsController controller) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(color: cardDark, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.w, 
            backgroundColor: primaryBlue, 
            child: Text("A", style: TextStyle(color: textWhite, fontSize: 24.sp, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(controller.userProfile.value['name']!, style: TextStyle(color: textWhite, fontSize: 18.sp, fontWeight: FontWeight.bold)),
              Text(controller.userProfile.value['email']!, style: TextStyle(color: textGrey, fontSize: 14.sp)),
            ],
          ),
          Spacer(),
          IconButton(onPressed: (){}, icon: Icon(Iconsax.edit, color: primaryBlue))
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(alignment: Alignment.centerLeft, child: Text(title, style: TextStyle(color: textGrey, fontSize: 14.sp, fontWeight: FontWeight.bold)));
  }

  Widget _buildSettingsTile({
    required IconData icon, 
    required String title, 
    String? subtitle, 
    VoidCallback? onTap, 
    Widget? trailing, 
    IconData? trailingIcon,
    Color? iconColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(color: bgDark, borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: iconColor ?? textWhite, size: 20.w),
      ),
      title: Text(title, style: TextStyle(color: textWhite, fontWeight: FontWeight.w500)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: textGrey, fontSize: 12.sp)) : null,
      trailing: trailing ?? Icon(trailingIcon ?? Iconsax.arrow_right_3, color: textGrey, size: 18.w),
    );
  }

  Widget _buildDivider() => Divider(color: borderDark, height: 1);
}