import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:surfboard_rental_app/app/services/user_service.dart';
import 'package:surfboard_rental_app/app/services/rental_service.dart';
import 'package:surfboard_rental_app/app/services/inventory_service.dart';
import 'package:surfboard_rental_app/app/services/customer_service.dart';
import 'package:surfboard_rental_app/app/services/sample_data_service.dart';
import 'package:surfboard_rental_app/utils/common/app_snack_bar.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../services/auth_service.dart';

class AdminHomeController extends GetxController {
  final selectedIndex = 0.obs;

  /// Change Bottom Navigation Index
  void changeIndex(int index) {
    if (index == 1) {
      Get.toNamed('/new-rental');
    } else {
      selectedIndex.value = index;
    }
  }

  // Dashboard Stats
  final activeRentals = 0.obs;
  final boardsAvailable = 0.obs;
  final damagesPending =
      0.obs; // This was tracking 'overdue' rentals in previous code
  final totalCustomers = 0.obs;
  final isLoadingStats = false.obs;

  // Services
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.find<UserService>();
  final RentalService _rentalService = RentalService();
  final InventoryService _inventoryService = InventoryService();
  final CustomerService _customerService = CustomerService();

  String? shopId;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    await _setShopId();
    loadDashboardStats();
  }

  Future<void> _setShopId() async {
    shopId = await _userService.getShopId();
    log('shopId: $shopId');
  }

  /// Load Dashboard Stats (Future based)
  Future<void> loadDashboardStats() async {
    if (shopId == null) return;

    // Optional: Only show loading if it's the first load or explicit refresh
    // isLoadingStats.value = true;

    try {
      log('Loading dashboard stats...', name: 'AdminHomeController');

      final results = await Future.wait([
        _rentalService.getRentalCountByStatus(
          shopId!,
          RentalStatus.active.name,
        ),
        _inventoryService.getInventoryCountByStatus(
          shopId!,
          InventoryStatus.available.name,
        ),
        _customerService.getCustomerCount(shopId!),
        _rentalService.getRentalCountByStatus(
          shopId!,
          RentalStatus.overdue.name,
        ),
      ]);

      activeRentals.value = results[0];
      boardsAvailable.value = results[1];
      totalCustomers.value = results[2];
      damagesPending.value = results[3];
    } catch (e) {
      log('Error loading dashboard stats: $e', name: 'AdminHomeController');
    } finally {
      isLoadingStats.value = false;
    }
  }

  Future<void> onRefresh() async {
    await loadDashboardStats();
  }

  /// Sign out
  Future<void> signOut() async => await _authService.signOut();

  /// Seed Sample Data
  Future<void> seedSampleData() async {
    if (shopId == null) return;
    final adminUid = _userService.currentUser?.uid;
    if (adminUid == null) return;

    try {
      AppSnackBar.info(
        title: "Seeding...",
        message: "Populating sample data...",
      );
      final sampleService = SampleDataService();
      await sampleService.seedData(shopId!, adminUid);

      await loadDashboardStats();
      AppSnackBar.success(
        title: "Success",
        message: "Sample data populated successfully!",
      );
    } catch (e) {
      AppSnackBar.error(title: "Error", message: "Failed to seed data: $e");
    }
  }
}
