import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../controllers/onboard_controller.dart';

class OnBoardingDotNavigationWidget extends GetView<OnboardController> {
  const OnBoardingDotNavigationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SmoothPageIndicator(
      controller: controller.pageController,
      count: 3,
      onDotClicked: controller.dotNavigationClick,
      effect: ExpandingDotsEffect(
        activeDotColor: colorScheme.primary,
        dotColor: colorScheme.outlineVariant,
        dotHeight: 6.h,
        dotWidth: 8.w,
        expansionFactor: 3,
        spacing: 6.w,
      ),
    );
  }
}
