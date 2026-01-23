import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/a_enums.dart';
import '../../../models/rental_model.dart';
import '../../../models/security_deposit_model.dart';

class BoardInspectionController extends GetxController {
  // Reactive Rental Model
  late Rx<RentalModel> rental;

  // For the real-time countdown timer
  Timer? _timer;
  final RxString timeLabel = "Time Remaining".obs;
  final RxString timeRemaining = "00:00:00".obs;
  final Rx<Color> timeColor = Colors.white.obs;

  @override
  void onInit() {
    super.onInit();
    // 1. Get arguments passed from the previous screen (Active Rentals List)
    if (Get.arguments != null && Get.arguments is RentalModel) {
      rental = (Get.arguments as RentalModel).obs;
    } else {
      rental = _getDummyRental().obs;
    }

    // 2. Start the timer to update the time remaining every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTimer());
    _updateTimer(); // Initial call to set the value immediately
  }

  @override
  void onClose() {
    _timer?.cancel(); // Dispose the timer to prevent memory leaks
    super.onClose();
  }

  // --- Core Business Logic ---

  // Calculate Balance (Positive = Customer Owes, Negative = Refund Due)
  double get balanceDue =>
      rental.value.amountExpected - rental.value.amountPaid;

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
    final now = DateTime.now();
    final dueTime = rental.value.expectedReturnTime;
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

  // --- Dummy Data ---
  RentalModel _getDummyRental() {
    return RentalModel(
      id: "R-1001",
      shopId: "S-01",
      customerId: "C-99",
      itemId: "LB-017",
      staffId: "ST-01",
      startTime: DateTime.now().subtract(const Duration(hours: 4)),
      expectedReturnTime: DateTime.now().add(const Duration(minutes: 1, seconds: 30)),
      status: RentalStatus.active,
      rentType: RentType.hourly,
      paymentStatus: PaymentStatus.partial,
      rate: 15.0,
      amountExpected: 60.0,
      amountPaid: 20.0,
      securityDeposit: SecurityDepositModel(
        enabled: true,
        amount: 100.0,
        paid: 200.0,
        refunded: 0.0,
      ),
      createdAt: DateTime.now(),
    );
  }
}
