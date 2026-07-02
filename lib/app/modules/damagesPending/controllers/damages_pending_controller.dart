import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'dart:async';

import '../../../../utils/constants/a_enums.dart';
import '../../../models/inventory_model.dart';
import '../../../services/user_service.dart';
import '../../../services/inventory_service.dart';
import '../../../../utils/common/app_snack_bar.dart';

class DamagesPendingController extends GetxController {
  final PagingController<DocumentSnapshot?, InventoryModel> pagingController =
      PagingController(firstPageKey: null);

  final TextEditingController searchTextController = TextEditingController();

  final InventoryService _inventoryService = InventoryService();
  final UserService _userService = Get.find();

  String? shopId;
  static const int _limit = 15;
  Timer? _debounce;
  String _currentSearchTerm = '';

  @override
  void onInit() {
    super.onInit();
    pagingController.addPageRequestListener((pageKey) async {
      await _fetchPage(pageKey);
    });
    searchTextController.addListener(() {
      onSearchChanged(searchTextController.text);
    });
    _initializeAndFetch();
  }

  Future<void> _initializeAndFetch() async {
    shopId = await _userService.getShopIdFromStorage();
    pagingController.refresh();
  }

  @override
  void onClose() {
    pagingController.dispose();
    searchTextController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  // ---------------------------------------------------------------------------
  // 1. FETCH PAGE LOGIC
  // ---------------------------------------------------------------------------
  Future<void> _fetchPage(DocumentSnapshot? pageKey) async {
    if (shopId == null) {
      pagingController.error = "Shop ID could not be retrieved.";
      return;
    }
    try {
      final snapshot = await _inventoryService.getInventoryPage(
        shopId: shopId!,
        types: [],
        statuses: [InventoryStatus.damaged.name],
        lastDocument: pageKey,
        searchTerm: _currentSearchTerm,
        pageSize: _limit,
      );

      if (isClosed) return;

      final newItems = snapshot.docs
          .map(
            (doc) => InventoryModel.fromSnapshot(
              doc as DocumentSnapshot<Map<String, dynamic>>,
            ),
          )
          .toList();

      final isLastPage =
          newItems.length < _limit || _currentSearchTerm.isNotEmpty;

      if (isLastPage) {
        pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = snapshot.docs.last;
        pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      pagingController.error = error;
    }
  }

  // ---------------------------------------------------------------------------
  // 2. SEARCH HANDLER
  // ---------------------------------------------------------------------------
  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _currentSearchTerm = query;
      if (!isClosed) pagingController.refresh();
    });
  }

  void selectRental(InventoryModel item) {
    Get.dialog(
      AlertDialog(
        backgroundColor: Get.theme.colorScheme.surfaceContainer,
        title: Text(
          'mark_repaired_title'.tr,
          style: TextStyle(color: Get.theme.colorScheme.onSurface),
        ),
        content: Text(
          'mark_repaired_content'.trParams({'item': item.name}),
          style: TextStyle(color: Get.theme.colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _markAsRepaired(item);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.primary,
              foregroundColor: Get.theme.colorScheme.onPrimary,
            ),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }

  Future<void> _markAsRepaired(InventoryModel item) async {
    if (shopId == null) return;
    try {
      await _inventoryService.updateInventoryStatus(
        shopId: shopId!,
        itemId: item.id,
        status: InventoryStatus.available.name,
      );
      pagingController.refresh();
      AppSnackBar.success(
        title: 'success'.tr,
        message: 'marked_repaired_success'.trParams({'item': item.name}),
      );
    } catch (e) {
      AppSnackBar.error(
        title: 'error'.tr,
        message: 'marked_repaired_error'.tr,
      );
    }
  }
}
