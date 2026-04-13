import 'package:get/get.dart';

import '../controllers/rental_payment_controller.dart';

class RentalPaymentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RentalPaymentController>(() => RentalPaymentController());
  }
}
