import 'package:get/get.dart';

import '../controllers/rentals_controller.dart';

class RentalsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RentalsController>(() => RentalsController());
  }
}
