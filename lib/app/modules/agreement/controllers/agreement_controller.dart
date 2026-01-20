import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AgreementController extends GetxController {
  // -- Step Management --
  final RxInt currentStep = 0.obs;
  final PageController pageController = PageController();

  // -- 1. Board Details --
  final RxString selectedBoard = ''.obs;
  final RxList<String> selectedAccessories = <String>[].obs;

  // -- 2. Duration & Pricing --
  final rentalPriceController = TextEditingController();
  final RxString rentalDuration = '1 Day'.obs;
  final RxBool requireDeposit = false.obs;
  final depositController = TextEditingController();

  // -- 3. Damage Fees --
  // We use a Map to store enabled state and price
  final RxMap<String, Map<String, dynamic>> damageFees =
      <String, Map<String, dynamic>>{
        "Broken Fin": {"enabled": false, "price": 0.0},
        "Snapped Leash": {"enabled": false, "price": 0.0},
        "Major Ding": {"enabled": false, "price": 0.0},
        "Buckled Board": {"enabled": false, "price": 0.0},
      }.obs;

  void nextStep() {
    if (currentStep.value < 4) {
      // Assuming 5 steps total
      currentStep.value++;
      pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Submit / Generate Agreement
      Get.snackbar("Success", "Agreement Generated!");
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
      pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void toggleDamageFee(String key, bool enabled) {
    damageFees[key]!['enabled'] = enabled;
    damageFees.refresh();
  }

  void updateDamagePrice(String key, String price) {
    damageFees[key]!['price'] = double.tryParse(price) ?? 0.0;
  }
}
