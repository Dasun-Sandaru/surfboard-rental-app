import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../../../models/rental_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/pdf_service.dart';

import '../../../services/rental_service.dart';
import '../../../services/shop_service.dart';
import '../../../../data/firestore/firestore_fields.dart';
import '../../../../utils/common/app_snack_bar.dart';

import '../../../../utils/constants/a_enums.dart';
import '../../../models/customer_model.dart';
import '../../../models/damage_fee_model.dart';
import '../../../models/inventory_model.dart';
import '../../../models/init_rental_model.dart';
import '../../../models/security_deposit_model.dart';
import '../../../models/shop_model.dart';
import '../../../services/damage_fee_service.dart';
import '../../../services/payment_service.dart';
import '../../../services/user_service.dart';

class AgreementController extends GetxController {
  // -- Services --
  final DamageFeeService _damageFeeService = DamageFeeService();
  final UserService _userService = Get.find();
  final PdfService _pdfService = PdfService();
  final ShopService _shopService = ShopService();
  final RentalService _rentalService = RentalService();
  final PaymentService _paymentService = PaymentService();

  // -- Agreement Data --
  final Rxn<InitRentalModel> initRentalModel = Rxn<InitRentalModel>();

  // -- Shop Config --
  final RxInt hourlyGracePeriod = 15.obs;
  final RxInt dailyGracePeriod = 0.obs;

  // -- Step Management --
  final RxInt currentStep = 0.obs;
  final PageController pageController = PageController();

  // -- Post-Generation State --
  final RxBool isAgreementGenerated = false.obs;
  final RxBool isCreatingRental = false.obs;
  final RxBool isGeneratingAgreement = false.obs;
  final Rxn<Uint8List> generatedPdfData = Rxn<Uint8List>();

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

  // -- Derived Data from initRentalModel --
  CustomerModel? get customer => initRentalModel.value?.customer;
  InventoryModel? get board {
    final items = initRentalModel.value?.items;
    if (items != null && items.isNotEmpty) {
      return items.first;
    }
    return null;
  }

  double get suggestedPrice {
    final rentalData = initRentalModel.value;
    if (rentalData == null || rentalData.items.isEmpty) {
      return 0.0;
    }

    final item = rentalData.items.first;
    final double hourlyRate = item.rentalRateHour.toDouble();
    final double dailyRate = item.rentalRateDay.toDouble();

    final startDateTime = DateTime(
      rentalData.startDate.year,
      rentalData.startDate.month,
      rentalData.startDate.day,
      rentalData.startTime.hour,
      rentalData.startTime.minute,
    );

    final dueDateTime = DateTime(
      rentalData.dueDate.year,
      rentalData.dueDate.month,
      rentalData.dueDate.day,
      rentalData.dueTime.hour,
      rentalData.dueTime.minute,
    );

    if (!dueDateTime.isAfter(startDateTime)) {
      return 0.0;
    }

    final difference = dueDateTime.difference(startDateTime);

    /// -----------------------
    /// HOURLY RENT
    /// -----------------------
    if (rentalData.rentType == RentType.hourly) {
      int hours = difference.inHours;

      // Minimum 1 hour
      if (hours == 0) {
        hours = 1;
      }

      final int remainingMinutes = difference.inMinutes % 60;

      // Add extra hour only if grace period exceeded
      if (remainingMinutes > hourlyGracePeriod.value) {
        hours += 1;
      }

      return hours * hourlyRate;
    }
    /// -----------------------
    /// DAILY RENT
    /// -----------------------
    else {
      int days = difference.inDays;

      // Minimum 1 day
      if (days == 0) {
        days = 1;
      }

      // Calculate remaining time after full days
      final remainingDuration = difference - Duration(days: days);

      // Any extra time exceeding daily grace period counts as another day
      if (remainingDuration.inMinutes > dailyGracePeriod.value) {
        days += 1;
      }

      return days * dailyRate;
    }
  }

