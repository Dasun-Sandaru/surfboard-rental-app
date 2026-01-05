import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../../../../utils/constants/a_image_strings.dart';
import '../../../../utils/constants/a_text_string.dart';
import '../controllers/onboard_controller.dart';
import '../widgets/onboarding_dot_navigation_widget.dart';
import '../widgets/onboarding_next_button_widget.dart';
import '../widgets/onboarding_skip_widget.dart';
import '../widgets/onboarding_widget.dart';

class OnboardView extends GetView<OnboardController> {
  const OnboardView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// horizonatl scrollable pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnBoardingWidget(
                image: AImageStrings.onboardOne,
                title: ATextString.onBoardingTitle1,
                subtitle: ATextString.onBoardingSubTitle1,
              ),
              OnBoardingWidget(
                image: AImageStrings.onboardTwo,
                title: ATextString.onBoardingTitle2,
                subtitle: ATextString.onBoardingSubTitle2,
              ),
              OnBoardingWidget(
                image: AImageStrings.onboardThree,
                title: ATextString.onBoardingTitle3,
                subtitle: ATextString.onBoardingSubTitle3,
              ),
            ],
          ),
          // skip button
          const OnBoardingSkipWidget(),

          /// dot navigation smmoth page indicatior
          const OnBoardingDotNavigationWidget(),

          /// circulor button
          const OnBoardingNextButtonWidget(),
        ],
      ),
    );
  }
}
