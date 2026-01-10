import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../../../../utils/helper/a_device_utils.dart';
import '../controllers/onboard_controller.dart';

class OnBoardingNextButtonWidget extends GetView<OnboardController> {
  const OnBoardingNextButtonWidget({super.key});

  // -- Theme Colors to match the image --
  final Color bgDark = const Color(0xFF101f22); // Dark color for the ICON
  final Color textWhite = const Color(0xFFf0f4f4); // White color for the BUTTON BG

  @override
  Widget build(BuildContext context) {
    return Positioned(
      right: ASizes.defaultSpace,
      // Adjusted height to align with dots
      bottom: ADeviceUtils.getBottomNavigationBarHeight() + 20.h, 
      child: SizedBox(
        width: 50.w,
        height: 50.w,
        child: ElevatedButton(
          onPressed: () => controller.nextPage(),
          style: ElevatedButton.styleFrom(
            backgroundColor: textWhite, // White Background
            shape: const CircleBorder(),
            padding: EdgeInsets.zero,
            elevation: 2,
          ),
          child: Icon(
            Iconsax.arrow_right_3,
            size: 24.w,
            color: bgDark, // Dark Icon
          ),
        ),
      ),
    );
  }
}