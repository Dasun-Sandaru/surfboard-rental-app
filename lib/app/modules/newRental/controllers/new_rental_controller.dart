import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Add intl package for date formatting

class NewRentalController extends GetxController {
  
  // -- State Variables --
  final Rx<Map<String, dynamic>?> selectedCustomer = Rx<Map<String, dynamic>?>(null);
  final RxList<Map<String, dynamic>> selectedItems = <Map<String, dynamic>>[].obs;
  
  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> endDate = DateTime.now().add(const Duration(days: 1)).obs; // Default 1 day
  
  final RxDouble estimatedTotal = 0.0.obs;

  // -- Actions --

  void selectCustomer() async {
    // Navigate to Customer List in 'selection mode'
    // You need to update your CustomerListView to handle arguments for selection
    final result = await Get.toNamed('/customers', arguments: {'selectMode': true});
    if (result != null) {
      selectedCustomer.value = result;
    }
  }

  void addItem() async {
    // Navigate to Inventory List in 'selection mode'
    final result = await Get.toNamed('/inventory', arguments: {'selectMode': true});
    if (result != null) {
      // Avoid duplicates
      if (!selectedItems.any((item) => item['id'] == result['id'])) {
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
      initialDate: isStart ? startDate.value : endDate.value,
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
        // Auto-adjust end date if it's before start
        if (endDate.value.isBefore(picked)) {
          endDate.value = picked.add(const Duration(days: 1));
        }
      } else {
        endDate.value = picked;
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
    estimatedTotal.value = selectedItems.length * 25.0; // Dummy $25/day per item
  }

  void proceedToAgreement() {
    if (selectedCustomer.value == null) {
      Get.snackbar("Missing Info", "Please select a customer", backgroundColor: Colors.red.withOpacity(0.2), colorText: Colors.red);
      return;
    }
    if (selectedItems.isEmpty) {
      Get.snackbar("Missing Info", "Please add at least one item", backgroundColor: Colors.red.withOpacity(0.2), colorText: Colors.red);
      return;
    }

    // Pass data to the Agreement Wizard
    Get.toNamed('/agreement-wizard', arguments: {
      'customer': selectedCustomer.value,
      'items': selectedItems,
      'startDate': startDate.value,
      'endDate': endDate.value,
    });
  }

  // Helper for Date Format
  String formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);
}
