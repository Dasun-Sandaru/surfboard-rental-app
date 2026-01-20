import 'package:get/get.dart';

import '../../../models/user_model.dart';
import '../../../services/auth_service.dart';
import '../../../../utils/common/app_snack_bar.dart';

class StaffHomeController extends GetxController {
  final currentUser = Rxn<UserModel>();
  final AuthService _authService = Get.find();

  @override
  void onInit() {
    super.onInit();
  }

  /// Sign out the current user and navigate to login
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      AppSnackBar.success(title: 'Success', message: 'Logged out successfully');
    } catch (e) {
      AppSnackBar.error(title: 'Error', message: 'Failed to logout: $e');
    }
  }
}
