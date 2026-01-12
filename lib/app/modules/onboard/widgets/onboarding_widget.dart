import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../../../../utils/helper/a_device_utils.dart';

class OnBoardingWidget extends StatelessWidget {
  const OnBoardingWidget({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
  });

  final String image, title, subtitle;

  final Color bgDark = const Color(0xFF101f22);
  final Color textWhite = const Color(0xFFf0f4f4);
  final Color textGrey = const Color(0xFF94a3b8);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bgDark,
      // Add padding to avoid status bar and give breathing room
      // padding: EdgeInsets.only(top: ADeviceUtils.getAppbarHeight()),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 1. IMAGE SECTION (Changed to 50% for better balance)
          Expanded(
            flex: 2,
            child: Image.asset(
              image,
              width: double.infinity,

              // fit: BoxFit.cover,
            ),
          ),

          /// 2. TEXT SECTION (Changed to 50%)
          Expanded(
            flex: 1,
            child: SizedBox(
              width: double.infinity,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: ASizes.defaultSpace),
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  // Center content vertically in this section
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: textWhite,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: textGrey,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Add space below text so it doesn't hit the nav buttons
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
