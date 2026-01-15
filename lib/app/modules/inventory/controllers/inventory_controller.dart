import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Define Status Enum for better type safety
enum ItemStatus { available, rented, repair }

class InventoryController extends GetxController {
  
  // Dummy Data matching your HTML example
  final RxList<Map<String, dynamic>> inventoryItems = <Map<String, dynamic>>[
    {
      "name": "Channel Islands - Shortboard",
      "size": "6' 2\"",
      "status": ItemStatus.available,
      // Use placeholder images if you don't have real URLs yet
      "imageUrl": "https://via.placeholder.com/150", 
    },
    {
      "name": "Firewire - Longboard",
      "size": "9' 0\"",
      "status": ItemStatus.rented,
      "imageUrl": "https://via.placeholder.com/150",
    },
    {
      "name": "Pyzel - Funboard",
      "size": "7' 6\"",
      "status": ItemStatus.repair,
      "imageUrl": "https://via.placeholder.com/150",
    },
    {
      "name": "Lost - Shortboard",
      "size": "5' 10\"",
      "status": ItemStatus.available,
      "imageUrl": "https://via.placeholder.com/150",
    },
  ].obs;

  void openAddItemScreen() {
    Get.snackbar("Action", "Add Item clicked");
    // Get.toNamed('/add-item');
  }

  void openSearch() {
    Get.snackbar("Action", "Search clicked");
  }

  void openFilter(String filterType) {
     Get.snackbar("Action", "Filter by $filterType clicked");
  }
  
  void openItemDetails(Map<String, dynamic> item) {
      Get.snackbar("Action", "Opened ${item['name']}");
      // Get.toNamed('/item-details', arguments: item);
  }

  // Helper to get status color and text
  Map<String, dynamic> getStatusDetails(ItemStatus status) {
    switch (status) {
      case ItemStatus.available:
        return {'color': const Color(0xFF28a745), 'text': 'Available'};
      case ItemStatus.rented:
        return {'color': const Color(0xFF6F42C1), 'text': 'Rented'};
      case ItemStatus.repair:
        return {'color': const Color(0xFFFFC107), 'text': 'Repair'};
    }
  }
}