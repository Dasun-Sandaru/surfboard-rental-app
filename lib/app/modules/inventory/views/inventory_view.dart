import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../controllers/inventory_controller.dart';

class InventoryListView extends StatelessWidget {
  const InventoryListView({super.key});

  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22);
  final Color cardDark = const Color(0xFF182c30);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color chipDark = const Color(0xFF2a3b42);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InventoryController());

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        centerTitle: true,
        title: Text(
          'Inventory',
          style: TextStyle(
            color: textWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.openSearch,
            icon: Icon(Iconsax.search_normal, color: textWhite, size: 24.w),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          /// 1. Filter Chips Header
          _buildFilterHeader(controller),
          
          SizedBox(height: 16.h),

          /// 2. Inventory List
          Expanded(
            child: Obx(
              () => ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  ASizes.defaultPadding, 
                  0, 
                  ASizes.defaultPadding, 
                  80.h // Bottom padding for FAB
                ),
                itemCount: controller.inventoryItems.length,
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final item = controller.inventoryItems[index];
                  return _buildInventoryCard(item, controller);
                },
              ),
            ),
          ),
        ],
      ),
      
      /// 3. Floating Action Button
      floatingActionButton: SizedBox(
        width: 56.w,
        height: 56.w,
        child: FloatingActionButton(
          onPressed: controller.openAddItemScreen,
          backgroundColor: primaryBlue,
          shape: const CircleBorder(),
          elevation: 4,
          child: Icon(Iconsax.add, color: textWhite, size: 30.w),
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildFilterHeader(InventoryController controller) {
    return SizedBox(
      height: 40.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: ASizes.defaultPadding),
        children: [
          _buildFilterChip(controller, 'Brand', Iconsax.tag),
          SizedBox(width: 12.w),
          _buildFilterChip(controller, 'Size', Iconsax.ruler),
          SizedBox(width: 12.w),
          _buildFilterChip(
            controller, 
            'Status', 
            Iconsax.bookmark, 
            isActive: true // Example of active state
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    InventoryController controller, 
    String label, 
    IconData icon,
    {bool isActive = false}
  ) {
    final bgColor = isActive ? primaryBlue.withOpacity(0.2) : chipDark;
    final textColor = isActive ? primaryBlue : textWhite;

    return InkWell(
      onTap: () => controller.openFilter(label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 18.w),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                color: textColor,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(Iconsax.arrow_down_1, color: textColor, size: 16.w),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryCard(Map<String, dynamic> item, InventoryController controller) {
    final statusDetails = controller.getStatusDetails(item['status']);
    final Color statusColor = statusDetails['color'];
    final String statusText = statusDetails['text'];

    return InkWell(
      onTap: () => controller.openItemDetails(item),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Image
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                item['imageUrl'],
                width: 96.w,
                height: 96.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 96.w,
                  height: 96.w,
                  color: bgDark,
                  child: Icon(Iconsax.image, color: textGrey),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            
            /// Info & Status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 4.h),
                  Text(
                    item['name'],
                    style: TextStyle(
                      color: textWhite,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item['size'],
                    style: TextStyle(
                      color: textGrey,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  
                  /// Status Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}