import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:surfboard_rental_app/app/models/rental_model.dart';
import 'package:surfboard_rental_app/app/routes/app_pages.dart';
import 'package:surfboard_rental_app/app/services/rental_service.dart';
import 'package:surfboard_rental_app/app/services/user_service.dart';
import 'package:surfboard_rental_app/utils/constants/a_enums.dart';

class RentalHistoryController extends GetxController {
  final PagingController<DocumentSnapshot?, RentalModel> pagingController =
      PagingController(firstPageKey: null);

  final TextEditingController searchTextController = TextEditingController();

  final RentalService _rentalService = RentalService();
  final UserService _userService = Get.find();

  String? shopId;
  static const int _limit = 15;
  Timer? _debounce;
  String _currentSearchTerm = '';
  Rx<DateTimeRange?> dateRange = Rx<DateTimeRange?>(null);
  final Rx<RentalStatus?> selectedFilter = Rx<RentalStatus?>(null);

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
        status: selectedFilter.value,
        startDate: dateRange.value?.start,
        endDate: dateRange.value?.end,
      );

      if (isClosed) return;

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

  void onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      _currentSearchTerm = query;
      if (!isClosed) pagingController.refresh();
    });
  }

  void updateFilter(RentalStatus? status) {
    if (selectedFilter.value == status) return;
    selectedFilter.value = status;
    pagingController.refresh();
  }

  Future<void> pickDateRange(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: dateRange.value,
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: Theme.of(context).colorScheme),
          child: child!,
        );
      },
    );

    if (picked != null && picked != dateRange.value) {
      // Set end date to end of day to include all records for that day
      dateRange.value = DateTimeRange(
        start: picked.start,
        end: picked.end.add(
          const Duration(hours: 23, minutes: 59, seconds: 59),
        ),
      );
      if (!isClosed) pagingController.refresh();
    }
  }

  void clearDateRange() {
    if (dateRange.value != null) {
      dateRange.value = null;
      pagingController.refresh();
    }
  }

  Future<void> refreshRentals() async {
    _currentSearchTerm = '';
    searchTextController.clear();
    // dateRange.value = null; // Optional: Clear date range on pull-to-refresh? User might expect filters to stay.
    pagingController.refresh();
  }

  void selectRental(RentalModel rental) {
    Get.toNamed(Routes.RENTAL_DETAIL, arguments: rental);
  }
}
