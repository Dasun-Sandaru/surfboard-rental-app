import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/customer_model.dart';
import '../../../models/damage_fee_model.dart';
import '../../../models/inventory_model.dart';
import '../../../models/new_rental_pass_model.dart';
import '../../../services/damage_fee_service.dart';
import '../../../services/user_service.dart';

class AgreementController extends GetxController {
  // -- Services --
  final DamageFeeService _damageFeeService = DamageFeeService();
  final UserService _userService = Get.find();

  // -- Agreement Data --
  final Rxn<NewRentalPassModel> newRentalPassData = Rxn<NewRentalPassModel>();

  // -- Step Management --
  final RxInt currentStep = 0.obs;
  final PageController pageController = PageController();

  // -- 1. Board Details --
  final RxString selectedBoard = ''.obs;

  // -- 2. Duration & Pricing --
  final rentalPriceController = TextEditingController();
  final RxString rentalDuration = '1 Day'.obs;
  final RxBool requireDeposit = false.obs;
  final depositController = TextEditingController();

  // -- 3. Damage Fees --
  // Using DamageFeeModel list instead of hardcoded map
  final RxList<DamageFeeModel> availableDamageFees = <DamageFeeModel>[].obs;
  final RxMap<String, bool> selectedDamageFees = <String, bool>{}.obs;

  // -- Derived Data from newRentalPassData --

  // Customer data
  CustomerModel? get customer => newRentalPassData.value?.customer;
  // String get customerName =>
  //     "${customer?.firstName ?? ''} ${customer?.lastName ?? ''}";

  // Board data (assumes single item rental for now)
  InventoryModel? get board {
    final items = newRentalPassData.value?.items;
    if (items != null && items.isNotEmpty) {
      return items.first;
    }
    return null;
  }

  // String? get boardName => board?.name;

  // // Rental dates & times
  // String? get startDateTime => newRentalPassData.value?.startDateTimeString;
  // String? get dueDateTime => newRentalPassData.value?.dueDateTimeString;
  // int? get rentalHours => newRentalPassData.value?.rentalDurationHours;
  // double? get rentalDays => newRentalPassData.value?.rentalDurationDays;

  @override
  void onInit() {
    super.onInit();
    // Get the NewRentalPassModel passed from NewRentalController
    if (Get.arguments != null && Get.arguments is NewRentalPassModel) {
      newRentalPassData.value = Get.arguments as NewRentalPassModel;
      // Fetch damage fees for the selected board
      _loadDamageFees();
    }
  }

  /// Fetch damage fees from database for the selected item
  Future<void> _loadDamageFees() async {
    try {
      final itemId = board?.id;
      final shopId = await _userService.getShopIdFromStorage();

      if (itemId == null || shopId == null) {
        return;
      }

      // Bind the stream to the RxList
      availableDamageFees.bindStream(
        _damageFeeService.streamDamageRules(shopId: shopId, itemId: itemId),
      );

      // Add a listener to reset selections when fees change
      ever(availableDamageFees, (fees) {
        selectedDamageFees.clear();
        for (var fee in fees) {
          selectedDamageFees[fee.id!] = false;
        }
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load damage fees: $e');
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    rentalPriceController.dispose();
    depositController.dispose();
    super.onClose();
  }

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

  void toggleDamageFee(String feeId, bool enabled) {
    selectedDamageFees[feeId] = enabled;
    selectedDamageFees.refresh();
  }

  /// Get selected damage fees with their details
  List<DamageFeeModel> getSelectedDamageFees() {
    return availableDamageFees
        .where((fee) => selectedDamageFees[fee.id] == true)
        .toList();
  }

  /// Calculate total damage fees
  double getTotalDamageFees() {
    return getSelectedDamageFees().fold<double>(
      0.0,
      (sum, fee) => sum + fee.feeAmount,
    );
  }
}
