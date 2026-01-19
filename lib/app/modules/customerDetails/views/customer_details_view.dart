import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../controllers/customer_details_controller.dart';


class CustomerDetailsView extends StatelessWidget {
  const CustomerDetailsView({super.key});

  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22);
  final Color cardDark = const Color(0xFF182c30);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color borderDark = const Color(0xFF334155);
  final Color successGreen = const Color(0xFF34C759);
  final Color warningOrange = const Color(0xFFF59E0B);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CustomerDetailsController());

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "Customer Profile",
          style: TextStyle(
            color: textWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: controller.editCustomer,
            child: Text(
              "Edit",
              style: TextStyle(
                color: primaryBlue,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        child: Column(
          children: [
            /// 1. Profile Header & Actions
            _buildProfileHeader(controller),

            SizedBox(height: 24.h),

            /// 2. Personal Info Card
            _buildInfoCard(controller),

            SizedBox(height: 24.h),

            /// 3. History Section
            _buildSectionHeader("Rental History"),
            SizedBox(height: 12.h),
            _buildHistoryList(controller),
            
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildProfileHeader(CustomerDetailsController controller) {
    return Column(
      children: [
        // Avatar
        Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: primaryBlue, width: 2),
          ),
          child: CircleAvatar(
            radius: 40.w,
            backgroundColor: cardDark,
            backgroundImage: NetworkImage(controller.customer['imageUrl']!),
          ),
        ),
        SizedBox(height: 12.h),
        
        // Name
        Text(
          "${controller.customer['first_name']} ${controller.customer['last_name']}",
          style: TextStyle(
            color: textWhite,
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4.h),
        
        // ID Badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderDark),
          ),
          child: Text(
            "ID: ${controller.customer['id']}",
            style: TextStyle(color: textGrey, fontSize: 12.sp),
          ),
        ),

        SizedBox(height: 20.h),

        // Action Buttons Row
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              icon: Iconsax.call, 
              label: "Call", 
              onTap: controller.makeCall
            ),
            SizedBox(width: 16.w),
            _buildActionButton(
              icon: Iconsax.sms, 
              label: "Message", 
              onTap: controller.makeCall // Reuse for now or add SMS logic
            ),
            SizedBox(width: 16.w),
            _buildActionButton(
              icon: Iconsax.direct, 
              label: "Email", 
              onTap: controller.sendEmail
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 80.w,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderDark),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryBlue, size: 24.w),
            SizedBox(height: 6.h),
            Text(label, style: TextStyle(color: textWhite, fontSize: 12.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(CustomerDetailsController controller) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderDark.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          _buildDetailRow("Phone", controller.customer['phone']!, Iconsax.call),
          Divider(color: borderDark, height: 24.h),
          _buildDetailRow("Email", controller.customer['email']!, Iconsax.sms),
          Divider(color: borderDark, height: 24.h),
          _buildDetailRow("NIC / Passport", controller.customer['nic']!, Iconsax.card),
          Divider(color: borderDark, height: 24.h),
          _buildDetailRow("Notes", controller.customer['notes']!, Iconsax.note, isMultiLine: true),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon, {bool isMultiLine = false}) {
    return Row(
      crossAxisAlignment: isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Icon(icon, color: textGrey, size: 20.w),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: textGrey, fontSize: 12.sp)),
              SizedBox(height: 2.h),
              Text(
                value,
                style: TextStyle(
                  color: textWhite, 
                  fontSize: 14.sp, 
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          color: textWhite,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHistoryList(CustomerDetailsController controller) {
    return Obx(() => ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.history.length,
      separatorBuilder: (c, i) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final item = controller.history[index];
        final bool isLate = item['status'] == "Late Return";
        final Color statusColor = isLate ? warningOrange : successGreen;

        return Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: cardDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderDark),
          ),
          child: Row(
            children: [
              // Date Box
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: bgDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      item['date'].split(' ')[0], // Day
                      style: TextStyle(color: textWhite, fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      item['date'].split(' ')[1], // Month
                      style: TextStyle(color: textGrey, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['items'],
                      style: TextStyle(color: textWhite, fontSize: 14.sp, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Iconsax.clock, size: 14.w, color: textGrey),
                        SizedBox(width: 4.w),
                        Text("${item['duration']} • ${item['cost']}", style: TextStyle(color: textGrey, fontSize: 12.sp)),
                      ],
                    ),
                  ],
                ),
              ),

              // Status Pill
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item['status'],
                  style: TextStyle(color: statusColor, fontSize: 10.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        );
      },
    ));
  }
}