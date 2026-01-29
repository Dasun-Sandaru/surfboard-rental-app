import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:surfboard_rental_app/utils/common/app_snack_bar.dart';

class QrScannerController extends GetxController {
  late MobileScannerController scannerController;

  final RxBool isScanning = true.obs;
  final RxBool flashOn = false.obs;
  final RxString scannedValue = ''.obs;
  final RxBool hasScanned = false.obs;

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

  void onDetect(BarcodeCapture barcodeCapture) {
    if (hasScanned.value) return;

    final List<Barcode> barcodes = barcodeCapture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      if (barcode.rawValue != null) {
        scannedValue.value = barcode.rawValue!;
        hasScanned.value = true;
        isScanning.value = false;

        AppSnackBar.success(
          title: 'QR Code Scanned',
          message: 'Successfully scanned: ${barcode.rawValue}',
        );
      }
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
