import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../utils/constants/a_enums.dart';
import '../../utils/storage/app_storage.dart';
import '../routes/app_pages.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find();
  final UserService _userService = Get.find();
  final AppLocalStorage _storage = AppLocalStorage();

  late Rx<User?> firebaseUser;
  StreamSubscription? _userSub;

  @override
  void onInit() {
    super.onInit();

    // Firebase Auth Stream
    firebaseUser = Rx<User?>(_authService.currentUser);
    firebaseUser.bindStream(_authService.authStateChanges);

    // Listen to Auth Changes
    ever(firebaseUser, _handleAuthChanged);
  }

  final Rx<UserRole?> currentUserRole = Rx<UserRole?>(null);

  /// CENTRAL AUTH ROUTING
  Future<void> _handleAuthChanged(User? user) async {
    _userSub?.cancel();

    if (user == null) {
      Get.offAllNamed(Routes.SIGN_IN);
      return;
    }

    // Reload & Verify Email
    try {
      await user.reload();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _authService.signOut();
        return;
      }
      rethrow;
    }

    final isVerified = user.emailVerified;

    if (!isVerified) {
      Get.offAllNamed(Routes.VERIFY_EMAIL);
      return;
    }

    try {
      final userModel = await _userService.getUserMembership(user.uid);

      final role = userModel.role;
      currentUserRole.value = role;
      final shopId = userModel.shopId;

      // Save shopId Locally
      await _storage.saveData('shop_id', shopId);

      if (role == UserRole.admin) {
        Get.offAllNamed(Routes.ADMIN_HOME);
      } else if (role == UserRole.staff) {
        Get.offAllNamed(Routes.STAFF_HOME);
      } else {
        Get.offAllNamed(Routes.SIGN_IN);
      }
    } catch (e) {
      Get.offAllNamed(Routes.SIGN_IN);
    }
  }

  @override
  void onClose() {
    _userSub?.cancel();
    super.onClose();
  }
}
