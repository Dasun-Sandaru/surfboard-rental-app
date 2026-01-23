import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surfboard_rental_app/app/models/payment_model.dart';
import 'package:surfboard_rental_app/app/routes/app_pages.dart';
import 'package:surfboard_rental_app/app/services/rental_service.dart';
import 'package:surfboard_rental_app/app/services/user_service.dart';

import '../../../models/rental_model.dart';

class BoardInspectionController extends GetxController {
  final RentalService _rentalService = Get.find();
  final UserService _userService = Get.find();

  // Controller Status
  final status = RxStatus.loading().obs;

  // Data
  late String rentalId;
  final rental = Rx<RentalModel?>(null);
  Stream<RentalModel> rentalStream = Stream.empty();
  StreamSubscription? _rentalStreamSub;
  final RxList<PaymentModel> paymentHistory = <PaymentModel>[].obs;

  // For the real-time countdown timer
  Timer? _timer;
  final RxString timeLabel = "Time Remaining".obs;
  final RxString timeRemaining = "00:00:00".obs;
  final Rx<Color> timeColor = Colors.white.obs;

  // Firestore reference
  late FirebaseFirestore _firestore;

  @override
  void onInit() {
    super.onInit();
    _firestore = FirebaseFirestore.instance;
    rentalId = Get.arguments;
  }

  @override
  void onReady() {
    super.onReady();
    _loadRentalData();
  }

  Future<void> _loadRentalData() async {
    status.value = RxStatus.loading();
    final String? shopId = await _userService.getShopIdFromStorage();

    if (shopId == null) {
      status.value = RxStatus.error('Could not retrieve shop ID.');
      Get.snackbar('Error', 'Could not retrieve shop ID.');
      return;
    }

    rentalStream = _rentalService.streamRentalById(shopId, rentalId);
    _rentalStreamSub = rentalStream.listen((rentalData) {
      rental.value = rentalData;
      _setupPaymentListener();
      _updateTimer();
      status.value = RxStatus.success();
    }, onError: (error) {
      status.value = RxStatus.error(error.toString());
      Get.snackbar('Error', 'Failed to load rental data.');
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (rental.value != null) {
        _updateTimer();
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    _rentalStreamSub?.cancel();
    super.onClose();
  }

  // --- Listener Methods ---
  void _setupPaymentListener() {
    if (rental.value == null) return;
    _firestore
        .collection('shops')
        .doc(rental.value!.shopId)
        .collection('rentals')
        .doc(rental.value!.id)
        .collection('payments')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            final payments = snapshot.docs
                .map((doc) => PaymentModel.fromSnapshot(doc))
                .toList();
            paymentHistory.assignAll(payments);
          },
          onError: (e) {
            print('Error listening to payments: $e');
          },
        );
  }

  // --- Navigation ---
  void goToCustomerDetails() {
    if (rental.value?.customerId != null) {
      Get.toNamed(Routes.CUSTOMER_DETAILS, arguments: rental.value!.customerId);
    }
  }

  void goToItemDetails() {
    if (rental.value?.itemId != null) {
      Get.toNamed(Routes.ITEM_DETAILS, arguments: rental.value!.itemId);
    }
  }

  void goToStaffDetails() {
    if (rental.value?.staffId != null) {
      Get.toNamed(Routes.USER_DETAIL, arguments: rental.value!.staffId);
    }
  }


  // --- Getters ---
  double get balanceDue =>
      (rental.value?.amountExpected ?? 0) - (rental.value?.amountPaid ?? 0);

  String get staffName => rental.value?.staffId ?? '';

  String get customerName => rental.value?.customerId ?? '';

  String get boardName => rental.value?.itemId ?? '';

  double get totalPaymentsMade =>
      paymentHistory.fold(0.0, (sum, payment) => sum + payment.amount);

  // --- Actions ---
  void reportNoDamage() {
    // Logic: If balance is 0, just close. If balance exists, show Payment Dialog.
    if (balanceDue.abs() > 0.01) {
      _showSettlementDialog(damageFee: 0);
    } else {
      _finalizeReturn(damageFee: 0, finalPayment: 0);
    }
  }

  void reportDamage() {
    // For this example, we simulate a $50 fee
    _showSettlementDialog(damageFee: 50.0);
  }

  // -- Timer Logic --
  void _updateTimer() {
    if (rental.value == null) return;
    final now = DateTime.now();
    final dueTime = rental.value!.expectedReturnTime;
    final difference = dueTime.difference(now);

    if (difference.isNegative) {
      // Overdue
      timeLabel.value = "Overdue";
      timeColor.value = const Color(0xFFEF4444); // errorRed
      timeRemaining.value = _formatDuration(difference.abs());
    } else {
      // Time Remaining
      timeLabel.value = "Time Remaining";
      timeColor.value = const Color(0xFF34C759); // successGreen
      timeRemaining.value = _formatDuration(difference);
    }
  }

  String _formatDuration(Duration d) {
    // HH:MM:SS format
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$hours:$minutes:$seconds";
  }

  // -- UI Interaction --
  void _showSettlementDialog({required double damageFee}) {
    double finalTotal = balanceDue + damageFee;
    String actionText = finalTotal > 0 ? "Collect Payment" : "Refund Customer";

    Get.defaultDialog(
      title: "Settlement Required",
      backgroundColor: const Color(0xFF182c30),
      titleStyle: const TextStyle(color: Colors.white),
      content: Column(
        children: [
          _summaryRow("Outstanding Rent", balanceDue),
          if (damageFee > 0) _summaryRow("Damage Fee", damageFee),
          const Divider(color: Colors.grey),
          _summaryRow("Net Payable", finalTotal, isBold: true),
        ],
      ),
      textConfirm: actionText,
      confirmTextColor: Colors.white,
      buttonColor: finalTotal > 0
          ? const Color(0xFF4A90E2)
          : const Color(0xFFF59E0B),
      onConfirm: () {
        _finalizeReturn(damageFee: damageFee, finalPayment: finalTotal);
      },
      textCancel: "Cancel",
    );
  }

  void _finalizeReturn({
    required double damageFee,
    required double finalPayment,
  }) {
    Get.back(); // Close dialog
    Get.back(); // Close screen
    Get.snackbar(
      "Return Complete",
      "Rental closed. ${finalPayment != 0 ? 'Payment recorded.' : ''}",
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.green,
    );
  }

  Widget _summaryRow(String label, double amount, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            "\$${amount.abs().toStringAsFixed(2)}",
            style: TextStyle(
              color: Colors.white,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
