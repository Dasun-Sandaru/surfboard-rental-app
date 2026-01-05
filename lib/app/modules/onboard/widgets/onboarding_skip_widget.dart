import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../utils/helper/a_device_utils.dart';
import '../controllers/onboard_controller.dart';

class OnBoardingSkipWidget extends GetView<OnboardController> {
  const OnBoardingSkipWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: ADeviceUtils.getAppbarHeight(),
      right: 20.w,
      child: TextButton(
        onPressed: () {
          controller.skipPage();
        },
        style: TextButton.styleFrom(
          // Remove the default minimum size
          minimumSize: Size.zero,
          // Shrink the button's tap area
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        child: Text(
          'Skip',
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
