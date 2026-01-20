import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../controllers/agreement_template_controller.dart';

class AgreementTemplateListView extends StatelessWidget {
  const AgreementTemplateListView({super.key});

  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22);
  final Color cardDark = const Color(0xFF182c30);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color borderDark = const Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AgreementTemplateController());

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "Agreement Templates",
          style: TextStyle(
            color: textWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: controller.addTemplate,
            icon: Icon(Iconsax.add, color: primaryBlue, size: 28.w),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          /// 1. Search Bar
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ASizes.defaultPadding,
              vertical: 12.h,
            ),
            color: bgDark, // Match background
            child: TextFormField(
              controller: controller.searchTextController,
              style: TextStyle(color: textWhite),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Iconsax.search_normal,
                  size: 20.w,
                  color: textGrey,
                ),
                hintText: 'Search templates',
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

          /// 2. Template List
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(ASizes.defaultPadding),
              child: Obx(
                () => ListView.separated(
                  padding:
                      EdgeInsets.zero, // Padding handled inside tiles or header
                  itemCount: controller.templates.length,
                  separatorBuilder: (context, index) => Divider(
                    color: borderDark.withOpacity(0.3),
                    height: 1,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    final template = controller.templates[index];
                    return _buildTemplateTile(template, controller);
                  },
                ),
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

  Widget _buildTemplateTile(
    Map<String, dynamic> template,
    AgreementTemplateController controller,
  ) {
    return InkWell(
      onTap: () => controller.editTemplate(template),
      child: Container(
        color: cardDark, // Specific card color requested
        padding: EdgeInsets.symmetric(
          horizontal: ASizes.defaultPadding,
          vertical: 16.h,
        ),
        child: Row(
          children: [
            /// Icon
            Container(
              height: 48.w,
              width: 48.w,
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.document_text,
                color: primaryBlue,
                size: 24.w,
              ),
            ),

            SizedBox(width: 16.w),

            /// Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    template['title'],
                    style: TextStyle(
                      color: textWhite,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Last Updated: ${template['updatedAt']}",
                    style: TextStyle(color: textGrey, fontSize: 13.sp),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            /// Edit Button
            Container(
              height: 36.h,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: bgDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(
                  "Edit",
                  style: TextStyle(
                    color: textWhite,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
