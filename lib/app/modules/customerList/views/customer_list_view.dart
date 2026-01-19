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

  final Color bgDark = const Color(0xFF101f22);
  final Color cardDark = const Color(0xFF182c30);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color primaryBlue = const Color(0xFF4A90E2);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        title: Text('Customers', style: TextStyle(color: textWhite)),
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: textWhite),
        actions: [
          IconButton(
            onPressed: () => controller.addCustomer(),
            icon: Icon(Iconsax.user_add, color: textWhite),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// 1. Header & Search
            Container(
              padding: EdgeInsets.all(ASizes.defaultPadding),
              color: bgDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  TextField(
                    controller: controller.searchController,
                    onChanged: controller.onSearchChanged,
                    style: TextStyle(color: textWhite),
                    decoration: InputDecoration(
                      hintText: "Search name...",
                      hintStyle: TextStyle(color: textGrey),
                      prefixIcon: Icon(Iconsax.search_normal, color: textGrey),
                      filled: true,
                      fillColor: cardDark,
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
                color: const Color(0xFF4A90E2),
                child: PagedListView<dynamic, CustomerModel>.separated(
                  pagingController: controller.pagingController,
                  padding: EdgeInsets.symmetric(
                    horizontal: ASizes.defaultPadding,
                  ),
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  builderDelegate: PagedChildBuilderDelegate<CustomerModel>(
                    itemBuilder: (context, customer, index) =>
                        _buildCustomerCard(customer),

                    // -- Loading Indicators --
                    firstPageProgressIndicatorBuilder: (_) => Center(
                      child: CircularProgressIndicator(color: primaryBlue),
                    ),
                    newPageProgressIndicatorBuilder: (_) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: CircularProgressIndicator(color: primaryBlue),
                      ),
                    ),

                    // -- Empty State --
                    noItemsFoundIndicatorBuilder: (_) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Iconsax.people, size: 48.w, color: textGrey),
                          SizedBox(height: 8.h),
                          Text(
                            "No customers found",
                            style: TextStyle(color: textGrey),
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

  Widget _buildCustomerCard(CustomerModel customer) {
    return InkWell(
      onTap: () {
        Get.toNamed(Routes.CUSTOMER_DETAILS, arguments: customer);
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color(0xFF4A90E2).withOpacity(0.2),
              child: Text(
                customer.firstName.isNotEmpty ? customer.firstName[0] : "C",
                style: TextStyle(color: textWhite),
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
                  ),
                ),
                Text(
                  customer.phone,
                  style: TextStyle(color: textGrey, fontSize: 12.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
