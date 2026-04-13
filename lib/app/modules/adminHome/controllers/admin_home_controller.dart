import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import '../../../services/user_service.dart';
import '../../../services/rental_service.dart';
import '../../../services/inventory_service.dart';
import '../../../services/customer_service.dart';
import '../../../services/sample_data_service.dart';
import '../../../services/shop_service.dart';
import '../../../../data/firestore/firestore_fields.dart';
import '../../../../utils/common/app_snack_bar.dart';
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

  // Setup Completion Status
  final isSetupComplete = true.obs;
  final setupWarnings = <String>[].obs;
  final showSetupBanner = false.obs;

  // Services
  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.find<UserService>();
  final ShopService _shopService = ShopService();
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
    _setupRealTimeStats();
    checkSetupStatus();
  }

  Future<void> _setShopId() async {
    shopId = await _userService.getShopId();
    log('shopId: $shopId');
  }

  /// Setup Real-Time Dashboard Stats
  void _setupRealTimeStats() {
    if (shopId == null) return;

    log('Setting up real-time dashboard stats...', name: 'AdminHomeController');

    // 1. Active Rentals Stream
    activeRentals.bindStream(
      _rentalService.streamRentalCountByStatus(
        shopId!,
        RentalStatus.active.name,
      ),
    );

    // 2. Boards Available Stream
    boardsAvailable.bindStream(
      _inventoryService.streamInventoryCountByStatus(
        shopId!,
        InventoryStatus.available.name,
      ),
    );

    // 3. Total Customers Stream
    totalCustomers.bindStream(_customerService.streamCustomerCount(shopId!));

    // 4. Overdue Rentals (Damages Pending) Stream
    damagesPending.bindStream(
      _rentalService.streamRentalCountByStatus(
        shopId!,
        RentalStatus.overdue.name,
      ),
    );
  }

  /// Keep for legacy refresh or manual override
  Future<void> loadDashboardStats() async {
    _setupRealTimeStats();
  }

  Future<void> onRefresh() async {
    await loadDashboardStats();
    checkSetupStatus();
  }

  /// Check if shop setup is complete
  Future<void> checkSetupStatus() async {
    if (shopId == null) return;

    try {
      final warnings = <String>[];

      // Get shop data to check configuration
      final shopDoc = await _shopService.getShop(shopId!);
      if (!shopDoc.exists) return;

      final shopData = shopDoc.data() as Map<String, dynamic>?;
      if (shopData == null) return;

      // Check Currency
      final currency = shopData[FirestoreFields.currency];
      if (currency == null || currency.toString().isEmpty) {
        warnings.add('Currency not configured');
      }

      // Check Date Format
      final dateFormat = shopData[FirestoreFields.dateFormat];
      if (dateFormat == null || dateFormat.toString().isEmpty) {
        warnings.add('Date format not configured');
      }

      // Check Timezone
      final timeZone = shopData[FirestoreFields.timeZone];
      if (timeZone == null || timeZone.toString().isEmpty) {
        warnings.add('Timezone not configured');
      }

      // Check Rental Pricing - Default Hourly/Daily Rates
      final defaultHourlyRate = shopData[FirestoreFields.defaultHourlyRate];
      final defaultDailyRate = shopData[FirestoreFields.defaultDailyRate];
      if ((defaultHourlyRate == null || defaultHourlyRate == 0) &&
          (defaultDailyRate == null || defaultDailyRate == 0)) {
        warnings.add('Rental pricing rules not configured');
      }

      // Update observables
      setupWarnings.assignAll(warnings);
      isSetupComplete.value = warnings.isEmpty;
      showSetupBanner.value = warnings.isNotEmpty;

      log(
        'Setup check complete. Warnings: ${warnings.length}',
        name: 'AdminHomeController',
      );
    } catch (e) {
      log('Error checking setup status: $e', name: 'AdminHomeController');
    }
  }

  /// Dismiss setup banner temporarily
  void dismissSetupBanner() {
    showSetupBanner.value = false;
  }

  /// Sign out
  Future<void> signOut() async => await _authService.signOut();

  /// Granular Seeding Tasks
  Future<void> runSeedTask(String taskType) async {
    if (shopId == null) return;
    final adminUid = _userService.currentUser?.uid;
    if (adminUid == null) return;

    final sampleService = SampleDataService();
    isLoadingStats.value = true;

    try {
      AppSnackBar.info(
        title: "Seeding...",
        message: "Seeding $taskType data...",
      );

      switch (taskType) {
        case 'Users':
          await sampleService.seedUsers(shopId!);
          break;
        case 'Inventory':
          await sampleService.seedInventory(shopId!);
          break;
        case 'Customers':
          await sampleService.seedCustomers(shopId!);
          break;
        case 'Rentals':
          // We need IDs for these, so we call a helper that fetches them first or just seeds all for consistency
          final cIds = await sampleService.seedCustomers(shopId!);
          final iIds = await sampleService.seedInventory(shopId!);
          await sampleService.seedRentals(
            shopId: shopId!,
            customerIds: cIds,
            inventoryIds: iIds,
            staffId: adminUid,
            staffName: "Admin User",
          );
          break;
        case 'All':
          await sampleService.seedAll(shopId!, adminUid);
          break;
        case 'Backup':
          final path = await sampleService.exportFullDatabase(shopId!);
          AppSnackBar.success(
            title: "Export Success",
            message: "Database backup saved to: $path",
          );
          return; // Skip the default success message below
      }

      await loadDashboardStats();
      AppSnackBar.success(
        title: "Success",
        message: "$taskType data populated successfully!",
      );
    } catch (e) {
      log('Error seeding $taskType: $e', name: 'AdminHomeController');
      AppSnackBar.error(
        title: "Error",
        message: "Failed to seed $taskType: $e",
      );
    } finally {
      isLoadingStats.value = false;
    }
  }

  /// Original method trigger (can be updated to show options)
  Future<void> seedSampleData() async {
    // We will show the options in the View via a BottomSheet
  }
}
