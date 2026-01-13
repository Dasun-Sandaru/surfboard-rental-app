import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';
import '../../../services/firestore_service.dart';
import '../../../services/user_service.dart';

class ManageUsersController extends GetxController {
  final FirestoreService _firestoreService = Get.find();
  final UserService _userService = Get.find();

  // This comes from AuthController (current user's shop)
  String? shopId;

  final searchTextController = TextEditingController();

  // Users list for UI
  final RxList<Map<String, dynamic>> users = <Map<String, dynamic>>[].obs;

  StreamSubscription? _usersSub;

  @override
  void onInit() {
    super.onInit();
    _initShopMembers();
  }

  /// Initialize shop members listener
  Future<void> _initShopMembers() async {
    shopId = await _userService.getShopIdFromStorage();
    if (shopId == null) {
      log("Shop ID not found for current user.");
      return;
    }

    _listenUsers();
  }

  /// ---------------------------------------------------------------------------
  /// REAL-TIME SHOP MEMBERS LISTENER
  /// ---------------------------------------------------------------------------
  void _listenUsers() {
    if (shopId == null) return;

    _usersSub = _firestoreService.getShopUsers(shopId!).listen((snapshot) {
      final List<Map<String, dynamic>> fetchedUsers = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final String name = data['name'] ?? '';
        final String email = data['email'] ?? '';
        final String role = (data['role'] ?? 'staff')
            .toString()
            .capitalizeFirst!;
        final String phone = data['phone'] ?? '';


        final bool isActive = data['is_active'] ?? true;
        final bool isVerified = data['verified'] ?? false;
        final String createdAt = data['created_at']?.toDate().toString() ?? '';
        return {
          "id": doc.id,
          "name": name,
          "email": email,
          "role": role,
          "phone": phone,
          "is_active": isActive,
          "verified": isVerified,

          "created_at": createdAt,
          "initials": _getInitials(name),
          "color": _avatarColor(name),
        };
      }).toList();

      // Sort admins first
      fetchedUsers.sort((a, b) {
        if (a['role'] == 'Admin' && b['role'] != 'Admin') return -1;
        if (a['role'] != 'Admin' && b['role'] == 'Admin') return 1;
        return 0;
      });

      users.assignAll(fetchedUsers);
    });
  }

  /// ---------------------------------------------------------------------------
  /// UI ACTIONS
  /// ---------------------------------------------------------------------------
  void addUser() {
    Get.snackbar("Action", "Add User clicked");
  }

  void viewUserDetails(Map<String, dynamic> user) {
    log("Viewing details for user: ${user}");
    Get.toNamed(Routes.USER_DETAIL, arguments: user);
  }

  /// ---------------------------------------------------------------------------
  /// HELPERS
  /// ---------------------------------------------------------------------------
  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    final parts = name.trim().split(" ");
    if (parts.length == 1) return parts.first[0];
    return parts[0][0] + parts[1][0];
  }

  Color _avatarColor(String input) {
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
