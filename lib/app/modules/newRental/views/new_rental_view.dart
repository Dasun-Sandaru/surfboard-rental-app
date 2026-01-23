import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_enums.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../models/inventory_model.dart';
import '../controllers/new_rental_controller.dart';

class NewRentalView extends StatelessWidget {
  const NewRentalView({super.key});

  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22);
  final Color cardDark = const Color(0xFF182c30);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color borderDark = const Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewRentalController());

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "New Rental",
          style: TextStyle(
            color: textWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 1. Customer Section
            _buildSectionLabel("Customer"),
            SizedBox(height: 8.h),
            Obx(() => _buildCustomerSelector(controller)),

            SizedBox(height: 24.h),

            /// 2. Rental Dates
            _buildSectionLabel("Rental Period"),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeCard(
                    "Start Date & Time",
                    controller.startDate,
                    controller.startTime,
                    () => controller.pickDate(true),
                    () => controller.pickTime(true),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildDateTimeCard(
                    "Due Date & Time",
                    controller.dueDate,
                    controller.dueTime,
                    () => controller.pickDate(false),
                    () => controller.pickTime(false),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            /// 3. Items Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionLabel("Items"),
                TextButton.icon(
                  onPressed: controller.addItem,
                  icon: Icon(Iconsax.add, size: 18.w, color: primaryBlue),
                  label: Text(
                    "Add Item",
                    style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Items List
            Obx(() {
              if (controller.selectedItems.isEmpty) {
                return _buildEmptyItemState(controller);
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.selectedItems.length,
                separatorBuilder: (c, i) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final item = controller.selectedItems[index];
                  return _buildSelectedItemCard(
                    controller,
                    item,
                    () => controller.removeItem(index),
                  );
                },
              );
            }),

            SizedBox(height: 100.h), // Space for footer
          ],
        ),
      ),

      /// 4. Bottom Footer
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        decoration: BoxDecoration(
          color: bgDark,
          border: Border(top: BorderSide(color: borderDark)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 54.h,
            child: ElevatedButton(
              onPressed: controller.proceedToAgreement,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Draft Agreement",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: textWhite,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  // Icon(Iconsax.arrow_right_3, color: textWhite, size: 20.w),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildRentTypeSelector(NewRentalController controller) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: SegmentedButton<RentType>(
          segments: const [
            ButtonSegment(
              value: RentType.hourly,
              label: Text("Hourly"),
              icon: Icon(Iconsax.clock),
            ),
            ButtonSegment(
              value: RentType.daily,
              label: Text("Daily"),
              icon: Icon(Iconsax.calendar),
            ),
          ],
          selected: {controller.rentType.value},
          onSelectionChanged: (newSelection) {
            controller.rentType.value = newSelection.first;
            controller.calculateTotal();
          },
          style: SegmentedButton.styleFrom(
            backgroundColor: cardDark,
            foregroundColor: textGrey,
            selectedForegroundColor: textWhite,
            selectedBackgroundColor: primaryBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: textWhite,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // -- Customer Selector --
  Widget _buildCustomerSelector(NewRentalController controller) {
    final customer = controller.selectedCustomer.value;
    final bool isSelected = customer != null;

    return InkWell(
      onTap: controller.selectCustomer,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? primaryBlue : borderDark,
            style: isSelected ? BorderStyle.solid : BorderStyle.solid,
          ),
        ),
        child: isSelected
            ? Row(
                children: [
                  CircleAvatar(
                    backgroundColor: primaryBlue.withOpacity(0.2),
                    child: Text(
                      customer.firstName.isNotEmpty
                          ? customer.firstName[0]
                          : "C",
                      style: TextStyle(color: primaryBlue),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${customer.firstName} ${customer.lastName}",
                        style: TextStyle(
                          color: textWhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      Text(
                        customer.phone,
                        style: TextStyle(color: textGrey, fontSize: 14.sp),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(Iconsax.edit, color: textGrey, size: 20.w),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.user_add, color: textGrey),
                  SizedBox(width: 8.w),
                  Text(
                    "Select Customer",
                    style: TextStyle(color: textGrey, fontSize: 16.sp),
                  ),
                ],
              ),
      ),
    );
  }

  // -- Date & Time Picker Card --
  Widget _buildDateTimeCard(
    String title,
    Rx<DateTime> dateObs,
    Rx<TimeOfDay> timeObs,
    VoidCallback onDateTap,
    VoidCallback onTimeTap,
  ) {
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: textGrey, fontSize: 11.sp),
            ),
            SizedBox(height: 8.h),
            // Date Row
            InkWell(
              onTap: onDateTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: bgDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${dateObs.value.day}/${dateObs.value.month}/${dateObs.value.year}",
                      style: TextStyle(
                        color: textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    Icon(Iconsax.calendar_1, color: primaryBlue, size: 16.w),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8.h),
            // Time Row
            InkWell(
              onTap: onTimeTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: bgDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${timeObs.value.hour.toString().padLeft(2, '0')}:${timeObs.value.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        color: textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    Icon(Iconsax.clock, color: primaryBlue, size: 16.w),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -- Empty Item State --
  Widget _buildEmptyItemState(NewRentalController controller) {
    return InkWell(
      onTap: controller.addItem,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderDark,
            style: BorderStyle.solid,
          ), // Dotted better if possible
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.box_add, color: textGrey, size: 32.w),
            SizedBox(height: 8.h),
            Text("No items added yet", style: TextStyle(color: textGrey)),
          ],
        ),
      ),
    );
  }

  // -- Selected Item Card --
  Widget _buildSelectedItemCard(
      NewRentalController controller, InventoryModel item, VoidCallback onRemove) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderDark),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Thumbnail
              Container(
                height: 50.w,
                width: 50.w,
                decoration: BoxDecoration(
                  color: bgDark,
                  borderRadius: BorderRadius.circular(8),
                  image: item.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(item.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: item.imageUrl.isEmpty
                    ? Icon(Iconsax.image, color: textGrey)
                    : null,
              ),

              SizedBox(width: 12.w),

              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        color: textWhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.displaySize,
                      style: TextStyle(color: textGrey, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),

              // Remove Button
              IconButton(
                onPressed: onRemove,
                icon:
                    Icon(Iconsax.minus_cirlce, color: const Color(0xFFEF4444)),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildRentTypeSelector(controller),
        ],
      ),
    );
  }
}
