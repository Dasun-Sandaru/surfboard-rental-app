import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:surfboard_rental_app/app/routes/app_pages.dart';
import 'package:surfboard_rental_app/app/services/user_service.dart';
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
  final damagesPending = 0.obs;
  final totalCustomers = 0.obs;

  // Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? shopId;

  // Stream Subscriptions (to cancel later)
  StreamSubscription? _rentalsSub;
  StreamSubscription? _inventorySub;
  StreamSubscription? _customersSub;
  StreamSubscription? _damagesSub;

  final AuthService _authService = Get.find<AuthService>();
  final UserService _userService = Get.find<UserService>();

  @override
  void onInit() {
    super.onInit();
    _setShopId();
  }

  Future<void> _setShopId() async {
    shopId = await _userService.getShopId();
    log('shopId: $shopId');

    _listenActiveRentals();
    _listenInventory();
    _listenCustomers();
    _listenDamages();
  }

  /// REAL-TIME LISTENERS
  /// Active Rentals
  void _listenActiveRentals() {
    _rentalsSub = _firestore
        .collection('shops')
        .doc(shopId)
        .collection('rentals')
        .where('status', isEqualTo: RentalStatus.active.name)
        .snapshots()
        .listen((snapshot) {
          activeRentals.value = snapshot.docs.length;
        });
  }

  /// Boards Available
  void _listenInventory() {
    _inventorySub = _firestore
        .collection('shops')
        .doc(shopId)
        .collection('inventory')
        .where('status', isEqualTo: InventoryStatus.available.name)
        .snapshots()
        .listen((snapshot) {
          boardsAvailable.value = snapshot.docs.length;
        });
  }

  /// Total Customers
  void _listenCustomers() {
    _customersSub = _firestore
        .collection('shops')
        .doc(shopId)
        .collection('customers')
        .snapshots()
        .listen((snapshot) {
          totalCustomers.value = snapshot.docs.length;
        });
  }

  /// Damages Pending
  /// Count damage reports where severity exists
  void _listenDamages() {
    _damagesSub = _firestore
        .collection('shops')
        .doc(shopId)
        .collection('rentals')
        .where('status', isEqualTo: RentalStatus.overdue.name)
        .snapshots()
        .listen((snapshot) {
          damagesPending.value = snapshot.docs.length;
        });
  }

  /// Sign out
  Future<void> signOut() async => await _authService.signOut();

  @override
  void onClose() {
    _rentalsSub?.cancel();
    _inventorySub?.cancel();
    _customersSub?.cancel();
    _damagesSub?.cancel();
    super.onClose();
  }
}
