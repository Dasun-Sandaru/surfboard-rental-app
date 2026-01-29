import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surfboard_rental_app/app/services/auth_service.dart';
import 'package:surfboard_rental_app/app/services/shop_service.dart';
import 'package:surfboard_rental_app/app/services/user_service.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';
import 'package:surfboard_rental_app/utils/constants/a_enums.dart';

import '../../../../utils/common/app_snack_bar.dart';
import '../views/inventory_config_view.dart';
import '../views/edit_profile_view.dart';
import '../views/edit_shop_view.dart';

class SettingsController extends GetxController {
  final UserService _userService = Get.find();
  final ShopService _shopService = Get.find();
  final AuthService _authService = Get.find();

  final Rx<Map<String, dynamic>> userProfile = Rx<Map<String, dynamic>>({});
  final Rx<Map<String, dynamic>> shopProfile = Rx<Map<String, dynamic>>({});

  // -- Text Controllers for Edit Profile --
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  // -- Text Controllers for Edit Shop --
  final shopNameController = TextEditingController();
  final shopLocationController = TextEditingController();

  // -- Text Controller for Dialogs (Inventory) --
  final textInputController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Get current user's data
      final currentUser = _authService.currentUser;
      if (currentUser == null) throw 'User not logged in';

      final userModel = await _userService.getUser(currentUser.uid);
      if (userModel == null) throw 'User data not found in Firestore';

      userProfile.value = {
        "name": userModel.name,
        "role": userModel.role.name,
        "email": userModel.email,
        "phone": userModel.phone,
        "image": '',
      };

      // Get shop data
      final shopId = await _userService.getShopIdFromStorage();
      if (shopId == null) throw 'Shop ID not found in storage';

      final shopDoc = await _shopService.getShop(shopId);
      if (!shopDoc.exists) throw 'Shop data not found in Firestore';
      final shopData = shopDoc.data() as Map<String, dynamic>;
      shopProfile.value = {
        "name":
            shopData[FirestoreFields.businessName] ??
            'No Shop Name', // Using local key 'name' for profile Map
        "location": shopData[FirestoreFields.location] ?? 'No Location',
        "id": shopDoc.id,
      };
    } catch (e) {
      AppSnackBar.error(title: 'Error Loading Data', message: e.toString());
    }
  }

  // -- Inventory Configuration Data --
  final RxList<String> brands = <String>[
    "Channel Islands",
    "Firewire",
    "Pyzel",
    "Lost",
    "JS Industries",
    "Torq",
  ].obs;

  final RxList<SurfBoardType> boardTypes = RxList<SurfBoardType>.from(
    SurfBoardType.values,
  );

  // -- Actions --

  void editPersonalInfo() {
    // Initialize controllers with current data
    nameController.text = userProfile.value['name'] ?? '';
    phoneController.text = userProfile.value['phone'] ?? '';
    emailController.text = userProfile.value['email'] ?? '';

    // Navigate to Edit Profile View
    Get.to(() => EditProfileView());
  }

  Future<void> saveProfile() async {
    final newName = nameController.text.trim();
    final newPhone = phoneController.text.trim();

    if (newName.isEmpty) {
      AppSnackBar.error(title: "Error", message: "Name cannot be empty");
      return;
    }

    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        await _userService.updateUserProfile(
          userId: currentUser.uid,
          name: newName,
          phone: newPhone.isNotEmpty ? newPhone : null,
        );

        Get.back(); // Close Edit Profile View
        _loadData(); // Refresh data
        AppSnackBar.success(
          title: "Success",
          message: "Profile updated successfully",
        );
      }
    } catch (e) {
      AppSnackBar.error(title: "Update Failed", message: e.toString());
    }
  }

  void editShopDetails() {
    // Initialize controllers with current shop data
    shopNameController.text = shopProfile.value['name'] ?? '';
    shopLocationController.text = shopProfile.value['location'] ?? '';

    // Navigate to Edit Shop View
    Get.to(() => EditShopView());
  }

  Future<void> saveShopDetails() async {
    final newName = shopNameController.text.trim();
    final newLocation = shopLocationController.text.trim();

    if (newName.isEmpty) {
      AppSnackBar.error(title: "Error", message: "Shop Name cannot be empty");
      return;
    }

    try {
      final shopId = shopProfile.value['id'];
      if (shopId != null) {
        await _shopService.updateShop(
          shopId: shopId,
          name: newName,
          location: newLocation,
        );

        Get.back();
        _loadData();
        AppSnackBar.success(
          title: "Success",
          message: "Shop details updated successfully",
        );
      }
    } catch (e) {
      AppSnackBar.error(title: "Update Failed", message: e.toString());
    }
  }

  void logout() {
    Get.defaultDialog(
      title: "Logout",
      middleText: "Are you sure you want to logout?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () {
        // Auth Logic
        Get.back();
        Get.offAllNamed('/login');
      },
    );
  }

  // Generic function to add item to a list
  void addItem(String title, RxList<dynamic> list) {
    textInputController.clear();
    Get.defaultDialog(
      title: "Add $title",
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: textInputController,
          decoration: InputDecoration(
            hintText: "Enter $title name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      textConfirm: "Add",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (textInputController.text.isNotEmpty) {
          list.add(textInputController.text.trim());
          Get.back();
          AppSnackBar.success(
            title: 'Success',
            message: '$title added successfully',
          );
        }
      },
    );
  }

  // Generic function to remove item
  void removeItem(dynamic item, RxList<dynamic> list) {
    Get.defaultDialog(
      title: "Remove Item",
      middleText: "Delete '$item' from the list?",
      textConfirm: "Delete",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        list.remove(item);
        Get.back();
      },
    );
  }

  void navigateToInventorySettings() {
    Get.to(() => const InventoryConfigView());
  }
}
