import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import '../../../services/config_service.dart';
import '../../../../utils/common/app_snack_bar.dart';
import '../../../services/user_service.dart';
import '../../../services/rental_service.dart';
import '../../../services/inventory_service.dart';
import '../../../services/customer_service.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../services/auth_service.dart';
import '../../../services/notification_sync_service.dart';

class StaffHomeController extends GetxController {
  final selectedIndex = 0.obs;

  /// Change Bottom Navigation Index
  void changeIndex(int index) {
    if (index == 1) {
      Get.toNamed('/new-rental');
    } else if (index == 2) {
      if (Get.isRegistered<ConfigService>()) {
        final configService = Get.find<ConfigService>();
        if (configService.staffAccessRules.containsKey('activity_logs') &&
            configService.staffAccessRules['activity_logs'] == false) {
          AppSnackBar.warning(
            title: 'Access Denied',
            message:
                'You do not have access to this feature. Please contact the admin.',
          );
          return;
        }
      }
      selectedIndex.value = index;
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
    _setupRealTimeStats();
  }

  Future<void> _setShopId() async {
    shopId = await _userService.getShopId();
    log('shopId: $shopId');
    if (shopId != null) {
      Get.find<NotificationSyncService>().startSync();
    }
  }

  /// Setup Real-Time Dashboard Stats
  void _setupRealTimeStats() {
    if (shopId == null) return;

    log('Setting up real-time dashboard stats...', name: 'StaffHomeController');

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
  }

  /// Sign out
  Future<void> signOut() async => await _authService.signOut();
}
