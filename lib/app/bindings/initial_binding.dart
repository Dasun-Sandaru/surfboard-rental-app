import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../services/user_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthService(), permanent: true);
    Get.put(FirestoreService(), permanent: true);
    Get.put(UserService(), permanent: true);

  }
}
