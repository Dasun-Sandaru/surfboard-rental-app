import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ItemStatus { available, rented, repair }

class InventoryController extends GetxController {
  final Rxn<ItemStatus> selectedStatusFilter = Rxn<ItemStatus>();
  final RxList<String> selectedBrands = <String>[].obs;

  final List<String> availableBrands = [
    "Channel Islands",
    "Firewire",
    "Pyzel",
    "Lost",
    "JS Industries",
  ];

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

  void toggleBrandFilter(String brand) {
    selectedBrands.contains(brand)
        ? selectedBrands.remove(brand)
        : selectedBrands.add(brand);
  }

  void setStatusFilter(ItemStatus status) {
    selectedStatusFilter.value = selectedStatusFilter.value == status
        ? null
        : status;
  }

  void applyFilters() => Get.back();

  void resetFilters() {
    selectedStatusFilter.value = null;
    selectedBrands.clear();
    Get.back();
  }

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
