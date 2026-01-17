import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/a_enums.dart';
import '../../../models/inventory_model.dart';
import '../../../services/firestore_service.dart';
import '../../../services/user_service.dart';

class InventoryController extends GetxController {
  final GlobalKey<FormState> sizeFormKey = GlobalKey<FormState>();

  final FirestoreService _firestoreService = FirestoreService();
  final UserService _userService = UserService();

  final RxList<InventoryModel> items = <InventoryModel>[].obs;
  final RxList<String> selectedSurfboardTypes = <String>[].obs;

  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  bool hasMore = true;

  RxBool isLessThan = false.obs;
  RxBool isSizeFilterActive = false.obs;

  String shopId = '0000';
  final List<String> surfboardTypes = [
    "Shortboard",
    "Fish",
    "Longboard",
    "Consultant",
  ];

  final feetSizeController = TextEditingController();
  final inchesSizeController = TextEditingController();

  // String

  @override
  Future<void> onInit() async {
    super.onInit();
    shopId = await _userService.getShopIdFromStorage() ?? '0000';
    feetSizeController.addListener(_updateSizeFilterState);
    inchesSizeController.addListener(_updateSizeFilterState);
    loadMore();
  }

  @override
  void onClose() {
    feetSizeController.removeListener(_updateSizeFilterState);
    inchesSizeController.removeListener(_updateSizeFilterState);
    feetSizeController.dispose();
    inchesSizeController.dispose();
    super.onClose();
  }

  void _updateSizeFilterState() {
    isSizeFilterActive.value =
        feetSizeController.text.isNotEmpty || inchesSizeController.text.isNotEmpty;
  }

  Future<void> loadMore() async {
    if (isLoading || !hasMore) return;

    isLoading = true;

    final snapshot = await _firestoreService.getInventoryPage(
      shopId: shopId,
      types: selectedSurfboardTypes,
      lastDocument: lastDocument,
      sizeFeet: feetSizeController.text.isNotEmpty
          ? feetSizeController.text
          : null,
      sizeInches: inchesSizeController.text.isNotEmpty
          ? inchesSizeController.text
          : null,
      isLessThan: isLessThan.value,
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

  void applyFilters({bool validate = true}) {
    // items.clear();
    // lastDocument = null;
    // hasMore = true;
    // Get.back();
    // loadMore();

    // Validate the form
    if (validate &&
        sizeFormKey.currentState != null &&
        !sizeFormKey.currentState!.validate()) {
      return;
    }

    items.clear();
    lastDocument = null;
    hasMore = true;
    loadMore();
    Get.back();
  }

  void resetFilters() {
    selectedSurfboardTypes.clear();
    feetSizeController.clear();
    inchesSizeController.clear();
    isLessThan.value = false;

    applyFilters(validate: false);
  }

  void toggleSurfboardType(String type) {
    if (selectedSurfboardTypes.contains(type)) {
      selectedSurfboardTypes.remove(type);
    } else {
      selectedSurfboardTypes.add(type);
    }

    // applyFilters();
  }

  /// toggle Less Than / Greater Than for size filter
  void toggleLessThan() {
    isLessThan.value = !isLessThan.value;
  }
}
