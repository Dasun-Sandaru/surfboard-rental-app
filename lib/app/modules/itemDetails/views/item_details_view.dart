import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/helper/a_formatter.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../../../../utils/theme/app_material_theme.dart';
import '../controllers/item_details_controller.dart';

class ItemDetailsView extends GetView<ItemDetailsController> {
  const ItemDetailsView({super.key});

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
          "item_details".tr,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.showQR,
            icon: Icon(Iconsax.scan_barcode, color: colorScheme.onSurface),
            tooltip: 'Show QR Code',
          ),
          TextButton(
            onPressed: controller.editItem,
            child: Text(
              "edit".tr,
              style: TextStyle(
                color: colorScheme.primary,
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
              return Center(child: Text('item_not_found'.tr));
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
                    color: colorScheme.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    image: item.imageUrl.isNotEmpty && item.imageUrl != '000'
                        ? DecorationImage(
                            image: NetworkImage(item.imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: item.imageUrl.isEmpty || item.imageUrl == '000'
                      ? Center(
                          child: Text(
                            "no_image".tr,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : null,
                ),

                SizedBox(height: 16.h),

                _buildDetailRow(context, "item_id".tr, item.id),
                _buildDetailRow(
                  context,
                  "name".tr,
                  item.name,
                ), // Added 'name' key? Ah I added 'full_name' and 'enter_name'. I should use 'shop_details_sub' which has 'Name'. Or just 'Name'. I'll add 'name': 'Name' to app_translations if missing. I have 'enter_name'. I'll use 'full_name' or just 'Name'. I'll use 'name' and add it if missing, or use 'full_name' as a fallback? 'full_name' is "Full Name". "Name" is just "Name".
                // I'll check if 'name' key exists previously. I saw 'shop_details_sub': 'Name, Location...'.
                // I'll use "name" key and add it to app_translations in next batch if needed. Actually 'name' is very common.
                // I will add 'name': 'Name' now to app_translations in next step.
                // For now in this file I'll use "name".tr.
                _buildDetailRow(context, "brand".tr, item.brand),
                _buildDetailRow(context, "color".tr, item.color),
                _buildDetailRow(context, "type".tr, item.type),
                _buildDetailRow(context, "volume".tr, '${item.volume}L'),
                _buildDetailRow(
                  context,
                  "size".tr,
                  "${item.sizeFeet}' ${item.sizeInches}\"",
                ),

                _buildDetailRow(
                  context,
                  "status".tr,
                  item.status.name.toUpperCase(),
                ),
                _buildDetailRow(
                  context,
                  "purchase_cost".tr,
                  AFormatter.formatCurrency(item.purchaseCost),
                ),
                _buildDetailRow(
                  context,
                  "rental_rate_hr".tr,
                  AFormatter.formatCurrency(item.rentalRateHour),
                ),
                _buildDetailRow(
                  context,
                  "rental_rate_day".tr,
                  AFormatter.formatCurrency(item.rentalRateDay),
                ),
                _buildDetailRow(
                  context,
                  "damage_fee_rule".tr,
                  item.damageFeeRule,
                ),
                _buildDetailRow(context, "notes".tr, item.note),
                _buildDetailRow(
                  context,
                  "created_at".tr,
                  AFormatter.formatDate(item.createdAt),
                  isLast: true,
                ),
              ],
            );
          });
        },
      ),
      bottomNavigationBar: _buildBottomNav(context, controller),
    );
  }

  Widget _buildBottomNav(
    BuildContext context,
    ItemDetailsController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final statusColors = Theme.of(context).extension<StatusColors>();

    return Obx(() {
      final item = controller.item.value;
      if (item == null) {
        return const SizedBox.shrink();
      }

      return Container(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outline)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Mark as Repair Button
              if (item.status == InventoryStatus.damaged) ...[
                Expanded(
                  child: ElevatedButton(
                    onPressed: controller.markAsRepair,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColors?.warning ?? Colors.orange,
                      foregroundColor: colorScheme.surface,
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
                          "mark_repair".tr,
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
              ],
              // View Damage Fees Button
              Expanded(
                child: TextButton(
                  onPressed: controller.viewDamageFees,
                  style: TextButton.styleFrom(
                    backgroundColor: colorScheme.primary.withOpacity(0.15),
                    foregroundColor: colorScheme.primary,
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
                        "view_damage_fees".tr,
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
        ),
      );
    });
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isLast = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.outline),
          bottom: isLast
              ? BorderSide(color: colorScheme.outline)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 14.sp,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: TextStyle(
                color: colorScheme.onSurface,
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
