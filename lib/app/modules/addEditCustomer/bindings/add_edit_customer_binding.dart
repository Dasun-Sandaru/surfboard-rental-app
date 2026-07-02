import 'package:get/get.dart';

import '../controllers/add_edit_customer_controller.dart';

class AddEditCustomerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AddEditCustomerController>(() => AddEditCustomerController());
  }
}
