import 'dart:typed_data';
import 'package:surfboard_rental_app/utils/common/app_snack_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart';

class SignaturePadController extends GetxController {
  // -- Signature Controller Configuration --
  final SignatureController signaturePadController = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black, // Ink color
    exportBackgroundColor: Colors.white, // Background when saved
  );

  final RxBool isEmpty = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to changes to enable/disable the Save button
    signaturePadController.addListener(() {
      isEmpty.value = signaturePadController.isEmpty;
    });
  }

  @override
  void onClose() {
    signaturePadController.dispose();
    super.onClose();
  }

  void clearSignature() {
    signaturePadController.clear();
  }

  Future<void> saveSignature() async {
    if (signaturePadController.isNotEmpty) {
      // Export as PNG bytes
      final Uint8List? data = await signaturePadController.toPngBytes();

      if (data != null) {
        // Return the image data to the previous screen (Agreement Wizard)
        Get.back(result: data);
        AppSnackBar.success(
          title: "Success",
          message: "Signature saved successfully",
        );
      }
    }
  }
}
