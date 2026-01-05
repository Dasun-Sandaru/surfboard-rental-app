import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/common/is_text_field_required.dart';
import '../../../../utils/helper/a_validator.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AAppBar(
        showbackArrow: true,
        leadingIcon: Iconsax.arrow_left,
        centerTitle: true,
        title: const Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: controller.formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Forgot Password".tr,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 10),
              Text(
                "Enter your email and we will send you a link to reset your password.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              /// Email
              IsTextFieldRequired(fieldName: 'Email Address'),
              SizedBox(height: 6.h),

              TextFormField(
                controller: controller.emailController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: Icon(Iconsax.sms, size: 20.w),
                  hintText: 'hello@surfshop.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14.h,
                    horizontal: 16.w,
                  ),
                ),
                validator: (value) =>
                    AValidator.validateText(value, 'E-Mail'.tr),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 2,
                    ),
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Send Reset Link"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
