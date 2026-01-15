import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../views/inventory_config_view.dart';

class SettingsController extends GetxController {
  
  // -- Dummy User/Shop Data --
  final userProfile = {
    "name": "Admin User",
    "role": "Owner",
    "email": "admin@surfshop.com",
    "image": "https://via.placeholder.com/150"
  }.obs;

  final shopProfile = {
    "name": "Aloha Surf Rentals",
    "location": "Ahangama, Sri Lanka",
    "id": "SHOP-8821"
  }.obs;

  // -- Inventory Configuration Data --
  // In a real app, these would come from Firebase
  final RxList<String> brands = <String>[
    "Channel Islands",
    "Firewire",
    "Pyzel",
    "Lost",
    "JS Industries",
    "Torq"
  ].obs;

  final RxList<String> boardTypes = <String>[
    "Shortboard",
    "Longboard",
    "Funboard",
    "Fish",
    "Gun",
    "Soft Top"
  ].obs;

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
      }
    );
  }

  // Generic function to add item to a list
  void addItem(String title, RxList<String> list) {
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
          Get.snackbar("Success", "$title added successfully", 
            backgroundColor: Colors.green.withOpacity(0.1), colorText: Colors.green);
        }
      }
    );
  }

  // Generic function to remove item
  void removeItem(String item, RxList<String> list) {
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
      }
    );
  }
  
  void navigateToInventorySettings() {
    Get.to(() => const InventoryConfigView());
  }
}