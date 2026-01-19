import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/customer_model.dart';
import '../../../services/customer_service.dart';
import '../../../services/user_service.dart';

class AddEditCustomerController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final UserService _userService = Get.find();
  final CustomerService _customerService = Get.find();

  // Text Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneController = TextEditingController();
  final nicController = TextEditingController();
  final emailController = TextEditingController();
  final notesController = TextEditingController();

  // State Variables
  final RxBool isEditMode = false.obs;
  final RxString customerId = ''.obs;

  String shopId = '0000';

  @override
  Future<void> onInit() async {
    super.onInit();
    // Check arguments to see if we are editing
    if (Get.arguments != null && Get.arguments is Map) {
      final data = Get.arguments as Map<String, dynamic>;
      isEditMode.value = true;
      customerId.value = data['id'] ?? '';

      // Populate fields
      firstNameController.text = data['first_name'] ?? '';
      lastNameController.text = data['last_name'] ?? '';
      phoneController.text = data['phone'] ?? '';
      nicController.text = data['nic'] ?? '';
      emailController.text = data['email'] ?? '';
      notesController.text = data['notes'] ?? '';
    }

    shopId = await _userService.getShopIdFromStorage() ?? '0000';
  }

  void saveCustomer() {
    if (!formKey.currentState!.validate()) return;

    final customerData = {
      "first_name": firstNameController.text.trim(),
      "last_name": lastNameController.text.trim(),
      "phone": phoneController.text.trim(),
      "nic": nicController.text.trim(),
      "email": emailController.text.trim(),
      "notes": notesController.text.trim(),
      "created_at": isEditMode.value ? null : DateTime.now().toIso8601String(),
    };

    log('Customer Data: $customerData');

    if (isEditMode.value) {
      // _customerService.updateCustomer(shopId, customerId, data)
    } else {
      _customerService.addCustomer(
        shopId,
        CustomerModel.fromJson(customerData),
      );

      Get.snackbar(
        'Customer Added',
        'Customer has been added successfully.',
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      );

      // Clear fields
      clearForm();
    }

    Get.back(); // Return to previous screen
  }

  /// Clear fields
  void clearForm() {
    firstNameController.clear();
    lastNameController.clear();
    phoneController.clear();
    nicController.clear();
    emailController.clear();
    notesController.clear();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    nicController.dispose();
    emailController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
