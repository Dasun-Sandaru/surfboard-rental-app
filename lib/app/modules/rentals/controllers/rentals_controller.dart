import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'dart:async';

import '../../../../utils/constants/a_enums.dart';
import '../../../models/rental_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/user_service.dart';

import 'package:surfboard_rental_app/app/services/rental_service.dart';

class RentalsController extends GetxController {
  final PagingController<DocumentSnapshot?, RentalModel> pagingController =
      PagingController(firstPageKey: null);

  final TextEditingController searchTextController = TextEditingController();

  final RentalService _rentalService = RentalService();
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
      final snapshot = await _rentalService.getRentalsPage(
        shopId: shopId!,
        limit: _limit,
        startAfter: pageKey,
        searchTerm: _currentSearchTerm,
      );

      final newItems = snapshot.docs
          .map(
            (doc) => RentalModel.fromSnapshot(
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
      pagingController.refresh();
    });
  }

  void selectRental(RentalModel rental) {
    if (rental.status == RentalStatus.item_returned) {
      Get.toNamed(
        Routes.PAYMENTS,
        arguments: {'rentalId': rental.id, 'shopId': rental.shopId},
      );
    } else {
      Get.toNamed(Routes.BOARD_INSPECTION, arguments: rental.id);
    }
  }

  void addRental() {
    Get.toNamed(Routes.NEW_RENTAL);
  }

  void goToCustomerDetails(String customerId) {
    Get.toNamed(Routes.CUSTOMER_DETAILS, arguments: customerId);
  }

  void goToItemDetails(String itemId) {
    Get.toNamed(Routes.ITEM_DETAILS, arguments: itemId);
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
