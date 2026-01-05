import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../utils/constants/a_sizes.dart';
import '../../../../utils/helper/a_device_utils.dart';
import '../controllers/onboard_controller.dart';

class OnBoardingDotNavigationWidget extends GetView<OnboardController> {
  const OnBoardingDotNavigationWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // final dark = DDeviceUtils.isDarkMode();
    return Positioned(
      bottom: ADeviceUtils.getBottomNavigationBarHeight(),
      left: ASizes.defaultSpace,
      child: SmoothPageIndicator(
        controller: controller.pageController,
        count: 3,
        onDotClicked: controller.dotNavigationClick,
        effect: ExpandingDotsEffect(
          activeDotColor: Theme.of(context).colorScheme.primary,
          // activeDotColor: dark ? DColors.light : DColors.dark,
          dotHeight: 5.h,
        ),
      ),
    );
  }
}
