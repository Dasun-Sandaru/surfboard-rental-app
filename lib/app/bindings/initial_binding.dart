import 'package:get/get.dart';

import '../services/auth_service.dart';
import '../services/customer_service.dart';
import '../services/inventory_service.dart';
import '../services/payment_service.dart';
import '../services/rental_service.dart';
import '../services/shop_service.dart';
import '../services/user_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthService(), permanent: true);
    Get.put(UserService(), permanent: true);
    Get.put(ShopService(), permanent: true);
    Get.put(CustomerService(), permanent: true);
    Get.put(InventoryService(), permanent: true);
    Get.put(RentalService(), permanent: true);
    Get.put(PaymentService(), permanent: true);
  }
}
