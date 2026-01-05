import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/a_sizes.dart';
import '../../../../utils/helper/a_device_utils.dart';
import '../controllers/onboard_controller.dart';

class OnBoardingNextButtonWidget extends GetView<OnboardController> {
  const OnBoardingNextButtonWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: ASizes.defaultSpace,
      bottom: ADeviceUtils.getBottomNavigationBarHeight() / 1.8,
      child: FloatingActionButton(
        // backgroundColor: Color(0xFF173046),
        onPressed: () {
          controller.nextPage();
        },
        child: Icon(
          Iconsax.arrow_right_3,
          size: 30.w,
        ),
      ),
    );
  }
}
