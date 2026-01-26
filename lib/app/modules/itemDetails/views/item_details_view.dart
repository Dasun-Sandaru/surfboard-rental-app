import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../controllers/item_details_controller.dart';

class ItemDetailsView extends GetView<ItemDetailsController> {
  const ItemDetailsView({super.key});

  // -- Theme Colors --
  static const Color bgDark = Color(0xFF101f22);
  static const Color cardDark = Color(0xFF182c30);
  static const Color primaryBlue = Color(0xFF4A90E2);
  static const Color textWhite = Color(0xFFf0f4f4);
  static const Color textGrey = Color(0xFF94a3b8);
  static const Color borderDark = Color(0xFF334155);

  // Status Colors
  static const Color statusGreen = Color(0xFF28A745);
  static const Color statusYellow = Color(0xFFEAB308);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "Item Details",
          style: TextStyle(
            color: textWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: controller.editItem,
            child: Text(
              "Edit",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: GetBuilder<ItemDetailsController>(
        builder: (ctrl) {
          return Obx(() {
            if (ctrl.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (ctrl.item.value == null) {
              return const Center(child: Text('Item not found'));
            }

            final item = ctrl.item.value!;

            return ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                /// Image placeholder
                Container(
                  height: 200.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardDark,
                    borderRadius: BorderRadius.circular(16),
                    image: item.imageUrl.isNotEmpty && item.imageUrl != '000'
                        ? DecorationImage(
                            image: NetworkImage(item.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.imageUrl.isEmpty || item.imageUrl == '000'
                      ? const Center(
                          child: Text(
                            "No Image",
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : null,
                ),

                SizedBox(height: 16.h),

                _buildDetailRow("Item ID", item.id),
                _buildDetailRow("Name", item.name),
                _buildDetailRow("Brand", item.brand),
                _buildDetailRow("Color", item.color),
                _buildDetailRow("Type", item.type),
                _buildDetailRow("Volume", '${item.volume}L'),
                _buildDetailRow(
                  "Size",
                  "${item.sizeFeet}' ${item.sizeInches}\"",
                ),

                _buildDetailRow("Status", item.status.name.toUpperCase()),
                _buildDetailRow("Purchase Cost", '\$${item.purchaseCost}'),
                _buildDetailRow("Rental Rate (hr)", '\$${item.rentalRateHour}'),
                _buildDetailRow("Rental Rate (day)", '\$${item.rentalRateDay}'),
                _buildDetailRow("Damage Fee Rule", item.damageFeeRule),
                _buildDetailRow("Note", item.note),
                _buildDetailRow(
                  "Created At",
                  DateFormat.yMMMd().format(item.createdAt),
                  isLast: true,
                ),
              ],
            );
          });
        },
      ),
      bottomNavigationBar: _buildBottomNav(controller),
    );
  }

  Widget _buildBottomNav(ItemDetailsController controller) {
    return Container(
      padding: EdgeInsets.all(ASizes.defaultPadding),
      decoration: BoxDecoration(
        color: bgDark,
        border: const Border(top: BorderSide(color: borderDark)),
      ),
      child: Row(
        children: [
          // Mark as Repair Button
          Expanded(
            child: ElevatedButton(
              onPressed: controller.markAsRepair,
              style: ElevatedButton.styleFrom(
                backgroundColor: statusYellow,
                foregroundColor: Colors.black87, // Dark text on yellow
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.setting_2, size: 20.w),
                  SizedBox(width: 8.w),
                  Text(
                    "Mark as Repair",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // View Damage Fees Button
          Expanded(
            child: TextButton(
              onPressed: controller.viewDamageFees,
              style: TextButton.styleFrom(
                backgroundColor: primaryBlue.withOpacity(0.15),
                foregroundColor: primaryBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.receipt, size: 20.w),
                  SizedBox(width: 8.w),
                  Text(
                    "View Damage Fees",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        border: Border(
          top: const BorderSide(color: borderDark),
          bottom: isLast
              ? const BorderSide(color: borderDark)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(color: textGrey, fontSize: 14.sp),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: TextStyle(
                color: textWhite,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
