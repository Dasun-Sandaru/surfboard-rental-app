import 'package:flutter/material.dart';
import 'package:surfboard_rental_app/utils/common/app_snack_bar.dart';
import 'package:get/get.dart';
import '../../../models/payment_model.dart';
import '../../../models/rental_model.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../services/payment_service.dart';
import '../../../services/rental_service.dart';
import '../../../services/user_service.dart';
import '../views/collect_payment_tip.dart';

class RentalPaymentController extends GetxController {
  final PaymentService paymentService = Get.find<PaymentService>();
  final RentalService rentalService = RentalService();
  final UserService userService = Get.find<UserService>();

  // -- Data --
  final Rx<RentalModel?> rental = Rx<RentalModel?>(null);
  final payments = <PaymentModel>[].obs;

  final customerImage = "https://via.placeholder.com/150";
  String rentalId = "";
  String shopId = "";

  // -- Getters for View --
  String get customerName => rental.value?.customerId ?? "Customer";

  double get damageFeeValue => payments
      .where((p) => p.category == PaymentCategory.damageFee)
      .fold(0.0, (sum, p) => sum + p.amount);

  double get lateFeeValue => payments
      .where((p) => p.category == PaymentCategory.lateFee)
      .fold(0.0, (sum, p) => sum + p.amount);

  double get totalBalance =>
      (rental.value?.amountExpected ?? 0.0) - (rental.value?.amountPaid ?? 0.0);

  // "Remaining Rental Fee" is assumed to be the Balance minus specific fees like damage/late
  // If balance < 0, it wraps to 0.
  double get rentalFeeValue {
    double base = totalBalance - damageFeeValue - lateFeeValue;
    return base < 0 ? 0 : base;
  }

  // Expose obs for View compatibility if needed, or update View to use getters
  // For now, I'll keep the View's .value access pattern by using computed Rx properties or updating View.
  // View uses property.value. Let's provide Getters that return simple doubles,
  // and update View to simple property access (removed .value), OR return RxDouble.
  // It's cleaner to update View. But here I will return Rx wrapper to minimize View changes if I can.
  // Actually, View uses `controller.rentalFee.value`.
  // I will make these non-Rx getters and update View locally or use simple Obx in View.
  // Let's use Rx wrappers to match current View access.

  // -- Getters (Computed) --
  // These return the primitive value.
  // Accessing them inside an Obx() in the View will trigger updates
  // because they depend on 'payments' and 'rental' observable variables.

  double get rentalFee => rentalFeeValue;
  double get lateFee => lateFeeValue;
  double get damageFee => damageFeeValue;
  double get totalAmount => totalBalance;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final args = Get.arguments as Map<String, dynamic>;
      if (args['rentalId'] != null) rentalId = args['rentalId'];
      if (args['shopId'] != null) shopId = args['shopId'];
    }

    if (shopId.isNotEmpty && rentalId.isNotEmpty) {
      // Stream Payments
      payments.bindStream(paymentService.paymentStream(shopId, rentalId));

      // Stream Rental
      rental.bindStream(rentalService.streamRentalById(shopId, rentalId));
    }
  }

  Future<void> collectPayment() async {
    if (totalBalance <= 0) {
      AppSnackBar.info(title: "Info", message: "No balance to collect.");
      return;
    }

    Get.to(CollectPaymentTip(controller: this));
  }
}
