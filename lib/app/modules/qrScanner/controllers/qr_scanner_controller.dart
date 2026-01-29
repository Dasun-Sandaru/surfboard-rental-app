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

        // Identify and navigate
        await _identifyAndNavigate(barcode.rawValue!);
      }
    }
  }

  /// Identify the ID type and navigate to appropriate page
  Future<void> _identifyAndNavigate(String scannedId) async {
    try {
      log('Identifying scanned ID: $scannedId', name: _logName);

      // Get shop ID
      final shopId = await _userService.getShopIdFromStorage();
      if (shopId == null) {
        AppSnackBar.error(title: 'Error', message: 'Shop ID not found');
        isProcessing.value = false;
        return;
      }

      // Check each type in order of likelihood
      // 1. Check if it's a Customer ID
      final customerDoc = await _customerService.getCustomerOnce(
        shopId,
        scannedId,
      );
      if (customerDoc.exists) {
        final customer = CustomerModel.fromSnapshot(
          customerDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        log('Found customer: ${customer.firstName}', name: _logName);
        AppSnackBar.success(
          title: 'Customer Found',
          message: 'Opening ${customer.firstName} ${customer.lastName}',
        );
        Get.back(); // Close scanner
        Get.toNamed(Routes.CUSTOMER_DETAILS, arguments: customer);
        return;
      }

      // 2. Check if it's an Inventory Item ID
      final itemDoc = await _inventoryService.getInventoryItemOnce(
        shopId: shopId,
        itemId: scannedId,
      );
      if (itemDoc.exists) {
        final item = InventoryModel.fromSnapshot(
          itemDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        log('Found inventory item: ${item.name}', name: _logName);
        AppSnackBar.success(
          title: 'Item Found',
          message: 'Opening ${item.name}',
        );
        Get.back(); // Close scanner
        Get.toNamed(Routes.ITEM_DETAILS, arguments: scannedId);
        return;
      }

      // 3. Check if it's a Rental ID
      final rentalDoc = await _rentalService.getRentalOnce(shopId, scannedId);
      if (rentalDoc.exists) {
        final rental = RentalModel.fromSnapshot(
          rentalDoc as DocumentSnapshot<Map<String, dynamic>>,
        );
        log('Found rental: ${rental.id}', name: _logName);
        AppSnackBar.success(
          title: 'Rental Found',
          message: 'Opening rental details',
        );
        Get.back(); // Close scanner
        Get.toNamed(Routes.RENTAL_DETAIL, arguments: rental);
        return;
      }

      // 4. Check if it's a User ID
      final user = await _userService.getUser(scannedId);
      if (user != null) {
        log('Found user: ${user.name}', name: _logName);
        AppSnackBar.success(
          title: 'User Found',
          message: 'Opening ${user.name}',
        );
        Get.back(); // Close scanner
        Get.toNamed(Routes.USER_DETAIL, arguments: user);
        return;
      }

      // If nothing found
      AppSnackBar.warning(
        title: 'Not Found',
        message: 'No record found for ID: $scannedId',
      );

      // Reset scanner to scan again
      resetScanner();
      isProcessing.value = false;
    } catch (e) {
      log('Error identifying ID: $e', name: _logName);
      AppSnackBar.error(
        title: 'Error',
        message: 'Failed to process QR code: $e',
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
