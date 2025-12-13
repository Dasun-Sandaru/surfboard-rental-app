// ignore_for_file: library_prefixes

import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart' as MyUser;
import '../services/auth_service.dart';
import '../services/user_service.dart';

class UserController extends GetxController {
  final AuthService _authService = Get.find();
  final UserService _userService = Get.find();

  final Rxn<User> firebaseUser = Rxn<User>();
  final Rxn<MyUser.UserModel> userModel = Rxn<MyUser.UserModel>();

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_authService.user);
    ever(firebaseUser, _setUserData);
  }

  void _setUserData(User? firebaseUser) {
    if (firebaseUser != null) {
      userModel.bindStream(_userService.streamUser(firebaseUser.uid));
    } else {
      userModel.value = null;
    }
  }

  bool get isAdmin => userModel.value?.role == 'Admin';
  bool get isStaff => userModel.value?.role == 'Staff';
}
