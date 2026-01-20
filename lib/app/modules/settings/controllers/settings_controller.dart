import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surfboard_rental_app/app/services/auth_service.dart';
import 'package:surfboard_rental_app/app/services/shop_service.dart';
import 'package:surfboard_rental_app/app/services/user_service.dart';
import 'package:surfboard_rental_app/utils/constants/a_enums.dart';

import '../../../../utils/common/app_snack_bar.dart';
import '../views/inventory_config_view.dart';

class SettingsController extends GetxController {
  final UserService _userService = Get.find();
  final ShopService _shopService = Get.find();
  final AuthService _authService = Get.find();

  final Rx<Map<String, dynamic>> userProfile = Rx<Map<String, dynamic>>({});
  final Rx<Map<String, dynamic>> shopProfile = Rx<Map<String, dynamic>>({});

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
        "image": '',
      };

      // Get shop data
      final shopId = await _userService.getShopIdFromStorage();
      if (shopId == null) throw 'Shop ID not found in storage';

      final shopDoc = await _shopService.getShop(shopId);
      if (!shopDoc.exists) throw 'Shop data not found in Firestore';
      final shopData = shopDoc.data() as Map<String, dynamic>;
      shopProfile.value = {
        "name": shopData['name'] ?? 'No Shop Name',
        "location": shopData['location'] ?? 'No Location',
        "id": shopDoc.id,
      };

    } catch (e) {
      AppSnackBar.error(title: 'Error Loading Data', message: e.toString());
    }
  }


  // -- Inventory Configuration Data --
  // In a real app, these would come from Firebase
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

  // -- Text Controller for Dialogs --
  final textInputController = TextEditingController();

  // -- Actions --

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
