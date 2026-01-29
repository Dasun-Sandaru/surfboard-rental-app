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
    final colorScheme = Theme.of(context).colorScheme;
    final List<Widget> tabPages = [
      _buildDashboardContent(context),
      Container(), // Index 1 (Placeholder, never seen)
      _buildAlertsContent(context),
    ];
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Obx(
          () => IndexedStack(
            index: controller.selectedIndex.value,
            children: tabPages,
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  // WIDGET BUILDERS
  Widget _buildDashboardContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),

          /// Top Bar
          _buildTopBar(context),

          SizedBox(height: 24.h),

          /// Welcome Text
          Text(
            "Welcome, Admin!",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5,
            ),
          ),

          SizedBox(height: 24.h),

          /// Stats Grid (4 items)
          _buildStatsGrid(context),

          SizedBox(height: 24.h),

          /// Section Header
          Text(
            "Management",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 16.h),

          /// Management Grid
          _buildManagementGrid(context),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  /// Tab 2: Alerts
  Widget _buildAlertsContent(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Iconsax.notification5,
            size: 64.sp,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 16.h),
          Text(
            "No new alerts",
            style: TextStyle(color: colorScheme.onSurface, fontSize: 18.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        Icon(Icons.surfing, size: 40.sp, color: colorScheme.primary),

        // Profile Pic
        InkWell(
          onTap: () {
            Get.toNamed(Routes.QR_SCANNER);
          },
          child: Container(
            height: 40.w,
            width: 40.w,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.outline),
            ),
            child: Icon(
              Iconsax.scan_barcode,
              color: colorScheme.onSurface,
              size: 20.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
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
        return InkWell(
          onTap: () {
            // Handle Navigation Here
            switch (index) {
              case 0:
                Get.toNamed(Routes.RENTALS);
                break;
            }
          },
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  stats[index]['title']!,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  stats[index]['count']!,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildManagementGrid(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Data For Management Menu
    final menuItems = [
      {'title': 'Manage Users', 'sub': 'Staff & admin', 'icon': Iconsax.people},
      {'title': 'Inventory', 'sub': 'Boards & gear', 'icon': Iconsax.box},
      {'title': 'Customers', 'sub': 'Customer list', 'icon': Iconsax.user},
      {'title': 'Rentals', 'sub': 'Rental history', 'icon': Iconsax.receipt},
      {'title': 'Reports', 'sub': 'Performance', 'icon': Iconsax.chart},
      {
        'title': 'Agreements',
        'sub': 'Waivers & forms',
        'icon': Iconsax.document_text,
      },
      {'title': 'Settings', 'sub': 'App config', 'icon': Iconsax.setting_2},
      {'title': 'Seed Data', 'sub': 'DEBUG: Add samples', 'icon': Iconsax.data},
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
              case 2:
                Get.toNamed(Routes.CUSTOMER_LIST);
                break;
              case 5:
                Get.toNamed(Routes.AGREEMENT_TEMPLATE);
                break;
              case 6:
                Get.toNamed(Routes.SETTINGS);
                break;
              case 7:
                controller.seedSampleData();
                break;
            }
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  menuItems[index]['icon'] as IconData,
                  color: colorScheme.primary,
                  size: 28.sp,
                ),
                const Spacer(),
                Text(
                  menuItems[index]['title'] as String,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  menuItems[index]['sub'] as String,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
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

  Widget _buildBottomNav(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer.withValues(alpha: 0.95),
        border: Border(top: BorderSide(color: colorScheme.outline)),
      ),
      child: Obx(
        () => BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.selectedIndex.value,
          onTap: controller.changeIndex,
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: colorScheme.onSurfaceVariant,
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
