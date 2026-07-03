import 'package:get/get.dart';
import '../../../../utils/common/app_snack_bar.dart';
import '../../../models/customer_model.dart';
import '../../../services/customer_service.dart';
import '../../../services/user_service.dart';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../data/firestore/firestore_collections.dart';
import '../../../../data/firestore/firestore_fields.dart';
import '../../../models/rental_model.dart';
import '../../../services/firestore_usage_service.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../routes/app_pages.dart';
import '../widgets/customer_qr_code_dialog.dart';

class CustomerDetailsController extends GetxController {
  final CustomerService _customerService = CustomerService();
  final UserService _userService = Get.find();

  final Rx<CustomerModel?> customer = Rx<CustomerModel?>(null);
  final RxBool isLoading = true.obs;
  String? shopId;

  @override
  void onInit() {
    super.onInit();
    _loadCustomer();
  }

  Future<void> _loadCustomer() async {
    try {
      isLoading.value = true;
      final args = Get.arguments;
      if (args == null) {
        throw Exception('No customer data provided');
      }

      shopId = await _userService.getShopIdFromStorage();
      if (shopId == null) {
        throw Exception('Shop ID not found');
      }

      if (args is CustomerModel) {
        // Full customer model passed
        customer.value = args;
      } else if (args is String) {
        // Customer ID passed - fetch from Firestore
        final doc = await _customerService.getCustomerOnce(shopId!, args);
        if (!doc.exists) {
          throw Exception('Customer not found');
        }
        customer.value = CustomerModel.fromJson(
          doc.data() as Map<String, dynamic>,
        );
      } else {
        throw Exception('Invalid argument type');
      }
    } catch (e) {
      AppSnackBar.error(title: 'Error', message: 'Failed to load customer: $e');
      Get.back();
    } finally {
      isLoading.value = false;
      if (customer.value != null) {
        _loadRentals();
      }
    }
  }

  final RxList<RentalModel> recentRentals = <RentalModel>[].obs;
  final RxBool isLoadingRentals = false.obs;

  Future<void> _loadRentals() async {
    if (customer.value == null || shopId == null) return;

    try {
      isLoadingRentals.value = true;
      final db = FirebaseFirestore.instance;
      final snapshot = await db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.rentals)
          .where(FirestoreFields.customerId, isEqualTo: customer.value!.id)
          .orderBy(FirestoreFields.createdAt, descending: true)
          .limit(3)
          .get();

      FirestoreUsageService.to.trackQuerySnapshot(snapshot);

      recentRentals.value = snapshot.docs
          .map((doc) => RentalModel.fromSnapshot(doc))
          .toList();
    } catch (e) {
      log('Error loading customer rentals: $e');
    } finally {
      isLoadingRentals.value = false;
    }
  }

  void editCustomer() async {
    if (customer.value == null) return;
    // Navigate to Edit Screen and wait for result
    final result = await Get.toNamed(
      Routes.ADD_EDIT_CUSTOMER,
      arguments: customer.value,
    );

    // If we got an updated customer back, refresh our local state
    if (result != null && result is CustomerModel) {
      customer.value = result;
    }
  }

  void makeCall() async {
    if (customer.value == null) return;
    final Uri launchUri = Uri(scheme: 'tel', path: customer.value!.phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      AppSnackBar.error(title: "Error", message: "Could not launch dialer");
    }
  }

  void sendMessage() async {
    if (customer.value == null) return;
    final Uri launchUri = Uri(scheme: 'sms', path: customer.value!.phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      AppSnackBar.error(title: "Error", message: "Could not launch SMS app");
    }
  }

  void sendEmail() async {
    if (customer.value == null || customer.value!.email.isEmpty) {
      AppSnackBar.warning(title: "Warning", message: "Customer has no email address");
      return;
    }
    final Uri launchUri = Uri(scheme: 'mailto', path: customer.value!.email);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      AppSnackBar.error(title: "Error", message: "Could not launch Email app");
    }
  }

  void showQR() {
    if (customer.value == null) return;

    Get.dialog(
      CustomerQrCodeDialog(customer: customer.value!),
      barrierDismissible: true,
    );
  }
}
