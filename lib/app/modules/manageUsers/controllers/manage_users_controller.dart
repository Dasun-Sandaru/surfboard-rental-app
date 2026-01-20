import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/user_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/shop_service.dart';
import '../../../services/user_service.dart';
import '../../../../utils/common/app_snack_bar.dart';
import '../../../../utils/constants/a_enums.dart';

class ManageUsersController extends GetxController {
  static const String _logName = 'ManageUsersController';
  final ShopService _shopService = Get.find();
  final UserService _userService = Get.find();

  String? shopId;

  final searchTextController = TextEditingController();

  /// Shop Members List (Using UserModel instead of Map)
  final RxList<UserModel> users = <UserModel>[].obs;

  StreamSubscription? _usersSub;

  @override
  void onInit() {
    super.onInit();
    _initShopMembers();
  }

  /// INITIALIZE SHOP MEMBERS
  Future<void> _initShopMembers() async {
    try {
      shopId = await _userService.getShopIdFromStorage();
      if (shopId == null) {
        log("Shop ID not found for current user.", name: _logName);
        AppSnackBar.error(
          title: 'Error',
          message: 'Shop ID not found for current user',
        );
        return;
      }

      _listenUsers();
    } catch (e) {
      log("Error initializing shop members: $e", name: _logName);
      AppSnackBar.error(
        title: 'Error',
        message: 'Failed to load shop members: $e',
      );
    }
  }

  /// REAL-TIME SHOP MEMBERS LISTENER
  void _listenUsers() {
    if (shopId == null) return;

    try {
      _usersSub = _shopService.getShopMembers(shopId!).listen((snapshot) {
        try {
          final List<UserModel> fetchedUsers = snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return UserModel.fromMap(data, doc.id);
          }).toList();

          // Sort Admins First
          fetchedUsers.sort((a, b) {
            if (a.role == UserRole.admin && b.role != UserRole.admin) return -1;
            if (a.role != UserRole.admin && b.role == UserRole.admin) return 1;
            return 0;
          });

          log('Fetched ${fetchedUsers.length} users', name: _logName);
          users.assignAll(fetchedUsers);
        } catch (e) {
          log("Error processing users: $e", name: _logName);
          AppSnackBar.error(
            title: 'Error',
            message: 'Failed to process user data: $e',
          );
        }
      });
    } catch (e) {
      log("Error listening to users: $e", name: _logName);
      AppSnackBar.error(
        title: 'Error',
        message: 'Failed to listen to users: $e',
      );
    }
  }

  /// UI ACTIONS
  void addUser() {
    AppSnackBar.info(title: 'Action', message: 'Add User clicked');
  }

  void viewUserDetails(UserModel user) {
    log("Viewing details for user: ${user.uid}", name: _logName);
    Get.toNamed(Routes.USER_DETAIL, arguments: user);
  }

  /// HELPERS
  String getInitials(String name) {
    if (name.isEmpty) return "?";
    final parts = name.trim().split(" ");
    if (parts.length == 1) return parts.first[0];
    return parts[0][0] + parts[1][0];
  }

  Color avatarColor(String input) {
    const colors = [
      Color(0xFF4A90E2),
      Color(0xFF6366F1),
      Color(0xFFF97316),
      Color(0xFF10B981),
      Color(0xFFEC4899),
    ];
    return colors[input.hashCode % colors.length];
  }

  @override
  void onClose() {
    _usersSub?.cancel();
    searchTextController.dispose();
    super.onClose();
  }
}
