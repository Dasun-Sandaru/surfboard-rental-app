import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';
import 'package:surfboard_rental_app/utils/common/a_app_bar.dart';
import '../controllers/agreement_template_controller.dart';

class AddEditAgreementTemplateView extends StatelessWidget {
  const AddEditAgreementTemplateView({super.key});

  // -- Theme Colors --
  final Color bgDark = const Color(0xFF101f22);
  final Color cardDark = const Color(0xFF182c30);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);
  final Color borderDark = const Color(0xFF334155);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AgreementTemplateController>();
    final isEditing = controller.isEditing.value;
    final title = isEditing ? "Edit Template" : "Add New Template";

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            color: textWhite,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Template Name
              Text(
                "Template Name",
                style: TextStyle(
                    color: textWhite,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: controller.templateNameController,
                style: TextStyle(color: textWhite),
                decoration: InputDecoration(
                  hintText: 'Enter template name',
                  hintStyle: TextStyle(color: textGrey.withOpacity(0.5)),
                  filled: true,
                  fillColor: cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24.h),

              // Template Content
              Text(
                "Template Content",
                style: TextStyle(
                    color: textWhite,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8.h),
              TextFormField(
                controller: controller.contentController,
                style: TextStyle(color: textWhite),
                maxLines: 10,
                decoration: InputDecoration(
                  hintText: 'Enter template content',
                  hintStyle: TextStyle(color: textGrey.withOpacity(0.5)),
                  filled: true,
                  fillColor: cardDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Content is required';
                  }
                  return null;
                },
              ),
              SizedBox(height: 8.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  "Use placeholders to automatically insert rental information. For example: {{customer.name}}, {{rental.startDate}}, {{rental.totalCost}}.",
                  style: TextStyle(
                    color: textGrey,
                    fontSize: 12.sp,
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.previewTemplate,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: primaryBlue),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Preview",
                        style: TextStyle(
                          color: primaryBlue,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.saveTemplate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        "Save Template",
                        style: TextStyle(
                          color: textWhite,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
