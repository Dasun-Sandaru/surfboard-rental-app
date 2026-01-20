import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:surfboard_rental_app/app/services/pdf_service.dart';

import '../../../models/customer_model.dart';
import '../../../models/damage_fee_model.dart';
import '../../../models/inventory_model.dart';
import '../../../models/new_rental_pass_model.dart';
import '../../../models/shop_model.dart';
import '../../../services/damage_fee_service.dart';
import '../../../services/user_service.dart';

class AgreementController extends GetxController {
  // -- Services --
  final DamageFeeService _damageFeeService = DamageFeeService();
  final UserService _userService = Get.find();
  final PdfService _pdfService = PdfService();

  // -- Agreement Data --
  final Rxn<NewRentalPassModel> newRentalPassData = Rxn<NewRentalPassModel>();

  // -- Step Management --
  final RxInt currentStep = 0.obs;
  final PageController pageController = PageController();

  // -- 2. Duration & Pricing --
  final rentalPriceController = TextEditingController();
  final RxString rentalDuration = '1 Day'.obs;
  final RxBool requireDeposit = false.obs;
  final depositController = TextEditingController();

  // -- 3. Damage Fees --
  final RxList<DamageFeeModel> availableDamageFees = <DamageFeeModel>[].obs;
  final RxMap<String, bool> selectedDamageFees = <String, bool>{}.obs;

  // -- 4. Signature --
  final Rxn<Uint8List> customerSignature = Rxn<Uint8List>();

  // -- Derived Data from newRentalPassData --
  CustomerModel? get customer => newRentalPassData.value?.customer;
  InventoryModel? get board {
    final items = newRentalPassData.value?.items;
    if (items != null && items.isNotEmpty) {
      return items.first;
    }
    return null;
  }

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is NewRentalPassModel) {
      newRentalPassData.value = Get.arguments as NewRentalPassModel;
      _loadDamageFees();
    }
  }

  Future<void> _loadDamageFees() async {
    try {
      final itemId = board?.id;
      final shopId = await _userService.getShopIdFromStorage();

      if (itemId == null || shopId == null) {
        return;
      }

      availableDamageFees.bindStream(
        _damageFeeService.streamDamageRules(shopId: shopId, itemId: itemId),
      );

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
      currentStep.value++;
      pageController.animateToPage(
        currentStep.value,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _generateAgreement();
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

  void _generateAgreement() async {
    final rentalData = newRentalPassData.value;
    if (rentalData == null) {
      Get.snackbar("Error", "Cannot generate agreement: missing rental data.");
      return;
    }

    // TODO: Get Shop data from a service instead of placeholder
    final shopData = ShopModel();

    final rentalPrice = double.tryParse(rentalPriceController.text) ?? 0.0;
    final deposit = requireDeposit.value
        ? (double.tryParse(depositController.text) ?? 0.0)
        : 0.0;
    final selectedFees = getSelectedDamageFees();

    final pdfData = await _pdfService.generateAgreementPdf(
      rentalData: rentalData,
      shopData: shopData,
      rentalFee: rentalPrice,
      deposit: deposit,
      selectedDamageFees: selectedFees,
      customerSignature: customerSignature.value,
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfData);
  }

  void toggleDamageFee(String feeId, bool enabled) {
    selectedDamageFees[feeId] = enabled;
    selectedDamageFees.refresh();
  }

  List<DamageFeeModel> getSelectedDamageFees() {
    return availableDamageFees
        .where((fee) => selectedDamageFees[fee.id] == true)
        .toList();
  }

  double getTotalDamageFees() {
    return getSelectedDamageFees().fold<double>(
      0.0,
      (sum, fee) => sum + fee.feeAmount,
    );
  }
}
