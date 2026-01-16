import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../models/inventory_model.dart';
import '../../../routes/app_pages.dart';
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
  final Color borderDark = const Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InventoryController());

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        showbackArrow: true,
        centerTitle: true,
        title: Text(
          'Inventory',
          style: TextStyle(
            color: textWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        // actions: [
        //   IconButton(
        //     onPressed: () {},
        //     icon: Icon(Iconsax.search_normal, color: textWhite, size: 24.w),
        //   ),
        // ],
      ),
      body: Column(
        children: [
          _buildFilterHeader(context, controller),
          SizedBox(height: 16.h),

          /// Inventory List (Reactive)
          Expanded(
            child: StreamBuilder(
              stream: controller.inventoryItemsStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'Error: ${snapshot.error}',
                          style: TextStyle(color: textWhite),
                        ),
                      ),
                    ),
                  );
                }
                final items = snapshot.data?.docs ?? [];
                if (items.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: cardDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          'No inventory items found.',
                          style: TextStyle(color: textWhite),
                        ),
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: ASizes.defaultPadding,
                    vertical: 8.h,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    // final itemData =
                    //     items[index].data() as Map<String, dynamic>;
                    // return _buildInventoryCard(itemData, controller);
                    final itemData = InventoryModel.fromMap(
                      items[index].data() as Map<String, dynamic>,
                    );
                    return _buildInventoryCard(itemData, controller);
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryBlue,
        onPressed: () {
          Get.toNamed(Routes.ADD_INVENTORY);
        },
        child: Icon(Iconsax.add, color: textWhite),
      ),
    );
  }

  // ===========================================================================
  // FILTER HEADER
  // ===========================================================================

  Widget _buildFilterHeader(
    BuildContext context,
    InventoryController controller,
  ) {
    return SizedBox(
      height: 40.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: ASizes.defaultPadding),
        children: [
          _buildReactiveFilterChip(context, controller, 'Type', Iconsax.tag),
          SizedBox(width: 12.w),
          // _buildStaticFilterChip(context, controller, 'Size', Iconsax.ruler),
          // SizedBox(width: 12.w),
          // _buildReactiveFilterChip(
          //   context,
          //   controller,
          //   'Status',
          //   Iconsax.bookmark,
          // ),
        ],
      ),
    );
  }

  // ===========================================================================
  // FILTER CHIPS
  // ===========================================================================

  Widget _buildReactiveFilterChip(
    BuildContext context,
    InventoryController controller,
    String label,
    IconData icon,
  ) {
    return Obx(() {
      bool isActive = false;

      // if (label == 'Status' && controller.selectedStatusFilter.value != null) {
      //   isActive = true;
      // }

      if (label == 'Type' && controller.selectedSurfboardTypes.isNotEmpty) {
        isActive = true;
      }

      return _buildChipUI(context, controller, label, icon, isActive);
    });
  }

  Widget _buildStaticFilterChip(
    BuildContext context,
    InventoryController controller,
    String label,
    IconData icon,
  ) {
    return _buildChipUI(context, controller, label, icon, false);
  }

  Widget _buildChipUI(
    BuildContext context,
    InventoryController controller,
    String label,
    IconData icon,
    bool isActive,
  ) {
    final bgColor = isActive ? primaryBlue.withOpacity(0.2) : chipDark;
    final textColor = isActive ? primaryBlue : textWhite;
    final borderColor = isActive ? primaryBlue : Colors.transparent;

    return InkWell(
      onTap: () => _showFilterBottomSheet(context, controller, label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 18.w),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(color: textColor, fontSize: 14.sp),
            ),
            SizedBox(width: 4.w),
            Icon(Iconsax.arrow_down_1, color: textColor, size: 16.w),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // FILTER BOTTOM SHEET
  // ===========================================================================

  void _showFilterBottomSheet(
    BuildContext context,
    InventoryController controller,
    String type,
  ) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: textGrey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 24.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Filter by $type",
                  style: TextStyle(
                    color: textWhite,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: controller.resetFilters,
                  child: Text("Reset", style: TextStyle(color: textGrey)),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            if (type == 'Status') _buildStatusFilterOptions(controller),
            if (type == 'Type') _buildTypeFilterOptions(controller),

            SizedBox(height: 32.h),

            SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: controller.applyFilters,
                child: const Text("Apply Filters"),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ===========================================================================
  // FILTER OPTIONS
  // ===========================================================================

  Widget _buildStatusFilterOptions(InventoryController controller) {
    return Column(
      children: ItemStatus.values.map((status) {
        final details = controller.getStatusDetails(status);
        return Obx(() {
          final isSelected = controller.selectedStatusFilter.value == status;
          return ListTile(
            onTap: () => controller.setStatusFilter(status),
            leading: CircleAvatar(backgroundColor: details['color'], radius: 6),
            title: Text(details['text'], style: TextStyle(color: textWhite)),
            trailing: isSelected
                ? Icon(Iconsax.tick_circle, color: primaryBlue)
                : null,
          );
        });
      }).toList(),
    );
  }

  Widget _buildTypeFilterOptions(InventoryController controller) {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: controller.surfboardTypes.map((type) {
        return Obx(() {
          final isSelected = controller.selectedSurfboardTypes.contains(type);
          return FilterChip(
            label: Text(type),
            selected: isSelected,
            onSelected: (_) => controller.toggleTypeFilter(type),
          );
        });
      }).toList(),
    );
  }

  // ===========================================================================
  // INVENTORY CARD
  // ===========================================================================

  Widget _buildInventoryCard(
    InventoryModel item,
    InventoryController controller,
  ) {
    final status = controller.getStatusDetails(item.status);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(width: 80.w, height: 80.w, color: bgDark),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: TextStyle(color: textWhite, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.h),
              Text(status['text'], style: TextStyle(color: status['color'])),
            ],
          ),
        ],
      ),
    );
  }
}
