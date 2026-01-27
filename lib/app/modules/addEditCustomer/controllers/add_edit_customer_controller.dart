import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:surfboard_rental_app/utils/common/app_snack_bar.dart';

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
  final Rx<CustomerModel?> currentCustomer = Rx<CustomerModel?>(null);

  String? shopId;

  @override
  Future<void> onInit() async {
    super.onInit();
    // Check arguments to see if we are editing
    if (Get.arguments != null && Get.arguments is CustomerModel) {
      final customer = Get.arguments as CustomerModel;
      isEditMode.value = true;
      currentCustomer.value = customer;

      // Populate fields with customer data
      firstNameController.text = customer.firstName;
      lastNameController.text = customer.lastName;
      phoneController.text = customer.phone;
      nicController.text = customer.nic;
      emailController.text = customer.email;
      notesController.text = customer.notes;
    }

    shopId = await _userService.getShopIdFromStorage();
  }

  void saveCustomer() {
    if (!formKey.currentState!.validate()) return;

    if (shopId == null) {
      AppSnackBar.error(
        title: 'Error',
        message: 'Shop ID not found. Please restart the app.',
      );
      return;
    }

    final customer = CustomerModel(
      id: isEditMode.value ? currentCustomer.value!.id : null,
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      phone: phoneController.text.trim(),
      nic: nicController.text.trim(),
      email: emailController.text.trim(),
      notes: notesController.text.trim(),
      createdAt: isEditMode.value
          ? currentCustomer.value!.createdAt
          : DateTime.now(),
      imageUrl: isEditMode.value ? currentCustomer.value!.imageUrl : null,
    );

    log('Customer Data: ${customer.toMap()}');

    if (isEditMode.value) {
      // Update existing customer
      _customerService.updateCustomer(
        shopId!,
        currentCustomer.value!.id!,
        customer,
      );
      AppSnackBar.success(
        title: 'Customer Updated',
        message: 'Customer has been updated successfully.',
      );
    } else {
      // Add new customer
      _customerService.addCustomer(shopId!, customer);
      AppSnackBar.success(
        title: 'Customer Added',
        message: 'Customer has been added successfully.',
      );
      // Clear fields
      clearForm();
    }
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
