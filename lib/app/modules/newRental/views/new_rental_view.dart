import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../../utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../models/inventory_model.dart';
import '../controllers/new_rental_controller.dart';

class NewRentalView extends StatelessWidget {
  const NewRentalView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NewRentalController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "new_rental".tr,
          style: TextStyle(
            color: colorScheme.onSurface,
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
            _buildSectionLabel(context, "customer_section".tr),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: Obx(() => _buildCustomerSelector(context, controller)),
                ),
                SizedBox(width: 12.w),
                InkWell(
                  onTap: controller.scanCustomer,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 60.w,
                    width: 60.w,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: colorScheme.outline),
                    ),
                    child: Center(
                      child: Icon(
                        Iconsax.scan,
                        size: 28.w,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 24.h),

            /// 2. Rental Dates
            _buildSectionLabel(context, "rental_period".tr),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _buildDateTimeCard(
                    context,
                    "start_date_time".tr,
                    controller.startDate,
                    controller.startTime,
                    () => controller.pickDate(true),
                    () => controller.pickTime(true),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildDateTimeCard(
                    context,
                    "due_date_time".tr,
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
                _buildSectionLabel(context, "items_section".tr),
                Row(
                  children: [
                    TextButton.icon(
                      onPressed: controller.addItem,
                      icon: Icon(
                        Iconsax.add,
                        size: 18.w,
                        color: colorScheme.primary,
                      ),
                      label: Text(
                        "add_item".tr,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    IconButton(
                      onPressed: controller.scanItem,
                      icon: Icon(
                        Iconsax.scan_barcode,
                        size: 20.w,
                        color: colorScheme.primary,
                      ),
                      tooltip: "scan_item_tooltip".tr,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Items List
            Obx(() {
              if (controller.selectedItems.isEmpty) {
                return _buildEmptyItemState(context, controller);
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: controller.selectedItems.length,
                separatorBuilder: (c, i) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final item = controller.selectedItems[index];
                  return _buildSelectedItemCard(
                    context,
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
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outline)),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 54.h,
            child: ElevatedButton(
              onPressed: controller.proceedToAgreement,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 4,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "draft_agreement".tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
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

  Widget _buildRentTypeSelector(
    BuildContext context,
    NewRentalController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: SegmentedButton<RentType>(
          segments: [
            ButtonSegment(
              value: RentType.hourly,
              label: Text("hourly".tr),
              icon: Icon(Iconsax.clock),
            ),
            ButtonSegment(
              value: RentType.daily,
              label: Text("daily".tr),
              icon: Icon(Iconsax.calendar),
            ),
          ],
          selected: {controller.rentType.value},
          onSelectionChanged: (newSelection) {
            controller.rentType.value = newSelection.first;
            controller.calculateTotal();
          },
          style: SegmentedButton.styleFrom(
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurfaceVariant,
            selectedForegroundColor: colorScheme.onPrimary,
            selectedBackgroundColor: colorScheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // -- Customer Selector --
  Widget _buildCustomerSelector(
    BuildContext context,
    NewRentalController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final customer = controller.selectedCustomer.value;
    final bool isSelected = customer != null;

    return InkWell(
      onTap: controller.selectCustomer,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline,
          ),
        ),
        child: isSelected
            ? Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.2),
                    child: Text(
                      customer.firstName.isNotEmpty
                          ? customer.firstName[0]
                          : "C",
                      style: TextStyle(color: colorScheme.primary),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${customer.firstName} ${customer.lastName}",
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                      Text(
                        customer.phone,
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Icon(
                    Iconsax.edit,
                    color: colorScheme.onSurfaceVariant,
                    size: 20.w,
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.user_add, color: colorScheme.onSurfaceVariant),
                  SizedBox(width: 8.w),
                  Text(
                    "select_customer".tr,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 16.sp,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // -- Date & Time Picker Card --
  Widget _buildDateTimeCard(
    BuildContext context,
    String title,
    Rx<DateTime> dateObs,
    Rx<TimeOfDay> timeObs,
    VoidCallback onDateTap,
    VoidCallback onTimeTap,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(
      () => Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 11.sp,
              ),
            ),
            SizedBox(height: 8.h),
            // Date Row
            InkWell(
              onTap: onDateTap,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${dateObs.value.day}/${dateObs.value.month}/${dateObs.value.year}",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    Icon(
                      Iconsax.calendar_1,
                      color: colorScheme.primary,
                      size: 16.w,
                    ),
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
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${timeObs.value.hour.toString().padLeft(2, '0')}:${timeObs.value.minute.toString().padLeft(2, '0')}",
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp,
                      ),
                    ),
                    Icon(Iconsax.clock, color: colorScheme.primary, size: 16.w),
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
  Widget _buildEmptyItemState(
    BuildContext context,
    NewRentalController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: controller.addItem,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 100.h,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.box_add,
              color: colorScheme.onSurfaceVariant,
              size: 32.w,
            ),
            SizedBox(height: 8.h),
            Text(
              "no_items_added".tr,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  // -- Selected Item Card --
  Widget _buildSelectedItemCard(
    BuildContext context,
    NewRentalController controller,
    InventoryModel item,
    VoidCallback onRemove,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outline),
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
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  image: item.imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(item.imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: item.imageUrl.isEmpty
                    ? Icon(Iconsax.image, color: colorScheme.onSurfaceVariant)
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
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      item.displaySize,
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ),

              // Remove Button
              IconButton(
                onPressed: onRemove,
                icon: Icon(Iconsax.minus_cirlce, color: colorScheme.error),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildRentTypeSelector(context, controller),
        ],
      ),
    );
  }
}
