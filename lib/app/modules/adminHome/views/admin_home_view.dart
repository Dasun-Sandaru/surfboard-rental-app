import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/app/routes/app_pages.dart';

import '../controllers/admin_home_controller.dart';

class AdminHomeView extends GetView<AdminHomeController> {
  const AdminHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabPages = [
      _buildDashboardContent(),
      Container(), // Index 1 (Placeholder, never seen)
      _buildAlertsContent(),
    ];
    return Scaffold(
      backgroundColor: bgDark,
      body: SafeArea(
        child: Obx(
          () => IndexedStack(
            index: controller.selectedIndex.value,
            children: tabPages,
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // WIDGET BUILDERS
  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          /// Top Bar
          _buildTopBar(),

          SizedBox(height: 24.h),

          /// Welcome Text
          Text(
            "Welcome, Admin!",
            style: TextStyle(
              color: textWhite,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),

          SizedBox(height: 24.h),

          /// Stats Grid (4 items)
          _buildStatsGrid(),

          SizedBox(height: 24.h),

          /// Section Header
          Text(
            "Management",
            style: TextStyle(
              color: textWhite,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 16.h),

          /// Management Grid
          _buildManagementGrid(),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  /// Tab 2: Alerts
  Widget _buildAlertsContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.notification5, size: 64.sp, color: textSubtle),
          SizedBox(height: 16.h),
          Text(
            "No new alerts",
            style: TextStyle(color: textWhite, fontSize: 18.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        Icon(Icons.surfing, size: 40.sp, color: primaryBlue),

        // Profile Pic
        InkWell(
          onTap: () {
            controller.signOut();
          },
          child: Container(
            height: 40.w,
            width: 40.w,
            decoration: BoxDecoration(
              color: cardDark,
              shape: BoxShape.circle,
              border: Border.all(color: borderDark),
            ),
            child: Icon(Iconsax.user, color: textWhite, size: 20.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    // Data For Stats
    final stats = [
      {
        'title': 'Active Rentals',
        'count': controller.activeRentals.value.toString(),
      },
      {
        'title': 'Boards Available',
        'count': controller.boardsAvailable.value.toString(),
      },
      {
        'title': 'Damages Pending',
        'count': controller.damagesPending.value.toString(),
      },
      {
        'title': 'Total Customers',
        'count': controller.totalCustomers.value.toString(),
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.4,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: borderDark),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                stats[index]['title']!,
                style: TextStyle(
                  color: textWhite,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                stats[index]['count']!,
                style: TextStyle(
                  color: textWhite,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildManagementGrid() {
    // Data For Management Menu
    final menuItems = [
      {'title': 'Manage Users', 'sub': 'Staff & admin', 'icon': Iconsax.people},
      {'title': 'Inventory', 'sub': 'Boards & gear', 'icon': Iconsax.box},
      {'title': 'Rentals', 'sub': 'Rental history', 'icon': Iconsax.receipt},
      {'title': 'Reports', 'sub': 'Performance', 'icon': Iconsax.chart},
      {
        'title': 'Agreements',
        'sub': 'Waivers & forms',
        'icon': Iconsax.document_text,
      },
      {'title': 'Settings', 'sub': 'App config', 'icon': Iconsax.setting_2},
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.3,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            // Handle Navigation Here
            switch (index) {
              case 0:
                Get.toNamed(Routes.MANAGE_USERS);
                break;
              case 1:
                Get.toNamed(Routes.INVENTORY);
                break;
              case 5:
                Get.toNamed(Routes.SETTINGS);
                break;
              // case 2:
              //   Get.toNamed(Routes.RENTALS);
              //   break;
            }
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: cardDark,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: borderDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  menuItems[index]['icon'] as IconData,
                  color: primaryBlue,
                  size: 28.sp,
                ),
                const Spacer(),
                Text(
                  menuItems[index]['title'] as String,
                  style: TextStyle(
                    color: textWhite,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  menuItems[index]['sub'] as String,
                  style: TextStyle(
                    color: textSubtle,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: cardDark.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: borderDark)),
      ),
      child: Obx(
        () => BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeIndex,
          selectedItemColor: primaryBlue,
          unselectedItemColor: textSubtle,
          selectedFontSize: 12.sp,
          unselectedFontSize: 12.sp,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Iconsax.element_4),
              label: "Dashboard",
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.add_circle),
              label: "New Rental",
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.notification),
              label: "Alerts",
            ),
          ],
        ),
      ),
    );
  }
}

// -- Color Palette from your Design --
final Color bgDark = const Color(0xFF101f22);
final Color cardDark = const Color(0xFF182c30);
final Color primaryBlue = const Color(0xFF4A90E2);
final Color textWhite = const Color(0xFFf0f4f4);
final Color textSubtle = const Color(0xFF94a3b8);
final Color borderDark = const Color(0xFF334155);
