import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/a_enums.dart';
import '../../../models/inventory_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/user_service.dart';

class InventoryController extends GetxController {
  final FirestoreService _firestoreService = FirestoreService();
  final UserService _userService = UserService();

  final RxList<InventoryModel> items = <InventoryModel>[].obs;
  final RxList<String> selectedSurfboardTypes = <String>[].obs;

  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  bool hasMore = true;

  String shopId = '0000';
  final List<String> surfboardTypes = [
    "Shortboard",
    "Fish",
    "Longboard",
    "Consultant",
  ];

  @override
  Future<void> onInit() async {
    super.onInit();
    shopId = await _userService.getShopIdFromStorage() ?? '0000';
    loadMore();
  }

  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;

    isLoading = true;

    final snapshot = await _firestoreService.getInventoryPage(
      shopId: shopId,
      types: selectedSurfboardTypes,
      lastDocument: lastDocument,
      // types: ["Shortboard", "Fish"],
    );

    if (snapshot.docs.isNotEmpty) {
      lastDocument = snapshot.docs.last;

      items.addAll(
        snapshot.docs.map(
          (doc) => InventoryModel.fromMap(doc.data() as Map<String, dynamic>),
        ),
      );
    }

    if (snapshot.docs.length < 10) {
      hasMore = false;
    }

    isLoading = false;
  }

  void applyFilters() {
    items.clear();
    lastDocument = null;
    hasMore = true;
    Get.back();
    loadMore();
  }

  void resetFilters() {
    selectedSurfboardTypes.clear();
    applyFilters();
  }

  void toggleSurfboardType(String type) {
    if (selectedSurfboardTypes.contains(type)) {
      selectedSurfboardTypes.remove(type);
    } else {
      selectedSurfboardTypes.add(type);
    }

    // applyFilters();
  }
}
