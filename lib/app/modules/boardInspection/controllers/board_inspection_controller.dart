import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surfboard_rental_app/app/models/payment_model.dart';
import 'package:surfboard_rental_app/app/routes/app_pages.dart';
import 'package:surfboard_rental_app/app/services/rental_service.dart';
import 'package:surfboard_rental_app/app/services/user_service.dart';
import 'package:surfboard_rental_app/utils/common/app_snack_bar.dart';

import 'package:surfboard_rental_app/utils/theme/app_material_theme.dart';
import '../../../models/rental_model.dart';

import 'package:surfboard_rental_app/app/services/payment_service.dart';

class BoardInspectionController extends GetxController {
  final RentalService _rentalService = Get.find();
  final UserService _userService = Get.find();
  final PaymentService _paymentService = PaymentService();

  // Controller Status
  final status = RxStatus.loading().obs;

  // Data
  late String rentalId;
  final rental = Rx<RentalModel?>(null);
  Stream<RentalModel> rentalStream = Stream.empty();
  StreamSubscription? _rentalStreamSub;
  StreamSubscription? _paymentStreamSub;
  final RxList<PaymentModel> paymentHistory = <PaymentModel>[].obs;

  // For the real-time countdown timer
  Timer? _timer;
  final RxString timeLabel = "Time Remaining".obs;
  final RxString timeRemaining = "00:00:00".obs;
  final Rx<Color> timeColor = Colors.white.obs;

  @override
  void onInit() {
    super.onInit();
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
      AppSnackBar.error(title: 'Error', message: 'Could not retrieve shop ID.');
      return;
    }

    rentalStream = _rentalService.streamRentalById(shopId, rentalId);
    _rentalStreamSub = rentalStream.listen(
      (rentalData) {
        rental.value = rentalData;
        _setupPaymentListener();
        _updateTimer();
        status.value = RxStatus.success();
      },
      onError: (error) {
        status.value = RxStatus.error(error.toString());
        AppSnackBar.error(
          title: 'Error',
          message: 'Failed to load rental data.',
        );
      },
    );

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
    _paymentStreamSub?.cancel();
    super.onClose();
  }

  // --- Listener Methods ---
  void _setupPaymentListener() {
    final r = rental.value;
    if (r == null || r.id == null) return;

    // Cancel previous subscription if any
    _paymentStreamSub?.cancel();

    _paymentStreamSub = _paymentService
        .paymentStream(r.shopId, r.id!)
        .listen(
          (payments) {
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
    Get.toNamed(
      Routes.DAMAGE_REPORT,
      arguments: {'rentalId': rental.value!.id, 'itemId': rental.value!.itemId},
    );
  }

  // -- Timer Logic --
  void _updateTimer() {
    if (rental.value == null) return;
    final now = DateTime.now();
    final dueTime = rental.value!.expectedReturnTime;
    final difference = dueTime.difference(now);

    final colorScheme = Get.theme.colorScheme;
    final statusColors = Get.theme.extension<StatusColors>();

    if (difference.isNegative) {
      // Overdue
      timeLabel.value = "Overdue";
      timeColor.value = colorScheme.error;
      timeRemaining.value = _formatDuration(difference.abs());
    } else {
      // Time Remaining
      timeLabel.value = "Time Remaining";
      timeColor.value = statusColors?.success ?? Colors.green;
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
    final colorScheme = Get.theme.colorScheme;
    final statusColors = Get.theme.extension<StatusColors>();

    Get.defaultDialog(
      title: "Settlement Required",
      backgroundColor: colorScheme.surfaceContainer,
      titleStyle: TextStyle(color: colorScheme.onSurface),
      content: Column(
        children: [
          _summaryRow("Outstanding Rent", balanceDue),
          if (damageFee > 0) _summaryRow("Damage Fee", damageFee),
          Divider(color: colorScheme.outline),
          _summaryRow("Net Payable", finalTotal, isBold: true),
        ],
      ),
      textConfirm: actionText,
      confirmTextColor: colorScheme.onPrimary,
      buttonColor: finalTotal > 0
          ? colorScheme.primary
          : (statusColors?.warning ?? Colors.orange),
      onConfirm: () {
        _finalizeReturn(damageFee: damageFee, finalPayment: finalTotal);
      },
      textCancel: "Cancel",
      cancelTextColor: colorScheme.primary,
    );
  }

  void _finalizeReturn({
    required double damageFee,
    required double finalPayment,
  }) {
    Get.back(); // Close dialog
    Get.back(); // Close screen
    AppSnackBar.success(
      title: "Return Complete",
      message: "Rental closed. ${finalPayment != 0 ? 'Payment recorded.' : ''}",
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
