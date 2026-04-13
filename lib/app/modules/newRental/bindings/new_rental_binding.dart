import 'package:get/get.dart';

import '../controllers/new_rental_controller.dart';

class NewRentalBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NewRentalController>(() => NewRentalController());
  }
}
