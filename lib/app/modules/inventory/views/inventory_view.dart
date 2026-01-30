import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';
import 'package:surfboard_rental_app/utils/validators/a_validator.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../models/inventory_model.dart';
import '../../../routes/app_pages.dart';
import '../controllers/inventory_controller.dart';

class InventoryListView extends StatelessWidget {
  const InventoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(InventoryController());
    final isSelectionMode = Get.arguments?['selectMode'] ?? false;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        centerTitle: true,
        title: Text(
          isSelectionMode ? 'Select Board' : 'Inventory',
          style: TextStyle(
            color: colorScheme.onSurface,
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
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.add,
                          size: 48.w,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        Text(
                          'No inventory found',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
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
                    return controller.hasMoreItems.value
                        ? const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  }

                  return _buildInventoryCard(
                    context,
                    controller.items[index],
                    controller,
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: !isSelectionMode
          ? FloatingActionButton(
              backgroundColor: colorScheme.primary,
              onPressed: () {
                Get.toNamed(
                  Routes.ADD_INVENTORY,
                  arguments: {'mode': InventoryFormMode.add},
                );
              },
              child: Icon(Iconsax.add, color: colorScheme.onPrimary),
            )
          : null,
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
          Obx(
            () => _buildChipUI(
              context,
              controller,
              'Type',
              Iconsax.tag,
              controller.selectedSurfboardTypes.isNotEmpty,
            ),
          ),
          Obx(
            () => _buildChipUI(
              context,
              controller,
              'Status',
              Iconsax.status,
              controller.selectedStatuses.isNotEmpty,
            ),
          ),
          Obx(
            () => _buildChipUI(
              context,
              controller,
              'Size',
              Iconsax.ruler,
              controller.isSizeFilterActive.value,
            ),
          ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final bgColor = isActive
        ? colorScheme.primary.withOpacity(0.2)
        : colorScheme.secondaryContainer;
    final textColor = isActive ? colorScheme.primary : colorScheme.onSurface;
    final borderColor = isActive ? colorScheme.primary : Colors.transparent;

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
    final colorScheme = Theme.of(context).colorScheme;
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
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
                  color: colorScheme.onSurfaceVariant.withOpacity(0.3),
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
                    color: colorScheme.onSurface,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: controller.resetFilters,
                  child: Text(
                    "Reset",
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            if (type == 'Type') _buildTypeFilterOptions(context, controller),
            if (type == 'Status')
              _buildStatusFilterOptions(context, controller),
            if (type == 'Size') _buildSizeFilterOptions(context, controller),

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

  Widget _buildTypeFilterOptions(
    BuildContext context,
    InventoryController controller,
  ) {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: controller.surfboardTypes.map((type) {
        return Obx(() {
          final isSelected = controller.selectedSurfboardTypes.contains(type);
          return FilterChip(
            label: Text(type.name),
            selected: isSelected,
            onSelected: (_) => controller.toggleSurfboardType(type),
          );
        });
      }).toList(),
    );
  }

  Widget _buildStatusFilterOptions(
    BuildContext context,
    InventoryController controller,
  ) {
    return Wrap(
      spacing: 12.w,
      runSpacing: 12.h,
      children: controller.inventoryStatuses.map((status) {
        return Obx(() {
          final isSelected = controller.selectedStatuses.contains(status);
          return FilterChip(
            label: Text(status.name),
            selected: isSelected,
            onSelected: (_) => controller.toggleStatus(status),
          );
        });
      }).toList(),
    );
  }

  Widget _buildSizeFilterOptions(
    BuildContext context,
    InventoryController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
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
              style: TextStyle(color: colorScheme.onSurface, fontSize: 14.sp),
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
                  color: colorScheme.primary.withOpacity(0.15),
                ),
                child: Icon(
                  controller.isLessThan.value
                      ? Icons
                            .chevron_left_rounded // <
                      : Icons.chevron_right_rounded, // >
                  color: colorScheme.primary,
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
              style: TextStyle(color: colorScheme.onSurface),
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
              style: TextStyle(color: colorScheme.onSurface),
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
    BuildContext context,
    InventoryModel item,
    InventoryController controller,
  ) {
    final isSelectionMode = Get.arguments?['selectMode'] ?? false;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () {
        if (isSelectionMode) {
          Get.back(result: item);
        } else {
          Get.toNamed(Routes.ITEM_DETAILS, arguments: item.id);
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(width: 80.w, height: 80.w, color: colorScheme.surface),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item.status.name.toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Icon(
                        Iconsax.size,
                        size: 16.sp,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '"${item.sizeFeet} ${item.sizeInches} ${item.sizeTotalInches}"',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
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
