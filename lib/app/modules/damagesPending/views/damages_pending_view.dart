import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../app/models/inventory_model.dart';
import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../../../routes/app_pages.dart';
import '../controllers/damages_pending_controller.dart';

class DamagesPendingView extends GetView<DamagesPendingController> {
  const DamagesPendingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "damages_pending".tr,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          /// 1. Search Bar
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ASizes.defaultPadding,
              vertical: 12.h,
            ),
            child: TextFormField(
              controller: controller.searchTextController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Iconsax.search_normal,
                  size: 20.w,
                  color: colorScheme.onSurfaceVariant,
                ),
                hintText: 'search_customer_item'.tr,
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainer,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),

          /// 2. Rental List
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => controller.pagingController.refresh(),
              color: colorScheme.primary,
              child: PagedListView<DocumentSnapshot?, InventoryModel>(
                pagingController: controller.pagingController,
                padding: EdgeInsets.symmetric(horizontal: ASizes.defaultPadding),
                builderDelegate: PagedChildBuilderDelegate<InventoryModel>(
                  itemBuilder: (context, item, index) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _buildItemCard(context, item, controller),
                  ),
                  noItemsFoundIndicatorBuilder: (context) =>
                      _buildEmptyState(context),
                  firstPageErrorIndicatorBuilder: (context) =>
                      _buildErrorState(context),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildItemCard(
    BuildContext context,
    InventoryModel item,
    DamagesPendingController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: () => controller.selectRental(item),
      onLongPress: () => Get.toNamed(Routes.ITEM_DETAILS, arguments: item.id),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.error.withValues(
              alpha: 0.3,
            ), // Red border for damages
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Icon Box
            Container(
              height: 48.w,
              width: 48.w,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Iconsax.warning_2,
                color: colorScheme.error,
                size: 24.w,
              ),
            ),

            SizedBox(width: 16.w),

            /// Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "${item.brand} - ${item.type}",
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      _buildBadge(
                        context,
                        "${'size'.tr}: ${item.displaySize}",
                      ),
                      SizedBox(width: 8.w),
                      _buildBadge(
                        context,
                        "${'color'.tr}: ${item.color}",
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

  Widget _buildBadge(BuildContext context, String text) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outline),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(Iconsax.tick_circle, size: 40.w, color: Colors.green),
          ),
          SizedBox(height: 16.h),
          Text(
            "no_damages_pending".tr,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2, size: 40.w, color: colorScheme.error),
          SizedBox(height: 16.h),
          Text(
            "something_went_wrong".tr,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "load_error_msg".tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => controller.pagingController.refresh(),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text("retry".tr),
          ),
        ],
      ),
    );
  }
}
