import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/helper/a_formatter.dart';
import '../../../../utils/constants/a_sizes.dart';

import '../../../../utils/common/a_app_bar.dart';
import '../../../models/agreement_template_model.dart';
import '../controllers/agreement_template_controller.dart';

class AgreementTemplateListView extends StatelessWidget {
  const AgreementTemplateListView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AgreementTemplateController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: controller.addDefaultTemplate,
        backgroundColor: colorScheme.primary,
        child: Icon(Iconsax.add, color: colorScheme.onPrimary, size: 28.w),
      ),
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "Agreement Templates",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          /// 1. Search Bar
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ASizes.defaultPadding,
              vertical: 12.h,
            ),
            color: colorScheme.surface, // Match background
            child: TextFormField(
              controller: controller.searchTextController,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Iconsax.search_normal,
                  size: 20.w,
                  color: colorScheme.onSurfaceVariant,
                ),
                hintText: 'Search templates',
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainer,
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
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  );
                }

                if (controller.filteredTemplates.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.document_text_1,
                          size: 60,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No Templates Found',
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 16.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Add a new template to get started.',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 14.sp,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: controller.filteredTemplates.length,
                  separatorBuilder: (context, index) => Divider(
                    color: colorScheme.outline.withValues(alpha: 0.3),
                    height: 1,
                    thickness: 1,
                  ),
                  itemBuilder: (context, index) {
                    final template = controller.filteredTemplates[index];
                    return _buildTemplateTile(context, template, controller);
                  },
                );
              }),
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
    BuildContext context,
    AgreementTemplateModel template,
    AgreementTemplateController controller,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => controller.editTemplate(template),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ASizes.defaultPadding,
          vertical: 16.h,
        ),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.only(bottom: 8.h),
        child: Row(
          children: [
            /// Icon
            Container(
              height: 48.w,
              width: 48.w,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.document_text,
                color: colorScheme.primary,
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
                    template.templateName,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Last Updated: ${AFormatter.formatDate(template.updatedAt)}",
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13.sp,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(width: 12.w),

            /// Edit Icon
            Icon(
              Iconsax.arrow_right_3,
              color: colorScheme.onSurfaceVariant,
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }
}