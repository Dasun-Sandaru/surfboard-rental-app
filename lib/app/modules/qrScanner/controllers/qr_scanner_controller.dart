import 'dart:developer';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../utils/common/app_snack_bar.dart';

import '../../../models/customer_model.dart';
import '../../../models/rental_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/customer_service.dart';
import '../../../services/inventory_service.dart';
import '../../../services/rental_service.dart';
import '../../../services/user_service.dart';

class QrScannerController extends GetxController {
  static const String _logName = 'QrScannerController';

  late MobileScannerController scannerController;

  final RxBool isScanning = true.obs;
  final RxBool flashOn = false.obs;
  final RxString scannedValue = ''.obs;
  final RxBool hasScanned = false.obs;
  final RxBool isProcessing = false.obs;

  bool get isReturnMode {
    if (Get.arguments != null && Get.arguments is Map) {
      return Get.arguments['returnResult'] == true;
    }
    return false;
  }

  // Services
  final CustomerService _customerService = Get.find();
  final InventoryService _inventoryService = InventoryService();
  final RentalService _rentalService = Get.find();
  final UserService _userService = Get.find();

  @override
  void onInit() {
    super.onInit();
    scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }

  void onDetect(BarcodeCapture barcodeCapture) async {
    if (hasScanned.value || isProcessing.value) return;

    final List<Barcode> barcodes = barcodeCapture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        scannedValue.value = barcode.rawValue!;
        hasScanned.value = true;
        isScanning.value = false;
        isProcessing.value = true;

        if (isReturnMode) {
          isProcessing.value = false;
          return;
        }

        // Identify and navigate
        await _identifyAndNavigate(barcode.rawValue!);
      }
    }
  }

  /// Identify the ID type and navigate to appropriate page
  Future<void> _identifyAndNavigate(String scannedData) async {
    try {
      log('Identifying scanned data: $scannedData', name: _logName);

      // Parse the scanned data to extract type and ID
      final parts = scannedData.split(':');

      if (parts.length != 2) {
        // No prefix found - treat as legacy/raw ID and try to identify
        await _legacyIdentify(scannedData);
        return;
      }

      final type = parts[0].toUpperCase();
      final id = parts[1];

      log('Parsed - Type: $type, ID: $id', name: _logName);

      // Route based on type prefix
      switch (type) {
        case 'CUST':
        case 'C':
          _navigateToCustomer(id);
          break;

        case 'ITEM':
        case 'I':
          _navigateToItem(id);
          break;

        case 'RENT':
        case 'R':
          _navigateToRental(id);
          break;

        case 'USER':
        case 'U':
          _navigateToUser(id);
          break;

        default:
          AppSnackBar.warning(
            title: 'unknown_type'.tr,
            message: '${'qr_type_unrecognized'.tr} "$type"',
          );
          resetScanner();
          isProcessing.value = false;
      }
    } catch (e) {
      log('Error identifying QR data: $e', name: _logName);
      AppSnackBar.error(
        title: 'error'.tr,
        message: 'failed_process_qr'.tr,
      );
      resetScanner();
      isProcessing.value = false;
    }
  }

  /// Navigate to customer details
  void _navigateToCustomer(String customerId) async {
    try {
      final shopId = await _userService.getShopIdFromStorage();
      if (shopId == null) {
        AppSnackBar.error(
          title: 'error'.tr,
          message: 'shop_id_not_found'.tr,
        );
        return;
      }

      final customerDoc = await _customerService.getCustomerOnce(
        shopId,
        customerId,
      );
      if (customerDoc.exists) {
        final customer = CustomerModel.fromSnapshot(
          customerDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        AppSnackBar.success(
          title: 'customer_found'.tr,
          message: '${customer.firstName} ${customer.lastName}',
        );
        resetScanner();
        Get.toNamed(Routes.CUSTOMER_DETAILS, arguments: customer);
      } else {
        AppSnackBar.warning(
          title: 'not_found'.tr,
          message: 'customer_not_found'.tr,
        );
        resetScanner();
        isProcessing.value = false;
      }
    } catch (e) {
      log('Error loading customer: $e', name: _logName);
      AppSnackBar.error(
        title: 'error'.tr,
        message: 'failed_load_customer'.tr,
      );
      resetScanner();
      isProcessing.value = false;
    }
  }

  /// Navigate to item details
  void _navigateToItem(String itemId) {
    AppSnackBar.success(
      title: 'item_found'.tr,
      message: 'opening_item_details'.tr,
    );
    resetScanner();
    Get.toNamed(Routes.ITEM_DETAILS, arguments: itemId);
  }

  /// Navigate to rental details
  void _navigateToRental(String rentalId) async {
    try {
      final shopId = await _userService.getShopIdFromStorage();
      if (shopId == null) {
        AppSnackBar.error(
          title: 'error'.tr,
          message: 'shop_id_not_found'.tr,
        );
        return;
      }

      final rentalDoc = await _rentalService.getRentalOnce(shopId, rentalId);
      if (rentalDoc.exists) {
        final rental = RentalModel.fromSnapshot(
          rentalDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        AppSnackBar.success(
          title: 'rental_found'.tr,
          message: 'opening_rental_details'.tr,
        );
        resetScanner();
        Get.toNamed(Routes.RENTAL_DETAIL, arguments: rental);
      } else {
        AppSnackBar.warning(
          title: 'not_found'.tr,
          message: 'rental_not_found'.tr,
        );
        resetScanner();
        isProcessing.value = false;
      }
    } catch (e) {
      log('Error loading rental: $e', name: _logName);
      AppSnackBar.error(
        title: 'error'.tr,
        message: 'failed_load_rental'.tr,
      );
      resetScanner();
      isProcessing.value = false;
    }
  }

  /// Navigate to user details
  void _navigateToUser(String userId) async {
    try {
      final user = await _userService.getUser(userId);
      if (user != null) {
        AppSnackBar.success(
          title: 'user_found'.tr,
          message: user.name ?? 'user'.tr,
        );
        resetScanner();
        Get.toNamed(Routes.USER_DETAIL, arguments: user);
      } else {
        AppSnackBar.warning(
          title: 'not_found'.tr,
          message: 'user_not_found'.tr,
        );
        resetScanner();
        isProcessing.value = false;
      }
    } catch (e) {
      log('Error loading user: $e', name: _logName);
      AppSnackBar.error(
        title: 'error'.tr,
        message: 'failed_load_user'.tr,
      );
      resetScanner();
      isProcessing.value = false;
    }
  }

  /// Legacy identification for QR codes without prefixes (backward compatibility)
  Future<void> _legacyIdentify(String scannedId) async {
    try {
      log('Using legacy identification for: $scannedId', name: _logName);

      // Get shop ID
      final shopId = await _userService.getShopIdFromStorage();
      if (shopId == null) {
        AppSnackBar.error(
          title: 'error'.tr,
          message: 'shop_id_not_found'.tr,
        );
        isProcessing.value = false;
        return;
      }

      // Check each type in order
      // 1. Check Customer
      final customerDoc = await _customerService.getCustomerOnce(
        shopId,
        scannedId,
      );
      if (customerDoc.exists) {
        final customer = CustomerModel.fromSnapshot(
          customerDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        AppSnackBar.success(
          title: 'customer_found'.tr,
          message: '${customer.firstName} ${customer.lastName}',
        );
        resetScanner();
        Get.toNamed(Routes.CUSTOMER_DETAILS, arguments: customer);
        return;
      }

      // 2. Check Inventory
      final itemDoc = await _inventoryService.getInventoryItemOnce(
        shopId: shopId,
        itemId: scannedId,
      );
      if (itemDoc.exists) {
        AppSnackBar.success(
          title: 'item_found'.tr,
          message: 'opening_item'.tr,
        );
        resetScanner();
        Get.toNamed(Routes.ITEM_DETAILS, arguments: scannedId);
        return;
      }

      // 3. Check Rental
      final rentalDoc = await _rentalService.getRentalOnce(shopId, scannedId);
      if (rentalDoc.exists) {
        final rental = RentalModel.fromSnapshot(
          rentalDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        AppSnackBar.success(
          title: 'rental_found'.tr,
          message: 'opening_rental'.tr,
        );
        resetScanner();
        Get.toNamed(Routes.RENTAL_DETAIL, arguments: rental);
        return;
      }

      // 4. Check User
      final user = await _userService.getUser(scannedId);
      if (user != null) {
        AppSnackBar.success(
          title: 'user_found'.tr,
          message: user.name ?? 'user'.tr,
        );
        resetScanner();
        Get.toNamed(Routes.USER_DETAIL, arguments: user);
        return;
      }

      // Nothing found
      AppSnackBar.warning(
        title: 'not_found'.tr,
        message: 'no_record_found_qr'.tr,
      );
      resetScanner();
      isProcessing.value = false;
    } catch (e) {
      log('Error in legacy identification: $e', name: _logName);
      AppSnackBar.error(
        title: 'error'.tr,
        message: 'failed_process_qr'.tr,
      );
      resetScanner();
      isProcessing.value = false;
    }
  }

  void toggleFlash() {
    flashOn.value = !flashOn.value;
    scannerController.toggleTorch();
  }

  void resetScanner() {
    hasScanned.value = false;
    scannedValue.value = '';
    isScanning.value = true;
  }

  void stopScanner() {
    isScanning.value = false;
  }
}
