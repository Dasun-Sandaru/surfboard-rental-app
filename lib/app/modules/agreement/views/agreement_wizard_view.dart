import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AgreementController());
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        leadingOnPressed: controller.previousStep, // Back goes to previous step
        centerTitle: true,
        title: Obx(
          () => Text(
            "Step ${controller.currentStep.value + 1} of 4",
            style: TextStyle(color: colorScheme.onSurface, fontSize: 16.sp),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              controller.previousStep();
            },
            icon: Text(
              "Previous",
              style: TextStyle(color: colorScheme.primary, fontSize: 14.sp),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // -- Progress Bar --
          Obx(
            () => LinearProgressIndicator(
              value: (controller.currentStep.value + 1) / 4,
              backgroundColor: colorScheme.surfaceContainer,
              color: colorScheme.primary,
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
          Obx(() {
            if (!controller.isAgreementGenerated.value) {
              return Container(
                padding: EdgeInsets.all(ASizes.defaultPadding),
                child: SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: controller.isGeneratingAgreement.value
                        ? null
                        : controller.nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: Obx(() {
                      if (controller.isGeneratingAgreement.value) {
                        return SizedBox(
                          width: 24.w,
                          height: 24.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: colorScheme.onPrimary,
                          ),
                        );
                      }
                      return Text(
                        controller.currentStep.value == 3
                            ? "Generate Agreement"
                            : "Continue",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }),
                  ),
                ),
              );
            } else {
              return Container(
                padding: EdgeInsets.all(ASizes.defaultPadding),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 54.h,
                        child: OutlinedButton(
                          onPressed: controller.showGeneratedPdf,
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: colorScheme.primary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            "View PDF",
                            style: TextStyle(
                              color: colorScheme.primary,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: ASizes.spaceBtwItems),
                    Expanded(
                      child: SizedBox(
                        height: 54.h,
                        child: ElevatedButton(
                          onPressed: controller.createRental,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: Obx(() {
                            if (controller.isCreatingRental.value) {
                              return CircularProgressIndicator(
                                color: colorScheme.onPrimary,
                              );
                            }
                            return Text(
                              "Create Rental",
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          }),
        ],
      ),
    );
  }
}
