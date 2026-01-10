import 'package:get/get.dart';


import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';

class StaffHomeController extends GetxController {
  final currentUser = Rxn<UserModel>();
  final AuthService _authService = Get.find();

  @override
  void onInit() {
    super.onInit();
  }

 

  /// Sign out the current user and navigate to login
  Future<void> signOut() async {
    await _authService.signOut();
    Get.snackbar('Success', 'Logged out');
  }
}
