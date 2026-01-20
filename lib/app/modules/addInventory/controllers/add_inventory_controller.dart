import 'dart:developer';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/common/app_snack_bar.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../models/inventory_model.dart';
import '../../../services/inventory_service.dart';
import '../../../services/user_service.dart';

class AddInventoryController extends GetxController {
  static const String _logName = 'AddInventoryController';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final InventoryService _inventoryService = InventoryService();
  final UserService _userService = UserService();

  late final InventoryFormMode mode;
  String? itemId;
  String? shopId;

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
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      final args = Get.arguments as Map<String, dynamic>?;

      mode = args?['mode'] ?? InventoryFormMode.add;
      itemId = args?['itemId'];

      log('Initialized with mode: $mode, itemId: $itemId', name: _logName);
    } catch (e) {
      log('Error in onInit: $e', name: _logName);
      AppSnackBar.error(
        title: 'Initialization Error',
        message: 'Failed to initialize form: $e',
      );
    }
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    try {
      shopId = await _userService.getShopIdFromStorage();
      log('Shop ID loaded: $shopId', name: _logName);

      _attachListeners();

      if (mode == InventoryFormMode.edit && itemId != null) {
        await _loadItemForEdit();
      }
    } catch (e) {
      log('Error in onReady: $e', name: _logName);
      AppSnackBar.error(
        title: 'Initialization Error',
        message: 'Failed to load form data: $e',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // LOAD ITEM FOR EDIT
  // ---------------------------------------------------------------------------
  Future<void> _loadItemForEdit() async {
    try {
      if (shopId == null) {
        throw Exception('Shop ID not found');
      }
      log('Loading item for edit: $itemId', name: _logName);
      isLoading.value = true;

      final doc = await _inventoryService.getInventoryItemOnce(
        shopId: shopId!,
        itemId: itemId!,
      );

      if (!doc.exists) {
        throw Exception('Item not found');
      }

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

      log('Item loaded successfully: $itemId', name: _logName);
      AppSnackBar.info(
        title: 'Item Loaded',
        message: 'Item details loaded successfully',
      );
    } catch (e) {
      log('Error loading item for edit: $e', name: _logName);
      AppSnackBar.error(
        title: 'Load Error',
        message: 'Failed to load item: $e',
      );
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // SAVE OR UPDATE
  // ---------------------------------------------------------------------------
  Future<void> saveItem() async {
    try {
      if (!formKey.currentState!.validate()) {
        AppSnackBar.warning(
          title: 'Validation Error',
          message: 'Please check all required fields',
        );
        return;
      }

      if (shopId == null) {
        AppSnackBar.warning(
          title: 'Error',
          message: 'Shop ID not found. Please restart.',
        );
        return;
      }

      isLoading.value = true;
      log('Saving item...', name: _logName);

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
      };

      if (mode == InventoryFormMode.edit && itemId != null) {
        await _inventoryService.updateInventoryItem(
          shopId: shopId!,
          itemId: itemId!,
          data: data,
        );
        log('Item updated successfully: $itemId', name: _logName);
        AppSnackBar.success(
          title: 'Success',
          message: 'Item updated successfully',
        );
      } else {
        final newItemId = await _inventoryService.createInventoryItem(
          shopId: shopId!,
          data: data,
        );
        log('Item created successfully: $newItemId', name: _logName);
        AppSnackBar.success(
          title: 'Success',
          message: 'Item added successfully',
        );
        clearForm();
      }

      Get.back();
    } catch (e) {
      log('Error saving item: $e', name: _logName);
      AppSnackBar.error(
        title: 'Save Error',
        message: 'Failed to save item: $e',
      );
    } finally {
      isLoading.value = false;
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
