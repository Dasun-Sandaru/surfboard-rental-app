import 'dart:developer';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/app/models/inventory_model.dart';
import 'package:surfboard_rental_app/utils/common/app_snack_bar.dart';

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

        if (Get.arguments != null &&
            Get.arguments is Map &&
            Get.arguments['returnResult'] == true) {
          Get.back(result: barcode.rawValue!);
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
            title: 'Unknown Type',
            message: 'QR code type "$type" not recognized',
          );
          resetScanner();
          isProcessing.value = false;
      }
    } catch (e) {
      log('Error identifying QR data: $e', name: _logName);
      AppSnackBar.error(title: 'Error', message: 'Failed to process QR code');
      resetScanner();
      isProcessing.value = false;
    }
  }

  /// Navigate to customer details
  void _navigateToCustomer(String customerId) async {
    try {
      final shopId = await _userService.getShopIdFromStorage();
      if (shopId == null) {
        AppSnackBar.error(title: 'Error', message: 'Shop ID not found');
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
          title: 'Customer Found',
          message: '${customer.firstName} ${customer.lastName}',
        );
        Get.back(); // Close scanner
        Get.toNamed(Routes.CUSTOMER_DETAILS, arguments: customer);
      } else {
        AppSnackBar.warning(title: 'Not Found', message: 'Customer not found');
        resetScanner();
        isProcessing.value = false;
      }
    } catch (e) {
      log('Error loading customer: $e', name: _logName);
      AppSnackBar.error(title: 'Error', message: 'Failed to load customer');
      resetScanner();
      isProcessing.value = false;
    }
  }

  /// Navigate to item details
  void _navigateToItem(String itemId) {
    AppSnackBar.success(
      title: 'Item Found',
      message: 'Opening item details...',
    );
    Get.back(); // Close scanner
    Get.toNamed(Routes.ITEM_DETAILS, arguments: itemId);
  }

  /// Navigate to rental details
  void _navigateToRental(String rentalId) async {
    try {
      final shopId = await _userService.getShopIdFromStorage();
      if (shopId == null) {
        AppSnackBar.error(title: 'Error', message: 'Shop ID not found');
        return;
      }

      final rentalDoc = await _rentalService.getRentalOnce(shopId, rentalId);
      if (rentalDoc.exists) {
        final rental = RentalModel.fromSnapshot(
          rentalDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        AppSnackBar.success(
          title: 'Rental Found',
          message: 'Opening rental details...',
        );
        Get.back(); // Close scanner
        Get.toNamed(Routes.RENTAL_DETAIL, arguments: rental);
      } else {
        AppSnackBar.warning(title: 'Not Found', message: 'Rental not found');
        resetScanner();
        isProcessing.value = false;
      }
    } catch (e) {
      log('Error loading rental: $e', name: _logName);
      AppSnackBar.error(title: 'Error', message: 'Failed to load rental');
      resetScanner();
      isProcessing.value = false;
    }
  }

  /// Navigate to user details
  void _navigateToUser(String userId) async {
    try {
      final user = await _userService.getUser(userId);
      if (user != null) {
        AppSnackBar.success(title: 'User Found', message: user.name ?? 'User');
        Get.back(); // Close scanner
        Get.toNamed(Routes.USER_DETAIL, arguments: user);
      } else {
        AppSnackBar.warning(title: 'Not Found', message: 'User not found');
        resetScanner();
        isProcessing.value = false;
      }
    } catch (e) {
      log('Error loading user: $e', name: _logName);
      AppSnackBar.error(title: 'Error', message: 'Failed to load user');
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
        AppSnackBar.error(title: 'Error', message: 'Shop ID not found');
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
          title: 'Customer Found',
          message: '${customer.firstName} ${customer.lastName}',
        );
        Get.back();
        Get.toNamed(Routes.CUSTOMER_DETAILS, arguments: customer);
        return;
      }

      // 2. Check Inventory
      final itemDoc = await _inventoryService.getInventoryItemOnce(
        shopId: shopId,
        itemId: scannedId,
      );
      if (itemDoc.exists) {
        AppSnackBar.success(title: 'Item Found', message: 'Opening item...');
        Get.back();
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
          title: 'Rental Found',
          message: 'Opening rental...',
        );
        Get.back();
        Get.toNamed(Routes.RENTAL_DETAIL, arguments: rental);
        return;
      }

      // 4. Check User
      final user = await _userService.getUser(scannedId);
      if (user != null) {
        AppSnackBar.success(title: 'User Found', message: user.name ?? 'User');
        Get.back();
        Get.toNamed(Routes.USER_DETAIL, arguments: user);
        return;
      }

      // Nothing found
      AppSnackBar.warning(
        title: 'Not Found',
        message: 'No record found for this QR code',
      );
      resetScanner();
      isProcessing.value = false;
    } catch (e) {
      log('Error in legacy identification: $e', name: _logName);
      AppSnackBar.error(title: 'Error', message: 'Failed to process QR code');
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
