import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/onboard_controller.dart';

class OnBoardingNextButtonWidget extends GetView<OnboardController> {
  const OnBoardingNextButtonWidget({super.key});

  final Color bgDark = const Color(0xFF101f22);
  final Color textWhite = const Color(0xFFf0f4f4);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50.w,
      height: 50.w,
      child: ElevatedButton(
        onPressed: () => controller.nextPage(),
        style: ElevatedButton.styleFrom(
          backgroundColor: textWhite,
          shape: const CircleBorder(),
          padding: EdgeInsets.zero,
          elevation: 2,
        ),
        child: Icon(Iconsax.arrow_right_3, size: 24.w, color: bgDark),
      ),
    );
  }
}
