import 'dart:developer';
import 'package:get/get.dart';

import '../../../../utils/common/app_snack_bar.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../models/inventory_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/inventory_service.dart';
import '../../../services/user_service.dart';

class ItemDetailsController extends GetxController {
  static const String _logName = 'ItemDetailsController';

  final InventoryService _inventoryService = InventoryService();
  final UserService _userService = UserService();

  late final String itemId;
  String? shopId;

  /// Use InventoryModel instead of DocumentSnapshot
  final Rx<InventoryModel?> item = Rx<InventoryModel?>(null);
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      itemId = Get.arguments as String;
      log('Initialized with itemId: $itemId', name: _logName);
    } catch (e) {
      log('Error in onInit: $e', name: _logName);
      AppSnackBar.error(
        title: 'Initialization Error',
        message: 'Failed to load item details: $e',
      );
      Get.back();
    }
  }

  @override
  Future<void> onReady() async {
    super.onReady();
    try {
      isLoading.value = true;
      log('Loading item details...', name: _logName);

      shopId = await _userService.getShopIdFromStorage();

      _loadItemDetails();
    } catch (e) {
      log('Error in onReady: $e', name: _logName);
      AppSnackBar.error(
        title: 'Load Error',
        message: 'Failed to load item: $e',
      );
      Get.back();
    } finally {
      isLoading.value = false;
    }
  }

  /// Load item details as InventoryModel
  Future<void> _loadItemDetails() async {
    try {
      if (shopId == null) {
        throw Exception('Shop ID not available');
      }
      final doc = await _inventoryService.getInventoryItemOnce(
        shopId: shopId!,
        itemId: itemId,
      );

      if (!doc.exists) {
        throw Exception('Item not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      item.value = InventoryModel.fromMap(data);
      log('Item details loaded: $itemId', name: _logName);
    } catch (e) {
      log('Error loading item: $e', name: _logName);
      throw Exception('Failed to load item details: $e');
    }
  }

  void editItem() {
    try {
      log('Editing item: $itemId', name: _logName);
      Get.toNamed(
        Routes.ADD_INVENTORY,
        arguments: {'mode': InventoryFormMode.edit, 'itemId': itemId},
      );
    } catch (e) {
      log('Error editing item: $e', name: _logName);
      AppSnackBar.error(
        title: 'Edit Error',
        message: 'Failed to open edit form: $e',
      );
    }
  }

  Future<void> deleteItem() async {
    try {
      if (shopId == null) {
        throw Exception('Shop ID not available');
      }
      log('Deleting item: $itemId', name: _logName);
      isLoading.value = true;

      await _inventoryService.deleteInventoryItem(
        shopId: shopId!,
        itemId: itemId,
      );

      log('Item deleted: $itemId', name: _logName);
      AppSnackBar.success(
        title: 'Success',
        message: 'Item deleted successfully',
      );
      Get.back();
    } catch (e) {
      log('Error deleting item: $e', name: _logName);
      AppSnackBar.error(
        title: 'Delete Error',
        message: 'Failed to delete item: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void shareItem() {
    try {
      log('Sharing item: $itemId', name: _logName);
      AppSnackBar.info(
        title: 'Share',
        message: 'Share Item functionality coming soon',
      );
    } catch (e) {
      log('Error sharing item: $e', name: _logName);
      AppSnackBar.error(
        title: 'Share Error',
        message: 'Failed to share item: $e',
      );
    }
  }

  Future<void> markAsRepair() async {
    try {
      if (shopId == null) {
        throw Exception('Shop ID not available');
      }
      log('Marking item as repair: $itemId', name: _logName);
      isLoading.value = true;

      await _inventoryService.updateInventoryStatus(
        shopId: shopId!,
        itemId: itemId,
        status: 'repair',
      );

      log('Item marked as repair: $itemId', name: _logName);
      AppSnackBar.success(title: 'Success', message: 'Item marked as repair');
    } catch (e) {
      log('Error marking as repair: $e', name: _logName);
      AppSnackBar.error(
        title: 'Repair Error',
        message: 'Failed to mark as repair: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void viewDamageFees() {
    // Get.snackbar("Action", "View Damage Fees Clicked $itemId");
    Get.toNamed(Routes.DAMAGE_FEE, arguments: itemId);
  }
}
