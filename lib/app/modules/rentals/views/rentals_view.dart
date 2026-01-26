import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../app/models/rental_model.dart';
import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../controllers/rentals_controller.dart';

class RentalsView extends GetView<RentalsController> {
  const RentalsView({super.key});

  // -- Theme Colors --
  static const Color bgDark = Color(0xFF101f22);
  static const Color cardDark = Color(0xFF182c30);
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color textWhite = Color(0xFFf0f4f4);
  static const Color textGrey = Color(0xFF94a3b8);
  static const Color borderDark = Color(0xFF334155);
  static const Color successGreen = Color(0xFF34C759);
  static const Color errorRed = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "Active Rentals",
          style: TextStyle(
            color: textWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.refreshRentals,
            icon: Icon(Iconsax.refresh, color: textWhite),
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
              style: TextStyle(color: textWhite),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Iconsax.search_normal,
                  size: 20.w,
                  color: textGrey,
                ),
                hintText: 'Search by Customer or Item...',
                hintStyle: TextStyle(color: textGrey.withOpacity(0.5)),
                filled: true,
                fillColor: cardDark,
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
                  child: _buildRentalCard(rental, controller),
                ),
                noItemsFoundIndicatorBuilder: (context) => _buildEmptyState(),
                firstPageErrorIndicatorBuilder: (context) => _buildErrorState(),
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

  Widget _buildRentalCard(RentalModel rental, RentalsController controller) {
    final bool isOverdue = rental.expectedReturnTime.isBefore(DateTime.now());

    return InkWell(
      onTap: () => controller.selectRental(rental),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOverdue ? errorRed.withOpacity(0.3) : Colors.transparent,
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
                color: bgDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.surfing, color: textWhite, size: 24.w),
            ),

            SizedBox(width: 16.w),

            /// Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rental.id ?? 'N/A',
                    style: TextStyle(
                      color: textWhite,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    rental.itemId,
                    style: TextStyle(color: textGrey, fontSize: 14.sp),
                  ),
                  SizedBox(height: 8.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTimeBadge("Start: ${rental.startTime}"),
                      SizedBox(width: 8.w),
                      _buildTimeBadge("Due: ${rental.expectedReturnTime}"),
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
                      color: errorRed.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "Overdue",
                      style: TextStyle(
                        color: errorRed,
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
                      color: successGreen,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: successGreen.withOpacity(0.4),
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

  Widget _buildTimeBadge(String text) {
    return Text(
      text,
      style: TextStyle(color: textGrey.withOpacity(0.7), fontSize: 12.sp),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(color: cardDark, shape: BoxShape.circle),
            child: Icon(Iconsax.box, size: 40.w, color: textGrey),
          ),
          SizedBox(height: 16.h),
          Text(
            "No Active Rentals",
            style: TextStyle(
              color: textWhite,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "All boards have been returned.",
            style: TextStyle(color: textGrey, fontSize: 14.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.warning_2, size: 40.w, color: errorRed),
          SizedBox(height: 16.h),
          Text(
            "Something went wrong!",
            style: TextStyle(
              color: textWhite,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "We couldn't load the rentals. Please try again.",
            textAlign: TextAlign.center,
            style: TextStyle(color: textGrey, fontSize: 14.sp),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => controller.pagingController.refresh(),
            style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }
}
