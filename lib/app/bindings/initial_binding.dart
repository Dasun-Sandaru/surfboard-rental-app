import 'package:get/get.dart';

import '../services/auth_service.dart';
import '../services/customer_service.dart';
import '../services/firestore_service.dart';
import '../services/shop_service.dart';
import '../services/user_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthService(), permanent: true);
    Get.put(FirestoreService(), permanent: true);
    Get.put(UserService(), permanent: true);
    Get.put(ShopService(), permanent: true);
    Get.put(CustomerService(), permanent: true);
  }
}
