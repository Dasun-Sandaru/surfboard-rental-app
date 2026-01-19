import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_pages.dart';

class CustomerListController extends GetxController {
  final searchTextController = TextEditingController();

  // Dummy Customer Data
  final RxList<Map<String, dynamic>> customers = <Map<String, dynamic>>[
    {
      "name": "Kai Smith",
      "phone": "(808) 555-0123",
      "lastRental": "08/15/2024",
      "imageUrl": "https://via.placeholder.com/150",
    },
    {
      "name": "Malia Johnson",
      "phone": "(808) 555-0456",
      "lastRental": "08/14/2024",
      "imageUrl": "https://via.placeholder.com/150",
    },
    {
      "name": "Kekoa Williams",
      "phone": "(808) 555-0789",
      "lastRental": "08/12/2024",
      "imageUrl": "https://via.placeholder.com/150",
    },
    {
      "name": "Leilani Davis",
      "phone": "(808) 555-0234",
      "lastRental": "08/11/2024",
      "imageUrl": "https://via.placeholder.com/150",
    },
    {
      "name": "Noah Brown",
      "phone": "(808) 555-0567",
      "lastRental": "08/10/2024",
      "imageUrl": "https://via.placeholder.com/150",
    },
  ].obs;

  void addCustomer() {
    // Get.snackbar("Action", "Add Customer clicked");
    Get.toNamed(Routes.ADD_EDIT_CUSTOMER);
  }

  void openCustomerDetails(Map<String, dynamic> customer) {
    // Get.snackbar("Action", "Opened ${customer['name']}");
    Get.toNamed(Routes.CUSTOMER_DETAILS, arguments: customer);
  }
}
