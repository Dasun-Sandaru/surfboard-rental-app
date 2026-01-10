import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../routes/app_pages.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find();
  final UserService _userService = Get.find();

  late Rx<User?> firebaseUser;

  @override
  void onInit() {
    super.onInit();

    // 🔥 Firebase Auth Stream → Rx
    firebaseUser = Rx<User?>(_authService.currentUser);
    firebaseUser.bindStream(_authService.authStateChanges);

    // 🔁 Listen to auth changes
    ever(firebaseUser, _handleAuthChanged);
  }

  /// CENTRAL AUTH ROUTING
  Future<void> _handleAuthChanged(User? user) async {
    if (user == null) {
      Get.offAllNamed(Routes.SIGN_IN);
      return;
    }

    // Reload & verify email
    await user.reload();
    final isVerified = user.emailVerified;

    if (!isVerified) {
      Get.offAllNamed(Routes.VERIFY_EMAIL);
      return;
    }

    // Fetch role
    final role = await _userService.getUserRole();

    Future.delayed(const Duration(seconds: 10), () {
      if (role == 'admin') {
        Get.offAllNamed(Routes.ADMIN_HOME);
      } else if (role == 'staff') {
        Get.offAllNamed(Routes.STAFF_HOME);
      } else {
        Get.offAllNamed(Routes.SIGN_IN);
      }
    });
  }
}
