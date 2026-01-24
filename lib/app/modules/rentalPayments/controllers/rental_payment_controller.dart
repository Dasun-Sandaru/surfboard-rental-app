import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/payment_model.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../services/payment_service.dart';

class RentalPaymentController extends GetxController {
  final PaymentService _paymentService = Get.find<PaymentService>();
  // -- Dummy Data from previous steps --
  final rentalFee = 25.00.obs;
  final lateFee = 10.00.obs;
  final damageFee = 50.00.obs; // Passed from Inspection Screen

  final customerName = "John Doe";
  String rentalId = "";
  final customerImage = "https://via.placeholder.com/150";

  final payments = <PaymentModel>[].obs;

  // -- Computed Total --
  double get totalAmount => rentalFee.value + lateFee.value + damageFee.value;

  // -- Data from Arguments --
  String shopId = "";

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments != null && Get.arguments is Map<String, dynamic>) {
      final args = Get.arguments as Map<String, dynamic>;
      if (args['rentalId'] != null) {
        rentalId = args['rentalId'];
      }
      if (args['shopId'] != null) {
        shopId = args['shopId'];
      }
      if (args['damageFee'] != null) {
        damageFee.value = (args['damageFee'] as num).toDouble();
      }
    }

    // Clear dummy data
    payments.clear();

    // Bind stream
    if (shopId.isNotEmpty && rentalId.isNotEmpty) {
      payments.bindStream(_paymentService.paymentStream(shopId, rentalId));
    }
  }

  void collectPayment() {
    Get.defaultDialog(
      title: "Confirm Payment",
      middleText: "Process payment of \$${totalAmount.toStringAsFixed(2)}?",
      textConfirm: "Confirm",
      textCancel: "Cancel",
      confirmTextColor: Colors.white,
      onConfirm: () {
        // Payment Logic (Stripe, Cash Log, etc.)
        Get.back(); // Close Dialog
        Get.back(); // Close Payment Screen
        Get.back(); // Close Inspection Screen
        Get.snackbar(
          "Success",
          "Payment collected & Rental Closed",
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      },
    );
  }
}
