import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../routes/app_pages.dart';
import '../../../../utils/constants/a_image_strings.dart';
import '../../alerts/views/alerts_view.dart';
import '../controllers/staff_home_controller.dart';

class StaffHomeView extends GetView<StaffHomeController> {
  const StaffHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final List<Widget> tabPages = [
      _buildDashboardContent(context),
      Container(), // Index 1 (Placeholder for New Rental, handled by changeIndex)
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
    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),

            /// Top Bar
            _buildTopBar(context),

            SizedBox(height: 24.h),

            /// Welcome Text
            Text(
              "staff_dashboard".tr,
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
              "operations".tr,
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
      ),
    );
  }

  /// Tab 2: Alerts
  Widget _buildAlertsContent(BuildContext context) {
    return const AlertsView();
  }

  Widget _buildTopBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Logo
        ClipOval(
          child: Image.asset(
            AImageStrings.appLogo,
            width: 40.sp,
            height: 40.sp,
            fit: BoxFit.cover,
          ),
        ),

        // QR Scanner
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
    
    return Obx(() {
      // Data For Stats
      final stats = [
        {
          'title': 'active_rentals'.tr,
          'count': controller.activeRentals.value.toString(),
        },
        {
          'title': 'boards_available'.tr,
          'count': controller.boardsAvailable.value.toString(),
        },
        {
          'title': 'damages_pending'.tr,
          'count': controller.damagesPending.value.toString(),
        },
        {
          'title': 'total_customers'.tr,
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
          childAspectRatio: 1.3,
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
                case 1:
                  Get.toNamed(Routes.AVAILABLE_INVENTORY);
                  break;
                case 2:
                  Get.toNamed(Routes.DAMAGES_PENDING);
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
    });
  }

  Widget _buildManagementGrid(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // Data For Management Menu (Filtered for Staff)
    final menuItems = [
      {'title': 'inventory'.tr, 'sub': 'inventory_sub'.tr, 'icon': Iconsax.box},
      {
        'title': 'customers'.tr,
        'sub': 'customers_sub'.tr,
        'icon': Iconsax.user,
      },
      {'title': 'rentals'.tr, 'sub': 'rentals_sub'.tr, 'icon': Iconsax.receipt},
      {
        'title': 'settings'.tr,
        'sub': 'settings_sub'.tr,
        'icon': Iconsax.setting_2,
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.1,
      ),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            // Handle Navigation Here
            switch (index) {
              case 0:
                Get.toNamed(Routes.INVENTORY);
                break;
              case 1:
                Get.toNamed(Routes.CUSTOMER_LIST);
                break;
              case 2:
                Get.toNamed(Routes.RENTAL_HISTORY);
                break;
              case 3:
                Get.toNamed(Routes.SETTINGS);
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
          items: [
            BottomNavigationBarItem(
              icon: Icon(Iconsax.element_4),
              label: "dashboard_tab".tr,
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.add_circle),
              label: "new_rental_tab".tr,
            ),
            BottomNavigationBarItem(
              icon: Icon(Iconsax.notification),
              label: "alerts_tab".tr,
            ),
          ],
        ),
      ),
    );
  }
}
