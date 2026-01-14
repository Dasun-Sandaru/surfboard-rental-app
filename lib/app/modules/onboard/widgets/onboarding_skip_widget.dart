import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/onboard_controller.dart';

class OnBoardingSkipWidget extends GetView<OnboardController> {
  const OnBoardingSkipWidget({super.key});

  final Color textSubtle = const Color(0xFF94a3b8);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => controller.skipPage(),
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,

        backgroundColor: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      ),
      child: Text(
        'Skip',
        style: TextStyle(
          color: textSubtle,
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
