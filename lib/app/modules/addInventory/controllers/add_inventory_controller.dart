import 'dart:developer';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/common/a_app_error_handler.dart';
import '../../../../utils/common/a_app_snacks.dart';
import '../../../services/firestore_service.dart';
import '../../../services/shop_service.dart';
import '../../../services/user_service.dart';

class AddInventoryController extends GetxController {
  // -- Form Keys & Controllers --
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final FirestoreService _firestoreService = FirestoreService();
  final UserService _userService = UserService();

  final brandController = TextEditingController();
  final typeController = TextEditingController();
  final colorController = TextEditingController();
  final costController = TextEditingController();
  final volumeController = TextEditingController();
  final rentalRateController = TextEditingController();
  final rentalRateDayController = TextEditingController();
  final notesController = TextEditingController();

  final SingleSelectController<String> surfboardTypeController =
      SingleSelectController(null);

  // Size Controllers
  final sizeFeetController = TextEditingController();
  final sizeInchesController = TextEditingController();

  // Selected Dropdown Value
  final RxString boardName =
      'Enter the details of the surfboard you want to add to your inventory.'
          .obs;

  // Dummy Brands List
  final List<String> brandList = [
    "Channel Islands",
    "Firewire",
    "Pyzel",
    "Lost",
    "JS Industries",
    "Other",
  ];

  List<String> list = ['Developer', 'Designer', 'Consultant', 'Student'];

  late String shopId;

  @override
  void onInit() async {
    super.onInit();
    shopId = await _userService.getShopIdFromStorage() ?? '0000';

    // Add listeners to update board name dynamically
    sizeFeetController.addListener(updateBoardName);
    sizeInchesController.addListener(updateBoardName);
    brandController.addListener(updateBoardName);
    volumeController.addListener(updateBoardName);
    typeController.addListener(updateBoardName);
  }

  void saveItem() {
    if (!formKey.currentState!.validate()) return;

    try {
      Map<String, dynamic> data = {
        'name': boardName.value,
        'type': typeController.text,
        'brand': brandController.text,
        'size_feet': sizeFeetController.text,
        'size_inches': sizeInchesController.text,
        'volume': volumeController.text,
        'color': colorController.text,
        'purchase_cost': costController.text,
        'damage_fee_rule': 'rule',
        'rental_rate_hour': rentalRateController.text,
        'rental_rate_day': rentalRateDayController.text,
        'note': notesController.text,
        'status': 'available',
        'created_at': FieldValue.serverTimestamp(),
      };

      log("Saving Inventory Item: $data");

      _firestoreService.saveInventoryItem(shopId, data);

      appSnackBarSuccessAndFailure('Inventory item added successfully.');

      // Clear form after successful submission
      clearForm();
    } on FirebaseException catch (e) {
      AppErrorHandler.handleError(e);
    } catch (e) {
      AppErrorHandler.handleError(e);
    }
  }

  void updateBoardName() {
    /// Format -: Size Brand Volume ex: 5' 9" Kelly Slater 34L Shortboard
    boardName.value =
        "${sizeFeetController.text}' ${sizeInchesController.text}\" ${brandController.text} ${volumeController.text} L ${typeController.text}";
  }

  void clearForm() {
    brandController.clear();
    typeController.clear();
    colorController.clear();
    costController.clear();
    sizeFeetController.clear();
    sizeInchesController.clear();
    volumeController.clear();
    rentalRateController.clear();
    rentalRateDayController.clear();
    notesController.clear();
    boardName.value =
        'Enter the details of the surfboard you want to add to your inventory.';

    // Reset Surfboard Type
    typeController.text = '';
    // surfboardTypeController.value = null;
    surfboardTypeController.clear();
  }

  @override
  void onClose() {
    // Remove listeners to prevent memory leaks
    sizeFeetController.removeListener(updateBoardName);
    sizeInchesController.removeListener(updateBoardName);
    brandController.removeListener(updateBoardName);
    volumeController.removeListener(updateBoardName);
    typeController.removeListener(updateBoardName);

    brandController.dispose();
    typeController.dispose();
    colorController.dispose();
    costController.dispose();
    sizeFeetController.dispose();
    sizeInchesController.dispose();
    volumeController.dispose();
    rentalRateController.dispose();
    rentalRateDayController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
