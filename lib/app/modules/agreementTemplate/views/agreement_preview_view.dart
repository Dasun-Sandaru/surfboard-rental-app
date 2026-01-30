import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/common/a_app_bar.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';

class AgreementPreviewView extends StatelessWidget {
  const AgreementPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    final String content = Get.arguments as String;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: Text(
          "Template Preview",
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(ASizes.defaultPadding),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SelectableText(
            content,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 14.sp,
              height: 1.5,
              fontFamily: 'Courier', // Monospace for alignment accuracy
            ),
          ),
        ),
      ),
    );
  }
}
