import 'package:get/get.dart';
import '../../../../utils/common/app_snack_bar.dart';
import '../../../models/customer_model.dart';
import '../../../services/customer_service.dart';
import '../../../services/user_service.dart';
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
    }
  }

  // Dummy History Data
  final history = <Map<String, dynamic>>[
    {
      "date": "15 Aug 2024",
      "items": "Firewire Longboard (9'0\")",
      "duration": "2 Days",
      "cost": "\$40.00",
      "status": "returned_label", // Status for color coding
    },
    {
      "date": "01 Aug 2024",
      "items": "Channel Islands Fish (6'2\")",
      "duration": "1 Day",
      "cost": "\$25.00",
      "status": "late_return",
    },
    {
      "date": "20 Jul 2024",
      "items": "Soft Top (8'0\")",
      "duration": "4 Hours",
      "cost": "5.00",
      "status": "returned_label",
    },
  ].obs;

  void editCustomer() {
    if (customer.value == null) return;
    // Navigate to Edit Screen with current data
    Get.toNamed(Routes.ADD_EDIT_CUSTOMER, arguments: customer.value);
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

  void sendEmail() {
    AppSnackBar.info(title: "Action", message: "Opening Email App...");
  }

  void showQR() {
    if (customer.value == null) return;

    Get.dialog(
      CustomerQrCodeDialog(customer: customer.value!),
      barrierDismissible: true,
    );
  }
}