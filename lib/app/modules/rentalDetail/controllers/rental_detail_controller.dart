import 'package:get/get.dart';
import '../../../models/rental_model.dart';
import '../widgets/rental_qr_code_dialog.dart';

class RentalDetailController extends GetxController {
  final RentalModel rental = Get.arguments;

  void showQR() {
    Get.dialog(RentalQrCodeDialog(rental: rental), barrierDismissible: true);
  }
}
