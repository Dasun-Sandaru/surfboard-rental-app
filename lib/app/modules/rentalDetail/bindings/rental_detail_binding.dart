import 'package:get/get.dart';
import '../controllers/rental_detail_controller.dart';

class RentalDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RentalDetailController>(
      () => RentalDetailController(),
    );
  }
}
