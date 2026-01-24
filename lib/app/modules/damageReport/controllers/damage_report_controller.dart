import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../models/damage_fee_model.dart';
import '../../../models/damage_report_model.dart';
import '../../../models/damage_photo_model.dart';
import '../../../models/payment_model.dart';
import '../../../../utils/constants/a_enums.dart';

import '../../../services/damage_fee_service.dart';
import '../../../services/damage_report_service.dart';
import '../../../services/rental_service.dart';
import '../../../services/user_service.dart';

class DamageReportController extends GetxController {
  final DamageFeeService _damageFeeService = DamageFeeService();
  final DamageReportService _damageReportService = DamageReportService();
  final RentalService _rentalService = RentalService();
  final UserService _userService = Get.find<UserService>();

  // -- State --
  final RxList<DamageFeeModel> availableDamageFees = <DamageFeeModel>[].obs;

  // Track selected damages: "DamageFee ID" -> isSelected
  final RxMap<String, bool> selectedDamageFees = <String, bool>{}.obs;

  // Track photos per damage type: "DamageFee ID" -> List of Files
  final RxMap<String, List<File>> damagePhotos = <String, List<File>>{}.obs;

  // Track notes per damage type: "DamageFee ID" -> TextEditingController
  final Map<String, TextEditingController> damageNotes = {};

  final ImagePicker _picker = ImagePicker();

  String? rentalId;
  String? itemId;

  // Loading state
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map) {
      final args = Get.arguments as Map;
      rentalId = args['rentalId'];
      itemId = args['itemId'];
      _loadDamageFees();
    }
  }

  @override
  void onClose() {
    for (var controller in damageNotes.values) {
      controller.dispose();
    }
    super.onClose();
  }

  Future<void> _loadDamageFees() async {
    try {
      final shopId = await _userService.getShopIdFromStorage();

      if (itemId == null || shopId == null) {
        return;
      }

      availableDamageFees.bindStream(
        _damageFeeService.streamDamageRules(shopId: shopId, itemId: itemId!),
      );

      ever(availableDamageFees, (fees) {
        selectedDamageFees.clear();
        damagePhotos.clear();

        // Clear existing controllers safely
        for (var controller in damageNotes.values) {
          controller.dispose();
        }
        damageNotes.clear();

        for (var fee in fees) {
          if (fee.id != null) {
            selectedDamageFees[fee.id!] = false;
            damagePhotos[fee.id!] = [];
            damageNotes[fee.id!] = TextEditingController();
          }
        }
      });
    } catch (e) {
      Get.snackbar('Error', 'Failed to load damage fees: $e');
    }
  }

  // -- Actions --

  void toggleDamage(String feeId, bool isSelected) {
    selectedDamageFees[feeId] = isSelected;
  }

  double get totalFee {
    double total = 0.0;
    for (var fee in availableDamageFees) {
      if (selectedDamageFees[fee.id] == true) {
        total += fee.feeAmount;
      }
    }
    return total;
  }

  Future<void> pickPhoto(String feeId) async {
    final currentPhotos = damagePhotos[feeId] ?? [];
    if (currentPhotos.length >= 3) {
      Get.snackbar(
        "Limit Reached",
        "Maximum 3 photos per damage type.",
        backgroundColor: Colors.amber.withOpacity(0.1),
        colorText: Colors.amber,
      );
      return;
    }

    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      if (!damagePhotos.containsKey(feeId)) {
        damagePhotos[feeId] = [];
      }
      damagePhotos[feeId]!.add(File(image.path));
      damagePhotos.refresh();
    }
  }

  void removePhoto(String feeId, int index) {
    if (damagePhotos.containsKey(feeId)) {
      damagePhotos[feeId]!.removeAt(index);
      damagePhotos.refresh();
    }
  }

  Future<void> saveReport() async {
    // 1. Filter selected damage types
    final selectedFees = availableDamageFees
        .where((fee) => selectedDamageFees[fee.id] == true)
        .toList();

    if (selectedFees.isEmpty) {
      Get.snackbar(
        "Missing Info",
        "Please select at least one damage type",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      return;
    }

    isSaving.value = true;
    // Show loading overlay
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final shopId = await _userService.getShopIdFromStorage();
      final userId = _userService.currentUser!.uid;

      if (shopId == null || rentalId == null || itemId == null) {
        throw Exception("Missing context data (shopId, rentalId, or itemId)");
      }

      // 2. Iterate and save each damage report
      for (var fee in selectedFees) {
        if (fee.id == null) continue;

        // Create Report Document
        final reportModel = DamageReportModel(
          rentalId: rentalId!,
          itemId: itemId!,
          damageType: fee.damageType, // Now a String in model
          note: damageNotes[fee.id]?.text,
          status: DamageStatus.reported,
          estimatedCost: fee.feeAmount,
          reportedBy: userId,
          reportedAt: DateTime.now(),
        );

        final damageId = await _damageReportService.createDamageReport(
          shopId: shopId,
          rentalId: rentalId!,
          report: reportModel,
        );

        // 3. Upload Photos for this damage (Supabase)
        final photos = damagePhotos[fee.id] ?? [];
        for (var file in photos) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final filename = "photo_${timestamp}.jpg";
          // Path: rentalId/damageId/filename (Supabase bucket root relative)
          final storagePath = "$rentalId/$damageId/$filename";

          final photoUrl = await _damageReportService.uploadPhotoSupabase(
            file: file,
            path: storagePath,
          );

          final photoModel = DamagePhotoModel(
            damageId: damageId,
            photoUrl: photoUrl,
            uploadedBy: userId,
            uploadedAt: DateTime.now(),
          );

          await _damageReportService.addDamagePhoto(
            shopId: shopId,
            rentalId: rentalId!,
            damageId: damageId,
            photo: photoModel,
          );
        }

        // 4. Create Payment Record (Charge)
        final paymentModel = PaymentModel(
          rentalId: rentalId!,
          amount: fee.feeAmount,
          category: PaymentCategory.damageFee,
          method: PaymentMethod.cash, // Defaulting to cash for charge record
          handledBy: userId,
          timestamp: DateTime.now(),
          note: "Damage Fee: ${fee.damageType}",
        );

        await _damageReportService.createPayment(
          shopId: shopId,
          rentalId: rentalId!,
          payment: paymentModel,
        );

        // 5. Update Rental Ledger (Amount Expected)
        await _rentalService.addDamageCharge(
          shopId: shopId,
          rentalId: rentalId!,
          amount: fee.feeAmount,
        );
      }

      // Close loading dialog
      Get.back();

      // Return to Inspection Screen with success result
      Get.back(result: {'success': true, 'totalFee': totalFee});
      Get.snackbar("Success", "Damage reports saved successfully");
    } catch (e) {
      // Close loading dialog
      if (Get.isDialogOpen == true) Get.back();

      Get.snackbar(
        "Error",
        "Failed to save reports: $e",
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
      isSaving.value = false;
    }
  }
}
