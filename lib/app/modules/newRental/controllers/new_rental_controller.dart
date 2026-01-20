import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:surfboard_rental_app/app/routes/app_pages.dart';
import '../../../models/customer_model.dart';
import '../../../models/inventory_model.dart';
import '../../../models/new_rental_pass_model.dart'; // Add intl package for date formatting

class NewRentalController extends GetxController {
  // -- State Variables --
  final Rx<CustomerModel?> selectedCustomer = Rx<CustomerModel?>(null);
  final RxList<InventoryModel> selectedItems = <InventoryModel>[].obs;

  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> dueDate = DateTime.now()
      .add(const Duration(days: 1))
      .obs; // Default 1 day

  final Rx<TimeOfDay> startTime = TimeOfDay.now().obs;
  final Rx<TimeOfDay> dueTime = TimeOfDay(
    hour: TimeOfDay.now().hour + 1,
    minute: 0,
  ).obs;

  final RxDouble estimatedTotal = 0.0.obs;

  // -- Actions --

  void selectCustomer() async {
    // Navigate to Customer List in 'selection mode'
    // You need to update your CustomerListView to handle arguments for selection
    final result = await Get.toNamed(
      Routes.CUSTOMER_LIST,
      arguments: {'selectMode': true},
    );
    if (result != null) {
      selectedCustomer.value = result;
    }
  }

  void addItem() async {
    // Only allow one item
    if (selectedItems.isNotEmpty) {
      Get.snackbar(
        "Limit Reached",
        "You can only select one item per rental",
        backgroundColor: Colors.orange.withOpacity(0.2),
        colorText: Colors.orange,
      );
      return;
    }

    // Navigate to Inventory List in 'selection mode'
    final result = await Get.toNamed(
      Routes.INVENTORY,
      arguments: {'selectMode': true},
    );
    if (result != null && result is InventoryModel) {
      // Avoid duplicates (should not happen with limit, but keeping for safety)
      if (!selectedItems.any((item) => item.id == result.id)) {
        selectedItems.add(result);
        calculateTotal();
      } else {
        Get.snackbar("Info", "Item already added");
      }
    }
  }

  void removeItem(int index) {
    selectedItems.removeAt(index);
    calculateTotal();
  }

  void pickDate(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: isStart ? startDate.value : dueDate.value,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4A90E2),
              onPrimary: Colors.white,
              surface: Color(0xFF182c30),
              onSurface: Color(0xFFf0f4f4),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStart) {
        startDate.value = picked;
        // Auto-adjust due date if it's before start
        if (dueDate.value.isBefore(picked)) {
          dueDate.value = picked.add(const Duration(days: 1));
        }
      } else {
        dueDate.value = picked;
      }
      calculateTotal();
    }
  }

  void pickTime(bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: isStart ? startTime.value : dueTime.value,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF4A90E2),
              onPrimary: Colors.white,
              surface: Color(0xFF182c30),
              onSurface: Color(0xFFf0f4f4),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      if (isStart) {
        startTime.value = picked;
      } else {
        dueTime.value = picked;
      }
      calculateTotal();
    }
  }

  void calculateTotal() {
    // Simple logic: Sum of item prices * days
    // In a real app, parse the 'cost' string to double
    // double days = endDate.value.difference(startDate.value).inDays.toDouble();
    // if (days < 1) days = 1;

    // For demo, just static calculation
    estimatedTotal.value =
        selectedItems.length * 25.0; // Dummy $25/day per item
  }

  void proceedToAgreement() {
    if (selectedCustomer.value == null) {
      Get.snackbar(
        "Missing Info",
        "Please select a customer",
        backgroundColor: Colors.red.withOpacity(0.2),
        colorText: Colors.red,
      );
      return;
    }
    if (selectedItems.isEmpty) {
      Get.snackbar(
        "Missing Info",
        "Please add at least one item",
        backgroundColor: Colors.red.withOpacity(0.2),
        colorText: Colors.red,
      );
      return;
    }

    // Create agreement data model
    final agreementData = NewRentalPassModel(
      customer: selectedCustomer.value!,
      items: selectedItems,
      startDate: startDate.value,
      startTime: startTime.value,
      dueDate: dueDate.value,
      dueTime: dueTime.value,
    );

    // Pass data model to the Agreement Wizard
    Get.toNamed(Routes.AGREEMENT_WIZARD, arguments: agreementData);
  }

  // Helper for Date Format
  String formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);
}
