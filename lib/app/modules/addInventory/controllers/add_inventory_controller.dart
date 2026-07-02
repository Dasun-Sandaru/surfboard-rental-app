import 'dart:developer';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/firestore/firestore_fields.dart';

import '../../../../utils/common/app_snack_bar.dart';
import '../../../../utils/constants/a_enums.dart';
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
      'enter_board_details_desc'.tr
          .obs;
  final RxBool isLoading = false.obs;
  
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxString existingImageUrl = ''.obs;

  // ---------------------------------------------------------------------------
  // IMAGE PICKER
  // ---------------------------------------------------------------------------
  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      log('Error picking image: $e', name: _logName);
      AppSnackBar.error(
        title: 'error'.tr,
        message: 'Failed to pick image: $e',
      );
    }
  }

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
        title: 'initialization_error'.tr,
        message: '${'failed_init_form'.tr}: $e',
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
        title: 'initialization_error'.tr,
        message: '${'failed_load_form_data'.tr}: $e',
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

      sizeFeetController.text = data[FirestoreFields.sizeFeet].toString();
      sizeInchesController.text = data[FirestoreFields.sizeInches].toString();
      brandController.text = data[FirestoreFields.brand];
      volumeController.text = data[FirestoreFields.volume].toString();
      colorController.text = data[FirestoreFields.color];
      costController.text = data[FirestoreFields.purchaseCost].toString();
      rentalRateController.text = data[FirestoreFields.rentalRateHour]
          .toString();
      rentalRateDayController.text = data[FirestoreFields.rentalRateDay]
          .toString();
      notesController.text = data[FirestoreFields.note];
      existingImageUrl.value = data[FirestoreFields.imageUrl] ?? '';

      final type = SurfBoardType.values.firstWhereOrNull(
        (e) => e.name == data[FirestoreFields.type],
      );
      surfboardTypeController.value = type;

      updateBoardName();

      log('Item loaded successfully: $itemId', name: _logName);
      AppSnackBar.info(
        title: 'item_loaded'.tr,
        message: 'item_details_loaded_success'.tr,
      );
    } catch (e) {
      log('Error loading item for edit: $e', name: _logName);
      AppSnackBar.error(
        title: 'load_error'.tr,
        message: '${'failed_load_item'.tr}: $e',
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
          title: 'validation_error'.tr,
          message: 'check_required_fields'.tr,
        );
        return;
      }

      if (shopId == null) {
        AppSnackBar.warning(
          title: 'error'.tr,
          message: 'shop_id_not_found_restart'.tr,
        );
        return;
      }

      isLoading.value = true;
      log('Saving item...', name: _logName);

      final feet = int.tryParse(sizeFeetController.text) ?? 0;
      final inches = int.tryParse(sizeInchesController.text) ?? 0;
      final totalInches = (feet * 12) + inches;

      final data = {
        FirestoreFields.name: boardName.value,
        FirestoreFields.type: surfboardTypeController.value?.name,
        FirestoreFields.brand: brandController.text,
        FirestoreFields.sizeFeet: feet,
        FirestoreFields.sizeInches: inches,
        FirestoreFields.sizeTotalInches: totalInches,
        FirestoreFields.volume: int.tryParse(volumeController.text) ?? 0,
        FirestoreFields.color: colorController.text,
        FirestoreFields.purchaseCost: int.tryParse(costController.text) ?? 0,
        // Consider if this should be constant or field
        FirestoreFields.damageFeeRule: 'rule',
        FirestoreFields.rentalRateHour:
            int.tryParse(rentalRateController.text) ?? 0,
        FirestoreFields.rentalRateDay:
            int.tryParse(rentalRateDayController.text) ?? 0,
        FirestoreFields.note: notesController.text,
        FirestoreFields.status: InventoryStatus.available.name,
      };

      if (mode == InventoryFormMode.edit && itemId != null) {
        if (selectedImage.value != null) {
          final url = await _inventoryService.uploadInventoryImageSupabase(
            file: selectedImage.value!,
            shopId: shopId!,
            itemId: itemId!,
          );
          data[FirestoreFields.imageUrl] = url;
        }

        await _inventoryService.updateInventoryItem(
          shopId: shopId!,
          itemId: itemId!,
          data: data,
        );
        log('Item updated successfully: $itemId', name: _logName);
        Get.back(result: true);
        AppSnackBar.success(
          title: 'success'.tr,
          message: 'item_updated_success'.tr,
        );
      } else {
        final newItemId = await _inventoryService.createInventoryItem(
          shopId: shopId!,
          data: data,
        );
        log('Item created successfully: $newItemId', name: _logName);

        if (selectedImage.value != null) {
          final url = await _inventoryService.uploadInventoryImageSupabase(
            file: selectedImage.value!,
            shopId: shopId!,
            itemId: newItemId,
          );
          await _inventoryService.updateInventoryItem(
            shopId: shopId!,
            itemId: newItemId,
            data: {FirestoreFields.imageUrl: url},
          );
        }

        AppSnackBar.success(
          title: 'success'.tr,
          message: 'item_added_success'.tr,
        );
        clearForm();
      }
    } catch (e) {
      log('Error saving item: $e', name: _logName);
      AppSnackBar.error(
        title: 'save_error'.tr,
        message: '${'failed_save_item'.tr}: $e',
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
        "${surfboardTypeController.value?.name.tr ?? ''}";
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
    selectedImage.value = null;
    existingImageUrl.value = '';

    boardName.value =
        'enter_board_details_desc'.tr;
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
