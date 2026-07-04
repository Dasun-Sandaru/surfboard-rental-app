import '../../../../utils/common/app_snack_bar.dart';
import 'package:get/get.dart';
import '../../../models/payment_model.dart';
import '../../../models/rental_model.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../routes/app_pages.dart';
import '../../../services/customer_service.dart';
import '../../../services/payment_service.dart';
import '../../../services/rental_service.dart';
import '../../../services/user_service.dart';
import '../views/collect_payment_tip.dart';

class RentalPaymentController extends GetxController {
  final PaymentService paymentService = Get.find<PaymentService>();
  final RentalService rentalService = RentalService();
  final UserService userService = Get.find<UserService>();
  final CustomerService customerService = CustomerService();

  // -- Data --
  final Rx<RentalModel?> rental = Rx<RentalModel?>(null);
  final payments = <PaymentModel>[].obs;

  final customerImage = "https://via.placeholder.com/150";
  String rentalId = "";
  String shopId = "";

  // -- Getters for View --
  String get customerName =>
      rental.value?.cachedCustomerName ??
      rental.value?.customerId ??
      "Customer";

  double get damageFee => payments
      .where((p) => p.category == PaymentCategory.damageFee)
      .fold(0.0, (sum, p) => sum + p.amount);

  double get lateFee => payments
      .where((p) => p.category == PaymentCategory.lateFee)
      .fold(0.0, (sum, p) => sum + p.amount);

  // Base rental is based on the initial ledger entry
  double get rentalFee => payments
      .where((p) => p.category == PaymentCategory.rental)
      .fold(0.0, (sum, p) => sum + p.amount);

  double get depositAmount => payments
      .where((p) => p.category == PaymentCategory.deposit)
      .fold(0.0, (sum, p) => sum + p.amount);

  double get totalBalance =>
      (rental.value?.amountExpected ?? 0.0) - (rental.value?.amountPaid ?? 0.0);

  // -- Getters (Computed) --
  double get totalExpected => rental.value?.amountExpected ?? 0.0;
  double get totalPaid => rental.value?.amountPaid ?? 0.0;

  double get depositHeld {
    final deposit = rental.value?.securityDeposit;
    if (deposit != null && deposit.paid > 0 && deposit.refunded == 0) {
      return deposit.paid;
    }
    return 0.0;
  }

  double get netCashToCollect {
    double balance = totalBalance;
    return balance - depositHeld;
  }

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
    // We allow navigation even if balance is 0 or negative to finalize the rental return.
    Get.to(() => CollectPaymentTip(controller: this));
  }

  Future<void> submitRating(double rating, String comment) async {
    try {
      final customerId = rental.value?.customerId;
      if (customerId == null || shopId.isEmpty) return;

      // 1. Update Customer's overall rating
      await customerService.rateCustomer(
        shopId: shopId,
        customerId: customerId,
        rating: rating,
      );

      // 2. Save rating in the specific rental
      await rentalService.saveCustomerRating(
        shopId: shopId,
        rentalId: rentalId,
        rating: rating,
        comment: comment,
      );
    } catch (e) {
      AppSnackBar.error(title: 'rating_failed'.tr, message: e.toString());
    }
  }

  void goToCustomerDetails() {
    final customerId = rental.value?.customerId;
    if (customerId != null) {
      Get.toNamed(Routes.CUSTOMER_DETAILS, arguments: customerId);
    }
  }
}
