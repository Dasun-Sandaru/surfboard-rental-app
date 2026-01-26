import 'package:get/get.dart';
import 'package:surfboard_rental_app/utils/common/app_snack_bar.dart';
import 'package:surfboard_rental_app/app/models/customer_model.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../routes/app_pages.dart'; // Add this package for calls/emails

class CustomerDetailsController extends GetxController {
  late final Rx<CustomerModel> customer;

  @override
  void onInit() {
    super.onInit();
    // Get customer from navigation arguments
    final arg = Get.arguments;
    if (arg is CustomerModel) {
      customer = arg.obs;
    } else {
      // Create a default/placeholder customer if none provided
      customer = CustomerModel(
        id: "N/A",
        firstName: "Unknown",
        lastName: "Customer",
        phone: "N/A",
        nic: "N/A",
        email: "N/A",
        notes: "No data available",
        imageUrl: null,
        createdAt: null,
      ).obs;
    }
  }

  // Dummy History Data
  final history = <Map<String, dynamic>>[
    {
      "date": "15 Aug 2024",
      "items": "Firewire Longboard (9'0\")",
      "duration": "2 Days",
      "cost": "\$40.00",
      "status": "Returned", // Status for color coding
    },
    {
      "date": "01 Aug 2024",
      "items": "Channel Islands Fish (6'2\")",
      "duration": "1 Day",
      "cost": "\$25.00",
      "status": "Late Return",
    },
    {
      "date": "20 Jul 2024",
      "items": "Soft Top (8'0\")",
      "duration": "4 Hours",
      "cost": "\5.00",
      "status": "Returned",
    },
  ].obs;

  void editCustomer() {
    // Navigate to Edit Screen with current data
    Get.toNamed(Routes.ADD_EDIT_CUSTOMER, arguments: customer.value);
  }

  void makeCall() async {
    final Uri launchUri = Uri(scheme: 'tel', path: customer.value.phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri); // Corrected to launchUrl
    } else {
      AppSnackBar.error(title: "Error", message: "Could not launch dialer");
    }
  }

  void sendEmail() {
    AppSnackBar.info(title: "Action", message: "Opening Email App...");
  }
}
