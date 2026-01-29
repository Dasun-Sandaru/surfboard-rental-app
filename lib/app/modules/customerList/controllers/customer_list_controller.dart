import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'dart:async';
import 'package:surfboard_rental_app/data/firestore/firestore_collections.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';

import '../../../models/customer_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/user_service.dart';

class CustomerListController extends GetxController {
  final PagingController<DocumentSnapshot?, CustomerModel> pagingController =
      PagingController(firstPageKey: null);

  final TextEditingController searchController = TextEditingController();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final UserService _userService = Get.find();
  String? shopId;
  static const int _limit = 15;
  Timer? _debounce;
  String _currentSearchTerm = '';
  bool isSelectionMode = false;

  @override
  void onInit() {
    super.onInit();
    // Register listener immediately
    pagingController.addPageRequestListener((pageKey) async {
      await _fetchPage(pageKey);
    });
    // Then initialize and fetch
    _initializeAndFetch();
  }

  Future<void> _initializeAndFetch() async {
    isSelectionMode = Get.arguments?['selectMode'] ?? false;
    shopId = await _userService.getShopIdFromStorage();
    // Trigger initial fetch only after shopId is ready
    pagingController.refresh();
  }

  @override
  void onClose() {
    pagingController.dispose();
    searchController.dispose();
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
      Query query = _db
          .collection(FirestoreCollections.shops)
          .doc(shopId!)
          .collection(FirestoreCollections.customers);

      // A. APPLY SEARCH OR SORT
      if (_currentSearchTerm.isNotEmpty) {
        // Search Mode: Simple query, limit 20, no pagination needed for typical search
        // Note: Firestore search requires exact case handling or specific setup.
        query = query
            .where(
              'name_lowercase', // TODO: Add to fields if necessary
              isGreaterThanOrEqualTo: _currentSearchTerm.toLowerCase(),
            )
            .where(
              'name_lowercase',
              isLessThan: '${_currentSearchTerm.toLowerCase()}z',
            )
            .limit(20);
      } else {
        // Standard Mode: Chronological order
        query = query
            .orderBy(FirestoreFields.createdAt, descending: true)
            .limit(_limit);

        if (pageKey != null) {
          query = query.startAfterDocument(pageKey);
        }
      }

      final QuerySnapshot snapshot = await query.get();

      final newItems = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data[FirestoreFields.id] = doc.id;
        return CustomerModel.fromJson(data);
      }).toList();

      // B. DETERMINE IF LAST PAGE
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
      // Triggers a complete reload of the list
      pagingController.refresh();
    });
  }

  void addCustomer() {
    // Navigate to add customer screen or show dialog
    Get.toNamed(Routes.ADD_EDIT_CUSTOMER, arguments: {'isEdit': false});
  }

  // ---------------------------------------------------------------------------
  // 3. REFRESH HANDLER (Pull to Refresh)
  // ---------------------------------------------------------------------------
  Future<void> refreshCustomers() async {
    // Clear search and reset to default view
    _currentSearchTerm = '';
    searchController.clear();
    // Refresh the paging controller
    pagingController.refresh();
  }
}
