import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/common/app_snack_bar.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../models/inventory_model.dart';
import '../../../services/inventory_service.dart';
import '../../../services/user_service.dart';

class InventoryController extends GetxController {
  static const String _logName = 'InventoryController';
  final GlobalKey<FormState> sizeFormKey = GlobalKey<FormState>();

  final InventoryService _inventoryService = InventoryService();
  final UserService _userService = UserService();

  final RxList<InventoryModel> items = <InventoryModel>[].obs;
  final RxList<SurfBoardType> selectedSurfboardTypes = <SurfBoardType>[].obs;
  final RxList<InventoryStatus> selectedStatuses = <InventoryStatus>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMoreItems = true.obs;

  final RxBool isSelectMode = false.obs;
  RxBool isLessThan = false.obs;
  RxBool isSizeFilterActive = false.obs;
  final TextEditingController searchTextController = TextEditingController();
  Timer? _debounce;
  String _currentSearchTerm = '';

  String? shopId;
  DocumentSnapshot? lastDocument;
  final List<SurfBoardType> surfboardTypes = SurfBoardType.values;
  final List<InventoryStatus> inventoryStatuses = InventoryStatus.values;

  final feetSizeController = TextEditingController();
  final inchesSizeController = TextEditingController();

  // String

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      if (Get.arguments != null && Get.arguments is Map) {
        final Map args = Get.arguments as Map;
        if (args['selectMode'] == true) {
          isSelectMode.value = true;
          selectedStatuses.add(InventoryStatus.available);
        }
      }
      shopId = await _userService.getShopIdFromStorage();
      log('Initialized with shopId: $shopId', name: _logName);
      feetSizeController.addListener(_updateSizeFilterState);
      inchesSizeController.addListener(_updateSizeFilterState);
      loadMore();
    } catch (e) {
      log('Error in onInit: $e', name: _logName);
      AppSnackBar.error(
        title: 'Initialization Error',
        message: 'Failed to initialize inventory: $e',
      );
    }
  }

  @override
  void onClose() {
    feetSizeController.removeListener(_updateSizeFilterState);
    inchesSizeController.removeListener(_updateSizeFilterState);
    feetSizeController.dispose();
    inchesSizeController.dispose();
    searchTextController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  void _updateSizeFilterState() {
    isSizeFilterActive.value =
        feetSizeController.text.isNotEmpty ||
        inchesSizeController.text.isNotEmpty;
  }

  Future<void> loadMore() async {
    try {
      if (isLoading.value || !hasMoreItems.value) return;

      isLoading.value = true;
      log('Loading more items...', name: _logName);

      if (shopId == null) {
        log('Shop ID is null, cannot load items.', name: _logName);
        isLoading.value = false;
        hasMoreItems.value = false; // Stop further attempts
        return;
      }

      final snapshot = await _inventoryService.getInventoryPage(
        shopId: shopId!,
        types: selectedSurfboardTypes.map((e) => e.name).toList(),
        statuses: selectedStatuses.map((e) => e.name).toList(),
        lastDocument: lastDocument,
        sizeFeet: feetSizeController.text.isNotEmpty
            ? feetSizeController.text
            : null,
        sizeInches: inchesSizeController.text.isNotEmpty
            ? inchesSizeController.text
            : null,
        isLessThan: isLessThan.value,
        searchTerm: _currentSearchTerm,
      );

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last;
        items.addAll(
          snapshot.docs.map(
            (doc) => InventoryModel.fromMap(doc.data() as Map<String, dynamic>),
          ),
        );
        log('Loaded ${snapshot.docs.length} items', name: _logName);
      }

      if (snapshot.docs.length < 10) {
        hasMoreItems.value = false;
      }
    } catch (e) {
      log('Error loading more items: $e', name: _logName);
      AppSnackBar.error(
        title: 'Load Error',
        message: 'Failed to load inventory items: $e',
      );
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilters({bool validate = true}) {
    try {
      log('Applying filters...', name: _logName);

      // Validate the form
      if (validate &&
          sizeFormKey.currentState != null &&
          !sizeFormKey.currentState!.validate()) {
        AppSnackBar.warning(
          title: 'Validation Error',
          message: 'Please check the size filters',
        );
        return;
      }

      items.clear();
      lastDocument = null;
      hasMoreItems.value = true;
      loadMore();
      Get.back();

      log('Filters applied successfully', name: _logName);
    } catch (e) {
      log('Error applying filters: $e', name: _logName);
      AppSnackBar.error(
        title: 'Filter Error',
        message: 'Failed to apply filters: $e',
      );
    }
  }

  void resetFilters() {
    try {
      log('Resetting filters...', name: _logName);

      selectedSurfboardTypes.clear();
      if (!isSelectMode.value) {
        selectedStatuses.clear();
      }
      feetSizeController.clear();
      inchesSizeController.clear();
      isLessThan.value = false;

      applyFilters(validate: false);

      log('Filters reset successfully', name: _logName);
      AppSnackBar.info(
        title: 'Filters Reset',
        message: 'All filters have been cleared',
      );
    } catch (e) {
      log('Error resetting filters: $e', name: _logName);
      AppSnackBar.error(
        title: 'Reset Error',
        message: 'Failed to reset filters: $e',
      );
    }
  }

  void toggleSurfboardType(SurfBoardType type) {
    if (selectedSurfboardTypes.contains(type)) {
      selectedSurfboardTypes.remove(type);
    } else {
      selectedSurfboardTypes.add(type);
    }
  }

  void toggleStatus(InventoryStatus status) {
    if (isSelectMode.value) {
      AppSnackBar.info(
        title: 'Filter Locked',
        message: 'Only available items can be selected in this mode.',
      );
      return;
    }
    if (selectedStatuses.contains(status)) {
      selectedStatuses.remove(status);
    } else {
      selectedStatuses.add(status);
    }
  }

  /// toggle Less Than / Greater Than for size filter
  void toggleLessThan() {
    isLessThan.value = !isLessThan.value;
  }

  Future<void> onRefresh() async {
    items.clear();
    lastDocument = null;
    hasMoreItems.value = true;
    await loadMore();
  }

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _currentSearchTerm = query;
      items.clear();
      lastDocument = null;
      hasMoreItems.value = true;
      loadMore();
    });
  }
}
