import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../app/models/rental_model.dart';
import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../../../../utils/theme/app_material_theme.dart';
import '../controllers/rentals_controller.dart';

class RentalsView extends GetView<RentalsController> {
  const RentalsView({super.key});

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
          "Active Rentals",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.refreshRentals,
            icon: Icon(Iconsax.refresh, color: colorScheme.onSurface),
          ),
          SizedBox(width: 8.w),
        ],
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
                hintText: 'Search by Customer or Item...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.5),
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
            child: PagedListView<DocumentSnapshot?, RentalModel>(
              pagingController: controller.pagingController,
              padding: EdgeInsets.symmetric(horizontal: ASizes.defaultPadding),
              builderDelegate: PagedChildBuilderDelegate<RentalModel>(
                itemBuilder: (context, rental, index) => Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: _buildRentalCard(context, rental, controller),
                ),
                noItemsFoundIndicatorBuilder: (context) =>
                    _buildEmptyState(context),
                firstPageErrorIndicatorBuilder: (context) =>
                    _buildErrorState(context),
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

  Widget _buildRentalCard(
    BuildContext context,
    RentalModel rental,
    RentalsController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>();
    final bool isOverdue = rental.expectedReturnTime.isBefore(DateTime.now());

    return InkWell(
      onTap: () => controller.selectRental(rental),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOverdue
                ? colorScheme.error.withOpacity(0.3)
                : Colors.transparent,
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
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.surfing,
                color: colorScheme.onSurface,
                size: 24.w,
              ),
            ),

            SizedBox(width: 16.w),

            /// Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () =>
                        controller.goToCustomerDetails(rental.customerId),
                    child: Text(
                      rental.cachedCustomerName ?? rental.customerId,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  GestureDetector(
                    onTap: () => controller.goToItemDetails(rental.itemId),
                    child: Text(
                      rental.cachedItemName ?? rental.itemId,
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 14.sp,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimeBadge(context, "Start: ${rental.startTime}"),
                      SizedBox(width: 8.w),
                      _buildTimeBadge(
                        context,
                        "Due: ${rental.expectedReturnTime}",
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            /// Status Indicator
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if (isOverdue)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Overdue",
                      style: TextStyle(
                        color: colorScheme.error,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Container(
                    height: 12.w,
                    width: 12.w,
                    decoration: BoxDecoration(
                      color: statusColors?.success ?? Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (statusColors?.success ?? Colors.green)
                              .withOpacity(0.4),
                          blurRadius: 6,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeBadge(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
        fontSize: 12.sp,
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
            child: Icon(
              Iconsax.box,
              size: 40.w,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            "No Active Rentals",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "All boards have been returned.",
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 14.sp,
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
            "Something went wrong!",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "We couldn't load the rentals. Please try again.",
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
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
