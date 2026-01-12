import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../../../../utils/helper/a_device_utils.dart';
import '../controllers/onboard_controller.dart';

class OnBoardingDotNavigationWidget extends GetView<OnboardController> {
  const OnBoardingDotNavigationWidget({super.key});

  // -- Theme Colors to match the image --
  final Color textWhite = const Color(0xFFf0f4f4);
  // A dark grey that contrasts with the background
  final Color inactiveGrey = const Color(0xFF4A5C6A);

  @override
  Widget build(BuildContext context) {
    return SmoothPageIndicator(
      controller: controller.pageController,
      count: 3,
      onDotClicked: controller.dotNavigationClick,
      effect: ExpandingDotsEffect(
        activeDotColor: textWhite, // Active is WHITE
        dotColor: inactiveGrey, // Inactive is DARK GREY
        dotHeight: 6.h,
        dotWidth: 8.w,
        expansionFactor: 3,
        spacing: 6.w,
      ),
    );
  }
}