  String get formattedDuration {
    final rentalData = initRentalModel.value;
    if (rentalData == null) {
      return "0h";
    }

    final startDateTime = DateTime(
      rentalData.startDate.year,
      rentalData.startDate.month,
      rentalData.startDate.day,
      rentalData.startTime.hour,
      rentalData.startTime.minute,
    );

    final dueDateTime = DateTime(
      rentalData.dueDate.year,
      rentalData.dueDate.month,
      rentalData.dueDate.day,
      rentalData.dueTime.hour,
      rentalData.dueTime.minute,
    );

    if (dueDateTime.isBefore(startDateTime) || dueDateTime == startDateTime) {
      return "0h";
    }

    final difference = dueDateTime.difference(startDateTime);
    int totalHours = difference.inHours;
    if (difference.inMinutes % 60 > 0) {
      totalHours++;
    }

    final days = totalHours ~/ 24;
    final remainingHours = totalHours % 24;

    if (days > 0) {
      String duration = "$days d";
      if (remainingHours > 0) {
        duration += " ${remainingHours}h";
      }
      return duration;
    } else {
      return "$totalHours h";
    }
  }

  RxBool isAgree = false.obs;
  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is InitRentalModel) {
      initRentalModel.value = Get.arguments as InitRentalModel;
      _loadShopConfig();
    }
    // Listeners to invalidate generated agreement on data change
    rentalPriceController.addListener(_onInputChanged);
    depositController.addListener(_onInputChanged);
    ever(requireDeposit, (_) => _onInputChanged());
    ever(selectedDamageFees, (_) => _onInputChanged());
    ever(customerSignature, (_) => _onInputChanged());
  }

  Future<void> _loadShopConfig() async {
    try {
      final itemId = board?.id;
      final shopId = await _userService.getShopIdFromStorage();

      if (itemId == null || shopId == null) {
        return;
      }

      // Load Damage Fees
      availableDamageFees.bindStream(
        _damageFeeService.streamDamageRules(shopId: shopId, itemId: itemId),
      );

      ever(availableDamageFees, (fees) {
        selectedDamageFees.clear();
        for (var fee in fees) {
          selectedDamageFees[fee.id!] = false;
        }
      });

      // Load Shop Grace Periods
      final shopDoc = await _shopService.getShop(shopId);
      if (shopDoc.exists) {
        final data = shopDoc.data() as Map<String, dynamic>;
        hourlyGracePeriod.value =
            data[FirestoreFields.hourlyGracePeriodMinutes] ?? 15;
        dailyGracePeriod.value =
            data[FirestoreFields.dailyGracePeriodHours] ?? 1;
      }
    } catch (e) {
      AppSnackBar.error(
        title: 'Error',
        message: 'Failed to load shop configuration: $e',
      );
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    rentalPriceController.dispose();
    depositController.dispose();
    super.onClose();
  }

  void _onInputChanged() {
    if (isAgreementGenerated.value) {
      isAgreementGenerated.value = false;
      generatedPdfData.value = null; // Also clear the old PDF
      AppSnackBar.info(
        title: 'Agreement Outdated',
        message: 'Your changes require the agreement to be re-generated.',
      );
    }
  }

  void nextStep() {
    // Validate before incrementing to avoid having to revert the step.
    if (currentStep.value == 1) {
      if (rentalPriceController.text.isEmpty) {
        AppSnackBar.warning(
          title: "Validation Error",
          message: "Rental price is required.",
        );
        return;
      }

      if (requireDeposit.value && depositController.text.isEmpty) {
        AppSnackBar.warning(
          title: "Validation Error",
          message: "Deposit amount is required.",
        );
        return;
      }
    }

    // if (currentStep.value == 2) {
    //   if (selectedDamageFees.isEmpty) {
    //     AppSnackBar.warning(
    //       title: "Validation Error",
    //       message: "Please select at least one damage fee option.",
    //     );
    //     return;
    //   }
    // }
    if (currentStep.value < 3) {
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

  void regenerateAgreement() {
    _generateAgreement();
  }

  void previousStep() {
    if (isAgreementGenerated.value) {
      isAgreementGenerated.value = false;
      generatedPdfData.value = null;
    }
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
    final rentalData = initRentalModel.value;
    if (rentalData == null) {
      AppSnackBar.error(
        title: "Error",
        message: "Cannot generate agreement: missing rental data.",
      );
      return;
    }

    if (isAgree.value == false) {
      AppSnackBar.warning(
        title: "Agreement Required",
        message: "You must agree to the terms before generating the agreement.",
      );
      return;
    }

    // Start loading
    isGeneratingAgreement.value = true;

    try {
      final shopId = await _userService.getShopIdFromStorage();
      if (shopId == null) {
        AppSnackBar.error(
          title: "Error",
          message: "Cannot generate agreement: missing shop ID.",
        );
        return;
      }

      final shopDoc = await _shopService.getShop(shopId);
      final shopData = ShopModel.fromSnapshot(
        shopDoc as DocumentSnapshot<Map<String, dynamic>>,
      );

      final rentalPrice = double.tryParse(rentalPriceController.text) ?? 0.0;
      final deposit = requireDeposit.value
          ? (double.tryParse(depositController.text) ?? 0.0)
          : 0.0;
      final selectedFees = getSelectedDamageFees();

      final pdfData = await _pdfService.generateAgreementPdf(
        rentalData: rentalData,
        shopData: shopData,
        shopId: shopId,
        rentalFee: rentalPrice,
        deposit: deposit,
        selectedDamageFees: selectedFees,
        customerSignature: customerSignature.value,
      );

      generatedPdfData.value = pdfData;
      isAgreementGenerated.value = true;
    } catch (e) {
      AppSnackBar.error(
        title: "Error",
        message: "Failed to generate agreement: $e",
      );
    } finally {
      isGeneratingAgreement.value = false;
    }
  }

  Future<void> showGeneratedPdf() async {
    if (generatedPdfData.value != null) {
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => generatedPdfData.value!,
      );
    } else {
      AppSnackBar.error(title: 'Error', message: 'PDF not generated yet.');
    }
  }

  Future<void> createRental() async {
    if (generatedPdfData.value == null) {
      AppSnackBar.error(
        title: "Error",
        message: "Please generate the agreement first.",
      );
      return;
    }

    isCreatingRental.value = true;

    try {
      final shopId = await _userService.getShopIdFromStorage();
      final userId = _userService.currentUser!.uid;

      final rentalData = initRentalModel.value;
      final customerId = customer?.id;

      if (shopId == null ||
          customerId == null ||
          board == null ||
          rentalData == null) {
        AppSnackBar.error(
          title: "Error",
          message: "Missing required data to create rental.",
        );
        return;
      }

      // Fetch Staff Name for caching
      final staffUser = await _userService.getUser(userId);
      final staffName = staffUser?.name ?? 'Staff';

      final startDateTime = DateTime(
        rentalData.startDate.year,
        rentalData.startDate.month,
        rentalData.startDate.day,
        rentalData.startTime.hour,
        rentalData.startTime.minute,
      );

      final dueDateTime = DateTime(
        rentalData.dueDate.year,
        rentalData.dueDate.month,
        rentalData.dueDate.day,
        rentalData.dueDate.hour,
        rentalData.dueDate.minute,
      );

      final deposit = requireDeposit.value
          ? (double.tryParse(depositController.text) ?? 0.0)
          : 0.0;

      final newRental = RentalModel(
        shopId: shopId,
        customerId: customerId,
        itemId: board!.id,
        staffId: userId,
        startTime: startDateTime,
        expectedReturnTime: dueDateTime,
        actualReturnTime: null,
        status: RentalStatus.active,
        rentType: initRentalModel.value!.rentType,
        paymentStatus: PaymentStatus.unpaid,
        rate: double.tryParse(rentalPriceController.text) ?? 0.0,
        amountExpected: double.tryParse(rentalPriceController.text) ?? 0.0,
        amountPaid: 0.0,
        securityDeposit: SecurityDepositModel(
          enabled: requireDeposit.value,
          amount: deposit,
          paid: requireDeposit.value ? deposit : 0.0,
          refunded: 0.0,
        ),
        agreementLink: null,
        overdueTime: null,
        cachedCustomerName: "${customer!.firstName} ${customer!.lastName}",
        cachedItemName: board!.name,
        cachedStaffName: staffName,
        createdAt: DateTime.now(),
      );

      final rentalId = await _rentalService.createRental(
        shopId,
        newRental,
        generatedPdfData.value!,
      );

      // Create Payment Record for Security Deposit if paid
      if (requireDeposit.value && deposit > 0) {
        await _paymentService.addPayment(
          shopId: shopId,
          rentalId: rentalId,
          category: PaymentCategory.deposit,
          amount: deposit,
          handledBy: staffName,
          method: PaymentMethod.cash, // Defaulting to cash for now
          note: "Initial Security Deposit",
        );
      }

      AppSnackBar.success(
        title: "Success",
        message: "Rental created successfully with ID: $rentalId",
      );
      Get.offAllNamed(Routes.ADMIN_HOME);
    } catch (e) {
      AppSnackBar.error(title: "Error", message: "Failed to create rental: $e");
    } finally {
      isCreatingRental.value = false;
    }
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
      (total, fee) => total + fee.feeAmount,
    );
  }
}