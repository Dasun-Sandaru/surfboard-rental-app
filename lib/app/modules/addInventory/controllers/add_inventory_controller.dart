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

// Sample data to add to the inventory
final List<Map<String, dynamic>> sampleInventoryData = [
  {
    'name': 'The Ripper',
    'type': 'Shortboard',
    'brand': 'Pyzel',
    'size_feet': '5',
    'size_inches': '10',
    'size_total_inches': '70',
    'volume': '28.5',
    'color': 'White',
    'purchase_cost': '750',
    'damage_fee_rule': 'rule',
    'rental_rate_hour': '15',
    'rental_rate_day': '60',
    'note': 'High-performance board for advanced surfers.',
    'status': 'available',
    'created_at': FieldValue.serverTimestamp(),
  },
  {
    'name': 'The Cruiser',
    'type': 'Longboard',
    'brand': 'CJ Nelson',
    'size_feet': '9',
    'size_inches': '2',
    'size_total_inches': '110',
    'volume': '72',
    'color': 'Blue',
    'purchase_cost': '1100',
    'damage_fee_rule': 'rule',
    'rental_rate_hour': '20',
    'rental_rate_day': '80',
    'note': 'Perfect for small waves and beginners.',
    'status': 'rented',
    'created_at': FieldValue.serverTimestamp(),
  },
  {
    'name': 'The Glider',
    'type': 'Fish',
    'brand': 'Firewire',
    'size_feet': '6',
    'size_inches': '4',
    'size_total_inches': '76',
    'volume': '38',
    'color': 'Yellow',
    'purchase_cost': '800',
    'damage_fee_rule': 'rule',
    'rental_rate_hour': '18',
    'rental_rate_day': '70',
    'note': 'Fast and loose, great for a variety of conditions.',
    'status': 'repair',
    'created_at': FieldValue.serverTimestamp(),
  },
];

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

  List<String> surfboardTypelist = ['Shortboard', 'Longboard', 'Funboard'];

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
    // if (!formKey.currentState!.validate()) return;

    try {
      // Map<String, dynamic> data = {
      //   'name': boardName.value,
      //   'type': typeController.text,
      //   'brand': brandController.text,
      //   'size_feet': sizeFeetController.text,
      //   'size_inches': sizeInchesController.text,
      //   'volume': volumeController.text,
      //   'color': colorController.text,
      //   'purchase_cost': costController.text,
      //   'damage_fee_rule': 'rule',
      //   'rental_rate_hour': rentalRateController.text,
      //   'rental_rate_day': rentalRateDayController.text,
      //   'note': notesController.text,
      //   'status': 'available',
      //   'created_at': FieldValue.serverTimestamp(),
      // };

      // log("Saving Inventory Item: $data");

      // _firestoreService.saveInventoryItem(shopId, data);

      for (var element in sampleInventoryData) {
        _firestoreService.saveInventoryItem(shopId, element);
        
      }

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

  /// Method to add sample boards to Firestore using a batch write.
  Future<void> addSampleBoards() async {
    try {
      final WriteBatch batch = FirebaseFirestore.instance.batch();
      final collectionRef = FirebaseFirestore.instance
          .collection('shops')
          .doc(shopId)
          .collection('inventory');

      for (var boardData in sampleInventoryData) {
        final docRef = collectionRef.doc();
        // Add 'id' field to the data, similar to saveInventoryItem
        var dataWithId = {...boardData, 'id': docRef.id};
        batch.set(docRef, dataWithId);
      }

      await batch.commit();

      log('Sample boards added successfully!');
      appSnackBarSuccessAndFailure('Sample boards added successfully.');
    } on FirebaseException catch (e) {
      log('Error adding sample boards: $e');
      AppErrorHandler.handleError(e);
    } catch (e) {
      log('Error adding sample boards: $e');
      AppErrorHandler.handleError(e);
    }
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
