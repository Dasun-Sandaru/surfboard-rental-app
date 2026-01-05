import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../services/firestore_service.dart';
import '../controllers/user_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FirestoreService>(() => FirestoreService());
    Get.lazyPut<AuthService>(() => AuthService());
    Get.lazyPut<UserService>(() => UserService());
    Get.lazyPut<UserController>(() => UserController());
  }
}
