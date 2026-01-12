import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../services/firestore_service.dart';
import '../../../services/user_service.dart';

class ManageUsersController extends GetxController {
  final FirestoreService _firestoreService = Get.find();

  // This should come from AuthController
  String? shopId;

  final searchTextController = TextEditingController();

  // Users list for UI
  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;

  StreamSubscription? _usersSub;

  final UserService _userService = Get.find();

  @override
  void onInit() {
    super.onInit();
    // _setShopId();
  }

  // Future<void> _setShopId() async {
  //   shopId = await _userService.getShopId();
  //   log('shopId: $shopId');
  //   _listenUsers();
  // }

  // ---------------------------------------------------------------------------
  // REAL-TIME USERS LISTENER
  // ---------------------------------------------------------------------------
  void _listenUsers() {
    if (shopId == null) {
      log("shopId is null, cannot listen to users");
      return;
    }
    _usersSub = _firestoreService.getShopUsers(shopId!).listen((snapshot) {
      final List<Map<String, dynamic>> fetchedUsers = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        final String name = data['name'] ?? '';
        final String email = data['email'] ?? '';
        final String role = (data['role'] ?? 'staff')
            .toString()
            .capitalizeFirst!;
        final bool isActive = data['is_active'] ?? true;

        return {
          "id": doc.id,
          "name": name,
          "email": email,
          "role": role,
          "status": isActive ? "Active" : "Inactive",
          "initials": _getInitials(name),
          "color": _avatarColor(name),
        };
      }).toList();

      // Sort the list to have admins first
      fetchedUsers.sort((a, b) {
        if (a['role'] == 'Admin' && b['role'] != 'Admin') {
          return -1;
        } else if (a['role'] != 'Admin' && b['role'] == 'Admin') {
          return 1;
        }
        return 0;
      });

      users.assignAll(fetchedUsers);
    });
  }

  // ---------------------------------------------------------------------------
  // UI ACTIONS
  // ---------------------------------------------------------------------------
  void addUser() {
    Get.snackbar("Action", "Add User clicked");
  }

  void openUserDetails(Map<String, dynamic> user) {
    Get.snackbar("User", "Opened ${user['name']}");
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------
  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    final parts = name.trim().split(" ");
    if (parts.length == 1) return parts.first[0];
    return parts[0][0] + parts[1][0];
  }

  Color _avatarColor(String input) {
    final colors = [
      const Color(0xFF4A90E2),
      const Color(0xFF6366F1),
      const Color(0xFFF97316),
      const Color(0xFF10B981),
      const Color(0xFFEC4899),
    ];
    return colors[input.hashCode % colors.length];
  }

  void viewUserDetails(Map<String, dynamic> user) {
    Get.toNamed(Routes.USER_DETAIL, arguments: user);
  }

  @override
  void onClose() {
    _usersSub?.cancel();
    searchTextController.dispose();
    super.onClose();
  }
}
