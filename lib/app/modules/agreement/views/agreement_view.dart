import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:surfboard_rental_app/utils/constants/a_sizes.dart';
import '../../../../utils/common/a_app_bar.dart';
import '../controllers/agreement_controller.dart';
import 'step_board_details.dart';
import 'step_damage_fees.dart';
import 'step_pricing.dart';
import 'step_review.dart';


// Import sub-steps (defined below)


class AgreementWizardView extends StatelessWidget {
  const AgreementWizardView({super.key});

  final Color bgDark = const Color(0xFF101f22);
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color textWhite = const Color(0xFFf0f4f4);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AgreementController());

    return Scaffold(
      backgroundColor: bgDark,
      appBar: AAppBar(
        showbackArrow: true,
        leadingOnPressed: controller.previousStep, // Back goes to previous step
        centerTitle: true,
        title: Obx(
          () => Text(
            "Step ${controller.currentStep.value + 1} of 4",
            style: TextStyle(color: textWhite, fontSize: 16.sp),
          ),
        ),
      ),
      body: Column(
        children: [
          // -- Progress Bar --
          Obx(
            () => LinearProgressIndicator(
              value: (controller.currentStep.value + 1) / 4,
              backgroundColor: bgDark,
              color: primaryBlue,
              minHeight: 6.h,
            ),
          ),

          // -- Content Pages --
          Expanded(
            child: PageView(
              controller: controller.pageController,
              physics: const NeverScrollableScrollPhysics(), // Disable swipe
              children: const [
                StepBoardDetails(),
                StepPricing(),
                StepDamageFees(),
                StepReview(),
              ],
            ),
          ),

          // -- Bottom Button --
          Container(
            padding: EdgeInsets.all(ASizes.defaultPadding),
            child: SizedBox(
              width: double.infinity,
              height: 54.h,
              child: ElevatedButton(
                onPressed: controller.nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Obx(
                  () => Text(
                    controller.currentStep.value == 3
                        ? "Generate Agreement"
                        : "Continue",
                    style: TextStyle(
                      color: textWhite,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
