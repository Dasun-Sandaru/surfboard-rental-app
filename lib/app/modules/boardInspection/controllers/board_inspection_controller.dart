import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/payment_model.dart';
import '../../../routes/app_pages.dart';
import '../../../services/rental_service.dart';
import '../../../services/user_service.dart';
import '../../../services/config_service.dart';
import '../../../../utils/common/app_snack_bar.dart';

import '../../../../utils/theme/app_material_theme.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../models/rental_model.dart';

import '../../../services/payment_service.dart';

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
  final RxString timeLabel = "time_remaining".obs;
  final RxString timeRemaining = "00:00:00".obs;
  final Rx<Color> timeColor = Rx<Color>(Colors.white);

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
            log('Error listening to payments: $e');
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

  String get staffName =>
      rental.value?.cachedStaffName ?? rental.value?.staffId ?? '';

  String get customerName =>
      rental.value?.cachedCustomerName ?? rental.value?.customerId ?? '';

  String get boardName =>
      rental.value?.cachedItemName ?? rental.value?.itemId ?? '';

  double get totalPaymentsMade =>
      paymentHistory.fold(0.0, (sum, payment) => sum + payment.amount);

  // --- Actions ---
  Future<void> reportNoDamage() async {
    final r = rental.value;
    if (r == null) return;

    double calculatedLateFee = 0;

    // 1. Check if overdue
    if (timeLabel.value == "overdue") {
      final now = DateTime.now();
      final difference = r.expectedReturnTime.difference(now).abs();

      bool applyLateFee = false;
      final configService = Get.isRegistered<ConfigService>() ? Get.find<ConfigService>() : null;
      final hourlyGrace = configService?.hourlyGracePeriodMinutes.value ?? 15;
      final dailyGrace = configService?.dailyGracePeriodHours.value ?? 1;

      // Calculation logic based on rentType
      if (r.rentType == RentType.hourly) {
        if (difference.inMinutes > hourlyGrace) {
          applyLateFee = true;
          // Round up to next full hour
          final hours = (difference.inMinutes / 60).ceil();
          calculatedLateFee = hours * r.rate;
        }
      } else {
        if (difference.inHours > dailyGrace) {
          applyLateFee = true;
          // Daily: Round up to next full day
          final days = (difference.inHours / 24).ceil();
          calculatedLateFee = days * r.rate;
        }
      }

      // 2. Save Late Fee if > 0
      if (applyLateFee && calculatedLateFee > 0) {
        final currentStaffId = _userService.currentUser?.uid ?? 'System';
        final shopId = await _userService.getShopIdFromStorage();
        if (shopId != null) {
          await _rentalService.addLateFeeCharge(
            shopId: shopId,
            rentalId: r.id!,
            amount: calculatedLateFee,
            handledBy: currentStaffId,
          );
        }
      }
    }

    // 3. Finalize Return (Updates Status to item_returned)
    await _finalizeReturn(
      damageFee: 0,
      finalPayment: 0,
      status: RentalStatus.item_returned,
    );

    // 4. Navigate to Rental Payment Screen
    // We use offAllNamed or similar to ensure we start fresh on the payments flow
    Get.offAllNamed(
      Routes.PAYMENTS,
      arguments: {'rentalId': r.id, 'shopId': r.shopId},
    );
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
      timeLabel.value = "overdue";
      timeColor.value = colorScheme.error;
      timeRemaining.value = _formatDuration(difference.abs());
    } else {
      // Time Remaining
      timeLabel.value = "time_remaining";
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
  // void _showSettlementDialog({required double damageFee}) {
  //   double finalTotal = balanceDue + damageFee;
  //   String actionText = finalTotal > 0 ? "Collect Payment" : "Refund Customer";
  //   final colorScheme = Get.theme.colorScheme;
  //   final statusColors = Get.theme.extension<StatusColors>();

  //   Get.defaultDialog(
  //     title: "Settlement Required",
  //     backgroundColor: colorScheme.surfaceContainer,
  //     titleStyle: TextStyle(color: colorScheme.onSurface),
  //     content: Column(
  //       children: [
  //         _summaryRow("Outstanding Rent", balanceDue),
  //         if (damageFee > 0) _summaryRow("Damage Fee", damageFee),
  //         Divider(color: colorScheme.outline),
  //         _summaryRow("Net Payable", finalTotal, isBold: true),
  //       ],
  //     ),
  //     textConfirm: actionText,
  //     confirmTextColor: colorScheme.onPrimary,
  //     buttonColor: finalTotal > 0
  //         ? colorScheme.primary
  //         : (statusColors?.warning ?? Colors.orange),
  //     onConfirm: () {
  //       _finalizeReturn(damageFee: damageFee, finalPayment: finalTotal);
  //     },
  //     textCancel: "Cancel",
  //     cancelTextColor: colorScheme.primary,
  //   );
  // }

  Future<void> _finalizeReturn({
    required double damageFee,
    required double finalPayment,
    RentalStatus status = RentalStatus.item_returned,
  }) async {
    try {
      final String? shopId = await _userService.getShopIdFromStorage();
      if (shopId == null || rental.value == null) return;

      // Only save overdue time if it's actually overdue
      String? overdueString;
      if (timeLabel.value == "overdue") {
        overdueString = timeRemaining.value;
      }

      await _rentalService.finalizeReturn(
        shopId: shopId,
        rentalId: rentalId,
        itemId: rental.value!.itemId,
        status: status,
        overdueTime: overdueString,
      );

      AppSnackBar.success(
        title: "Return Complete",
        message:
            "Rental closed. ${finalPayment != 0 ? 'Payment recorded.' : ''}",
      );
    } catch (e) {
      AppSnackBar.error(
        title: "Error",
        message: "Failed to finalize return: $e",
      );
    }
  }

  // Widget _summaryRow(String label, double amount, {bool isBold = false}) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 4.0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //       children: [
  //         Text(label, style: const TextStyle(color: Colors.grey)),
  //         Text(
  //           "\$${amount.abs().toStringAsFixed(2)}",
  //           style: TextStyle(
  //             color: Colors.white,
  //             fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
