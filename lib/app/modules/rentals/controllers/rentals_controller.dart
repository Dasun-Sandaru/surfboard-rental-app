import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'dart:async';

import '../../../models/rental_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/user_service.dart';

class RentalsController extends GetxController {
  final PagingController<DocumentSnapshot?, RentalModel> pagingController =
      PagingController(firstPageKey: null);

  final TextEditingController searchTextController = TextEditingController();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
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
      Query query =
          _db.collection('shops').doc(shopId!).collection('rentals');

      if (_currentSearchTerm.isNotEmpty) {
        query = query
            .where(
              'itemName_lowercase',
              isGreaterThanOrEqualTo: _currentSearchTerm.toLowerCase(),
            )
            .where(
              'itemName_lowercase',
              isLessThan: '${_currentSearchTerm.toLowerCase()}z',
            )
            .limit(20);
      } else {
        query = query.orderBy('createdAt', descending: true).limit(_limit);

        if (pageKey != null) {
          query = query.startAfterDocument(pageKey);
        }
      }

      final snapshot = await query.get();

      final newItems = snapshot.docs
          .map((doc) =>
              RentalModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>))
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
      pagingController.refresh();
    });
  }

  void selectRental(RentalModel rental) {
    // Get.toNamed(Routes.RENTAL_DETAIL, arguments: rental);
    Get.toNamed(Routes.BOARD_INSPECTION, arguments: rental);
  }

  void addRental() {
    Get.toNamed(Routes.NEW_RENTAL);
  }

  // ---------------------------------------------------------------------------
  // 3. REFRESH HANDLER
  // ---------------------------------------------------------------------------
  Future<void> refreshRentals() async {
    _currentSearchTerm = '';
    searchTextController.clear();
    pagingController.refresh();
  }
}
