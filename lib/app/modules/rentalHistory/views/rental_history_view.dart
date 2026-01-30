import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:surfboard_rental_app/app/models/rental_model.dart';
import 'package:surfboard_rental_app/utils/common/a_app_bar.dart';
import 'package:surfboard_rental_app/utils/constants/a_enums.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';
import 'package:surfboard_rental_app/utils/theme/app_material_theme.dart';
import '../../../../utils/helper/a_formatter.dart';
import '../controllers/rental_history_controller.dart';

class RentalHistoryView extends GetView<RentalHistoryController> {
  const RentalHistoryView({super.key});

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
          "Rental History",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          /// 1. Search Bar & Date Filter
          Padding(
            padding: EdgeInsets.fromLTRB(
              ASizes.defaultPadding,
              12.h,
              ASizes.defaultPadding,
              8.h,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.searchTextController,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      prefixIcon: Icon(
                        Iconsax.search_normal,
                        size: 20.w,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      hintText: 'Search...',
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
                SizedBox(width: 8.w),
                Obx(() {
                  final hasDateFilter = controller.dateRange.value != null;
                  return IconButton(
                    onPressed: () => controller.pickDateRange(context),
                    style: IconButton.styleFrom(
                      backgroundColor: hasDateFilter
                          ? colorScheme.primary
                          : colorScheme.surfaceContainer,
                      padding: EdgeInsets.all(12.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: Icon(
                      Iconsax.calendar_1,
                      color: hasDateFilter
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                      size: 24.w,
                    ),
                  );
                }),
                // Optional: Clear date filter button if needed, but icon color change indicates state.
                Obx(() {
                  if (controller.dateRange.value != null) {
                    return Padding(
                      padding: EdgeInsets.only(left: 4.w),
                      child: IconButton(
                        onPressed: controller.clearDateRange,
                        icon: Icon(
                          Icons.close,
                          color: colorScheme.onSurfaceVariant,
                          size: 20.w,
                        ),
                        tooltip: 'Clear Date Filter',
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          ),

          /// 2. Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: ASizes.defaultPadding),
            child: Row(
              children: [
                _buildFilterChip(context, 'All', null),
                SizedBox(width: 8.w),
                _buildFilterChip(
                  context,
                  'Active',
                  RentalStatus.active,
                  Colors.orange,
                ),
                SizedBox(width: 8.w),
                _buildFilterChip(
                  context,
                  'Completed',
                  RentalStatus.completed,
                  Colors.green,
                ),
                SizedBox(width: 8.w),
                _buildFilterChip(
                  context,
                  'Overdue',
                  RentalStatus.overdue,
                  Colors.red,
                ),
                SizedBox(width: 8.w),
                _buildFilterChip(
                  context,
                  'Returned',
                  RentalStatus.item_returned,
                  Colors.blue,
                ),
                SizedBox(width: 8.w),
                _buildFilterChip(
                  context,
                  'Cancelled',
                  RentalStatus.cancelled,
                  Colors.grey,
                ),
                SizedBox(width: 8.w),
                _buildFilterChip(
                  context,
                  'Damaged',
                  RentalStatus.mark_as_damaged,
                  Colors.redAccent,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          /// 3. Rental List
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refreshRentals,
              child: PagedListView<DocumentSnapshot?, RentalModel>(
                pagingController: controller.pagingController,
                padding: EdgeInsets.symmetric(
                  horizontal: ASizes.defaultPadding,
                ),
                builderDelegate: PagedChildBuilderDelegate<RentalModel>(
                  itemBuilder: (context, rental, index) => Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: _buildRentalCard(context, rental),
                  ),
                  noItemsFoundIndicatorBuilder: (context) =>
                      _buildEmptyState(context),
                  firstPageErrorIndicatorBuilder: (context) =>
                      _buildErrorState(context),
                  newPageErrorIndicatorBuilder: (context) =>
                      _buildErrorState(context),
                  firstPageProgressIndicatorBuilder: (context) =>
                      const Center(child: CircularProgressIndicator()),
                  newPageProgressIndicatorBuilder: (context) => Padding(
                    padding: EdgeInsets.all(16.w),
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    RentalStatus? status, [
    Color? color,
  ]) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      final isSelected = controller.selectedFilter.value == status;
      return FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            controller.updateFilter(status);
          } else {
            if (status != null) controller.updateFilter(null);
          }
        },
        selectedColor: (color ?? colorScheme.primary).withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected
              ? (color ?? colorScheme.primary)
              : colorScheme.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: colorScheme.surfaceContainer,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        checkmarkColor: color ?? colorScheme.primary,
      );
    });
  }

  Widget _buildRentalCard(BuildContext context, RentalModel rental) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>();
    final bool isOverdue =
        rental.expectedReturnTime.isBefore(DateTime.now()) &&
        rental.status == RentalStatus.active;

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          rental.cachedCustomerName ?? rental.customerId,
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusBadge(
                        context,
                        rental,
                        statusColors,
                        colorScheme,
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),
                  Text(
                    rental.cachedItemName ?? rental.itemId,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontSize: 14.sp,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimeBadge(
                        context,
                        "Start: ${AFormatter.formatDate(rental.startTime)}",
                      ),
                      SizedBox(width: 8.w),
                      if (rental.actualReturnTime != null)
                        _buildTimeBadge(
                          context,
                          "Returned: ${AFormatter.formatDate(rental.actualReturnTime)}",
                        )
                      else
                        _buildTimeBadge(
                          context,
                          "Due: ${AFormatter.formatDate(rental.expectedReturnTime)}",
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

  Widget _buildStatusBadge(
    BuildContext context,
    RentalModel rental,
    StatusColors? statusColors,
    ColorScheme colorScheme,
  ) {
    String text;
    Color color;

    switch (rental.status) {
      case RentalStatus.active:
        if (rental.expectedReturnTime.isBefore(DateTime.now())) {
          text = 'Overdue';
          color = colorScheme.error;
        } else {
          text = 'Active';
          color = statusColors?.warning ?? Colors.orange;
        }
        break;
      case RentalStatus.completed:
        text = 'Completed';
        color = statusColors?.success ?? Colors.green;
        break;
      case RentalStatus.item_returned:
        text = 'Returned';
        color = Colors.blue;
        break;
      case RentalStatus.mark_as_damaged:
        text = 'Damaged';
        color = colorScheme.error;
        break;
      case RentalStatus.cancelled:
        text = 'Cancelled';
        color = Colors.grey;
        break;
      default:
        text = rental.status.name;
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
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
          Icon(
            Iconsax.receipt,
            size: 64.w,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            "No Rentals Found",
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            "Try adjusting your filters",
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
          SizedBox(height: 8.h),
          ElevatedButton(
            onPressed: () => controller.pagingController.refresh(),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
