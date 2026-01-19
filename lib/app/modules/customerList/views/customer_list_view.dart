import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../controllers/customer_list_controller.dart';

class CustomerListView extends StatelessWidget {
  const CustomerListView({super.key});

  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22);
  final Color cardDark = const Color(0xFF182c30);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color borderDark = const Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerListController());

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        showbackArrow: true,
        title: Text(
          'Customer List',
          style: TextStyle(
            color: textWhite,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: bgDark,

        actions: [
          IconButton(
            icon: Icon(Iconsax.add_circle, color: primaryBlue, size: 24.w),
            onPressed: () => controller.addCustomer(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// 2. Search Bar (Sticky-like position)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: ASizes.defaultPadding),
              child: TextFormField(
                controller: controller.searchTextController,
                style: TextStyle(color: textWhite),
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Iconsax.search_normal,
                    size: 20.w,
                    color: textGrey,
                  ),
                  hintText: 'Search by name or phone...',
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

            SizedBox(height: 16.h),

            /// 3. Customer List
            Expanded(
              child: Obx(
                () => ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: ASizes.defaultPadding,
                  ),
                  itemCount: controller.customers.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final customer = controller.customers[index];
                    return _buildCustomerCard(customer, controller);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildCustomerCard(
    Map<String, dynamic> customer,
    CustomerListController controller,
  ) {
    return InkWell(
      onTap: () => controller.openCustomerDetails(customer),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(16),
          // Optional: Add subtle border if cards blend too much
          border: Border.all(color: borderDark.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            /// Avatar
            Container(
              height: 56.w,
              width: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(customer['imageUrl']),
                  fit: BoxFit.cover,
                ),
                border: Border.all(
                  color: borderDark,
                ), // Small border around avatar
              ),
            ),

            SizedBox(width: 16.w),

            /// Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    customer['name'],
                    style: TextStyle(
                      color: textWhite,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    customer['phone'],
                    style: TextStyle(color: textGrey, fontSize: 14.sp),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    "Last Rental: ${customer['lastRental']}",
                    style: TextStyle(color: textGrey, fontSize: 12.sp),
                  ),
                ],
              ),
            ),

            /// Arrow
            Icon(Iconsax.arrow_right_3, color: textGrey, size: 20.w),
          ],
        ),
      ),
    );
  }
}
