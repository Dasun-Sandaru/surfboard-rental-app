import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../controllers/onboard_controller.dart';

class OnBoardingDotNavigationWidget extends GetView<OnboardController> {
  const OnBoardingDotNavigationWidget({super.key});

  final Color textWhite = const Color(0xFFf0f4f4);
  final Color inactiveGrey = const Color(0xFF4A5C6A);

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: controller.pageController,
      count: 3,
      onDotClicked: controller.dotNavigationClick,
      effect: ExpandingDotsEffect(
        activeDotColor: textWhite,
        dotColor: inactiveGrey,
        dotHeight: 6.h,
        dotWidth: 8.w,
        expansionFactor: 3,
        spacing: 6.w,
      ),
    );
  }
}
