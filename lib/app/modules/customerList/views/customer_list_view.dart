import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../models/customer_model.dart';
import '../../../routes/app_pages.dart';
import '../controllers/customer_list_controller.dart';

class CustomerListView extends GetView<CustomerListController> {
  const CustomerListView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        title: Text(
          'customers'.tr,
          style: TextStyle(color: colorScheme.onSurface),
        ),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        actions: [
          IconButton(
            onPressed: () => controller.addCustomer(),
            icon: Icon(Iconsax.user_add, color: colorScheme.onSurface),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// 1. Header & Search
            Container(
              padding: EdgeInsets.all(ASizes.defaultPadding),
              color: colorScheme.surface,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  TextField(
                    controller: controller.searchController,
                    onChanged: controller.onSearchChanged,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      hintText: "search_name".tr,
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                      prefixIcon: Icon(
                        Iconsax.search_normal,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ],
              ),
            ),

            /// 2. Paged List
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.refreshCustomers,
                color: colorScheme.primary,
                child: PagedListView<dynamic, CustomerModel>.separated(
                  pagingController: controller.pagingController,
                  padding: EdgeInsets.symmetric(
                    horizontal: ASizes.defaultPadding,
                  ),
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  builderDelegate: PagedChildBuilderDelegate<CustomerModel>(
                    itemBuilder: (context, customer, index) =>
                        _buildCustomerCard(context, customer),

                    // -- Loading Indicators --
                    firstPageProgressIndicatorBuilder: (_) => Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    ),
                    newPageProgressIndicatorBuilder: (_) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),

                    // -- Empty State --
                    noItemsFoundIndicatorBuilder: (_) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.people,
                            size: 48.w,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            "no_customers_found".tr,
                            style: TextStyle(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, CustomerModel customer) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.CUSTOMER_DETAILS, arguments: customer);
      },
      onLongPress: () {
        if (controller.isSelectionMode) {
          Get.back(result: customer);
        }
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: colorScheme.primary.withOpacity(0.2),
              child: Text(
                customer.firstName.isNotEmpty ? customer.firstName[0] : "C",
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
                  ),
                ),
                Text(
                  customer.phone,
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
    );
  }
}
