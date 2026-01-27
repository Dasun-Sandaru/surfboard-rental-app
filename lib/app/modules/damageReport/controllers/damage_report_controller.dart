import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:surfboard_rental_app/utils/common/app_snack_bar.dart';
import '../../../models/damage_fee_model.dart';
import '../../../models/damage_report_model.dart';
import '../../../models/damage_photo_model.dart';
import '../../../../utils/constants/a_enums.dart';

import '../../../services/damage_fee_service.dart';
import '../../../services/damage_report_service.dart';
import '../../../services/user_service.dart';
import '../../../services/rental_service.dart';
import '../../../models/payment_model.dart';

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
      AppSnackBar.error(
        title: 'Error',
        message: 'Failed to load damage fees: $e',
      );
    }
  }

  void toggleDamage(String feeId, bool value) {
    selectedDamageFees[feeId] = value;
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
      AppSnackBar.warning(
        title: "Limit Reached",
        message: "Maximum 3 photos per damage type.",
      );
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (image != null) {
        if (!damagePhotos.containsKey(feeId)) {
          damagePhotos[feeId] = [];
        }
        damagePhotos[feeId]!.add(File(image.path));
        damagePhotos.refresh();
      }
    } catch (e) {
      AppSnackBar.error(title: 'Error', message: 'Failed to pick image: $e');
    }
  }

  void removePhoto(String feeId, int index) {
    if (damagePhotos.containsKey(feeId)) {
      damagePhotos[feeId]!.removeAt(index);
      damagePhotos.refresh();
    }
  }

  Future<void> saveReport() async {
    final selectedFees = availableDamageFees
        .where((fee) => selectedDamageFees[fee.id] == true)
        .toList();

    if (selectedFees.isEmpty) {
      AppSnackBar.error(
        title: "Missing Info",
        message: "Please select at least one damage type",
      );
      return;
    }

    try {
      isSaving.value = true;
      final shopId = await _userService.getShopIdFromStorage();
      if (shopId == null || rentalId == null || itemId == null) {
        throw 'Missing shop, rental or item information';
      }

      for (var fee in selectedFees) {
        final note = damageNotes[fee.id]?.text;

        final report = DamageReportModel(
          rentalId: rentalId!,
          itemId: itemId!,
          damageType: fee.damageType,
          note: note,
          status: DamageStatus.reported,
          estimatedCost: fee.feeAmount,
          reportedBy: _userService.currentUser?.uid ?? 'Unknown',
          reportedAt: DateTime.now(),
        );

        final reportId = await _damageReportService.createDamageReport(
          shopId: shopId,
          rentalId: rentalId!,
          report: report,
        );

        // 4. Create Payment Record (Charge)
        final userId = _userService.currentUser?.uid ?? 'Unknown';
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

        // Upload photos if any
        final photos = damagePhotos[fee.id] ?? [];
        for (var photoFile in photos) {
          final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
          final path =
              'shops/$shopId/rentals/$rentalId/damages/$reportId/$fileName';

          final photoUrl = await _damageReportService.uploadPhotoSupabase(
            file: photoFile,
            path: path,
          );

          await _damageReportService.addDamagePhoto(
            shopId: shopId,
            rentalId: rentalId!,
            damageId: reportId,
            photo: DamagePhotoModel(
              damageId: reportId,
              photoUrl: photoUrl,
              uploadedBy: _userService.currentUser?.uid ?? 'Unknown',
              uploadedAt: DateTime.now(),
            ),
          );
        }
      }

      await _damageReportService.updateRentalStatus(
        shopId: shopId,
        rentalId: rentalId!,
        status: RentalStatus.mark_as_damaged,
      );

      Get.back(result: {'success': true, 'totalFee': totalFee});
      AppSnackBar.success(
        title: "Success",
        message: "Damage reports saved successfully",
      );
    } catch (e) {
      AppSnackBar.error(title: "Error", message: "Failed to save reports: $e");
    } finally {
      isSaving.value = false;
    }
  }
}
