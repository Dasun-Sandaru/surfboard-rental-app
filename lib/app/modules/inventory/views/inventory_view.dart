import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';
import 'package:surfboard_rental_app/utils/helper/a_validator.dart';

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
      ),
      body: Column(
        children: [
          _buildFilterHeader(context, controller),
          SizedBox(height: 16.h),

          /// Inventory List (Reactive)
          Expanded(
            child: Obx(() {
              // if (controller.items.isEmpty && controller.isLoading) {
              //   return const Center(child: CircularProgressIndicator());
              // }

              if (controller.items.isEmpty) {
                return Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        // decoration: BoxDecoration(
                        //   color: cardDark,
                        //   borderRadius: BorderRadius.circular(16),
                        // ),
                        child: const Center(
                          child: Text(
                            'No inventory found',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              // if (controller.items.isEmpty && !controller.isLoading) {
              //   return const Center(
              //     child: Text('No inventory found'),
              //   );
              // }

              return ListView.separated(
                padding: EdgeInsets.symmetric(
                  horizontal: ASizes.defaultPadding,
                  vertical: 8.h,
                ),
                itemCount: controller.items.length + 1,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  if (index == controller.items.length) {
                    controller.loadMore();
                    return controller.hasMore
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  }

                  return _buildInventoryCard(
                    controller.items[index],
                    controller,
                  );
                },
              );
            }),
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
          Obx(() => _buildChipUI(
                context,
                controller,
                'Type',
                Iconsax.tag,
                controller.selectedSurfboardTypes.isNotEmpty,
              )),
          Obx(() => _buildChipUI(
                context,
                controller,
                'Size',
                Iconsax.size,
                controller.isSizeFilterActive.value,
              )),
        ],
      ),
    );
  }

  // ===========================================================================
  // FILTER CHIPS
  // ===========================================================================

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
        margin: EdgeInsets.only(right: 12.w),
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

            if (type == 'Type') _buildTypeFilterOptions(controller),
            if (type == 'Size') _buildSizeFilterOptions(controller),

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
            onSelected: (_) => controller.toggleSurfboardType(type),
          );
        });
      }).toList(),
    );
  }

  Widget _buildSizeFilterOptions(InventoryController controller) {
    return Form(
      key: controller.sizeFormKey, // optional but recommended
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Label
          Expanded(
            flex: 2,
            child: Text(
              "Surfboard Size",
              style: TextStyle(color: textWhite, fontSize: 14.sp),
            ),
          ),

          // SizedBox(width: 12.w),

          /// Less / Greater toggle
          Obx(
            () => InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: controller.toggleLessThan,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryBlue.withOpacity(0.15),
                ),
                child: Icon(
                  controller.isLessThan.value
                      ? Icons
                            .chevron_left_rounded // <
                      : Icons.chevron_right_rounded, // >
                  color: primaryBlue,
                  size: 22,
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          /// Feet input
          Expanded(
            child: TextFormField(
              controller: controller.feetSizeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Ft',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              style: TextStyle(color: textWhite),
              validator: (v) => AValidator.validateSurfboardFeet(v),
            ),
          ),

          SizedBox(width: 12.w),

          /// Inches input
          Expanded(
            child: TextFormField(
              controller: controller.inchesSizeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'In',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              style: TextStyle(color: textWhite),
              validator: (v) => AValidator.validateSurfboardInches(v),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // INVENTORY CARD
  // ===========================================================================
  Widget _buildInventoryCard(
    InventoryModel item,
    InventoryController controller,
  ) {
    // final status = controller.getStatusDetails(item.status);

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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    color: textWhite,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  item.status.name.toUpperCase(),
                  style: TextStyle(color: textGrey, fontSize: 12.sp),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(Iconsax.size, size: 16.sp, color: textGrey),
                    SizedBox(width: 4.w),
                    Text(
                      '"${item.sizeFeet} ${item.sizeInches} ${item.sizeTotalInches}"',
                      style: TextStyle(color: textGrey, fontSize: 12.sp),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
