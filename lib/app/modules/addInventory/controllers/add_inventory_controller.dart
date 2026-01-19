import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/common/a_app_snacks.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../services/firestore_service.dart';
import '../../../services/user_service.dart';

class AddInventoryController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final FirestoreService _firestoreService = FirestoreService();
  final UserService _userService = UserService();

  late final InventoryFormMode mode;
  String? itemId;
  late String shopId;

  /// Text Controllers
  final brandController = TextEditingController();
  final colorController = TextEditingController();
  final costController = TextEditingController();
  final volumeController = TextEditingController();
  final rentalRateController = TextEditingController();
  final rentalRateDayController = TextEditingController();
  final notesController = TextEditingController();
  final sizeFeetController = TextEditingController();
  final sizeInchesController = TextEditingController();

  final SingleSelectController<SurfBoardType?> surfboardTypeController =
      SingleSelectController(null);

  final RxString boardName =
      'Enter the details of the surfboard you want to add to your inventory.'
          .obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;

    mode = args?['mode'] ?? InventoryFormMode.add;
    itemId = args?['itemId'];
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    shopId = await _userService.getShopIdFromStorage() ?? '0000';

    _attachListeners();

    if (mode == InventoryFormMode.edit && itemId != null) {
      await _loadItemForEdit();
    }
  }

  // ---------------------------------------------------------------------------
  // LOAD ITEM FOR EDIT
  // ---------------------------------------------------------------------------
  Future<void> _loadItemForEdit() async {
    final doc = await _firestoreService.getInventoryItemOnce(
      shopId: shopId,
      itemId: itemId!,
    );

    if (!doc.exists) return;

    final data = doc.data() as Map<String, dynamic>;

    sizeFeetController.text = data['size_feet'].toString();
    sizeInchesController.text = data['size_inches'].toString();
    brandController.text = data['brand'];
    volumeController.text = data['volume'].toString();
    colorController.text = data['color'];
    costController.text = data['purchase_cost'].toString();
    rentalRateController.text = data['rental_rate_hour'].toString();
    rentalRateDayController.text = data['rental_rate_day'].toString();
    notesController.text = data['note'];

    final type = SurfBoardType.values.firstWhereOrNull(
      (e) => e.name == data['type'],
    );
    surfboardTypeController.value = type;

    updateBoardName();
  }

  // ---------------------------------------------------------------------------
  // SAVE OR UPDATE
  // ---------------------------------------------------------------------------
  Future<void> saveItem() async {
    if (!formKey.currentState!.validate()) return;

    final feet = int.tryParse(sizeFeetController.text) ?? 0;
    final inches = int.tryParse(sizeInchesController.text) ?? 0;
    final totalInches = (feet * 12) + inches;

    final data = {
      'name': boardName.value,
      'type': surfboardTypeController.value?.name,
      'brand': brandController.text,
      'size_feet': feet,
      'size_inches': inches,
      'size_total_inches': totalInches,
      'volume': int.tryParse(volumeController.text) ?? 0,
      'color': colorController.text,
      'purchase_cost': int.tryParse(costController.text) ?? 0,
      'damage_fee_rule': 'rule',
      'rental_rate_hour': int.tryParse(rentalRateController.text) ?? 0,
      'rental_rate_day': int.tryParse(rentalRateDayController.text) ?? 0,
      'note': notesController.text,
      'status': 'available',
      'updated_at': FieldValue.serverTimestamp(),
    };

    print('Data to be saved/updated: $data' + 'item id: $itemId');

    if (mode == InventoryFormMode.edit && itemId != null) {
      await _firestoreService.updateInventoryItem(
        shopId: shopId,
        itemId: itemId!,
        data: data,
      );
      appSnackBarSuccessAndFailure('Item updated successfully.');
    } else {
      await _firestoreService.saveInventoryItem(shopId, data);
      appSnackBarSuccessAndFailure('Item added successfully.');
      clearForm();
    }
  }

  // ---------------------------------------------------------------------------
  void _attachListeners() {
    sizeFeetController.addListener(updateBoardName);
    sizeInchesController.addListener(updateBoardName);
    brandController.addListener(updateBoardName);
    volumeController.addListener(updateBoardName);
  }

  void updateBoardName() {
    boardName.value =
        "${sizeFeetController.text}' ${sizeInchesController.text}\" "
        "${brandController.text} ${volumeController.text}L "
        "${surfboardTypeController.value?.name ?? ''}";
  }

  // ---------------------------------------------------------------------------
  void clearForm() {
    brandController.clear();
    colorController.clear();
    costController.clear();
    sizeFeetController.clear();
    sizeInchesController.clear();
    volumeController.clear();
    rentalRateController.clear();
    rentalRateDayController.clear();
    notesController.clear();
    surfboardTypeController.clear();

    boardName.value =
        'Enter the details of the surfboard you want to add to your inventory.';
  }

  @override
  void onClose() {
    brandController.dispose();
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
