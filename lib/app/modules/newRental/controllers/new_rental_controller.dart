import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/app/services/customer_service.dart';
import 'package:surfboard_rental_app/app/services/inventory_service.dart';
import 'package:surfboard_rental_app/app/services/user_service.dart';
import 'package:surfboard_rental_app/utils/common/app_snack_bar.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:surfboard_rental_app/app/routes/app_pages.dart';
import 'package:surfboard_rental_app/utils/constants/a_enums.dart';
import '../../../models/customer_model.dart';
import '../../../models/inventory_model.dart';
import '../../../models/init_rental_model.dart';

class NewRentalController extends GetxController {
  // -- State Variables --
  final Rx<CustomerModel?> selectedCustomer = Rx<CustomerModel?>(null);
  final RxList<InventoryModel> selectedItems = <InventoryModel>[].obs;

  final Rx<DateTime> startDate = DateTime.now().obs;
  final Rx<DateTime> dueDate = DateTime.now().obs;

  final Rx<TimeOfDay> startTime = TimeOfDay.now().obs;
  final Rx<TimeOfDay> dueTime = TimeOfDay(
    hour: TimeOfDay.now().hour + 1,
    minute: 0,
  ).obs;
  final Rx<RentType> rentType = RentType.hourly.obs;

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
      AppSnackBar.warning(
        title: "Limit Reached",
        message: "You can only select one item per rental",
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
        AppSnackBar.info(title: "Info", message: "Item already added");
      }
    }
  }

  void removeItem(int index) {
    selectedItems.removeAt(index);
    calculateTotal();
  }

  void scanCustomer() async {
    final result = await Get.toNamed(
      Routes.QR_SCANNER,
      arguments: {'returnResult': true},
    );
    if (result != null && result is String) {
      _handleScannedData(result, isCustomer: true);
    }
  }

  void scanItem() async {
    // Only allow one item
    if (selectedItems.isNotEmpty) {
      AppSnackBar.warning(
        title: "Limit Reached",
        message: "You can only select one item per rental",
      );
      return;
    }

    final result = await Get.toNamed(
      Routes.QR_SCANNER,
      arguments: {'returnResult': true},
    );
    if (result != null && result is String) {
      _handleScannedData(result, isCustomer: false);
    }
  }

  Future<void> _handleScannedData(
    String scannedData, {
    required bool isCustomer,
  }) async {
    try {
      final parts = scannedData.split(':');
      if (parts.length < 2) {
        // Try legacy/direct ID
        if (isCustomer) {
          await _fetchAndSetCustomer(scannedData);
        } else {
          await _fetchAndSetItem(scannedData);
        }
        return;
      }

      final type = parts[0].toUpperCase();
      final id = parts[1];

      if (isCustomer) {
        if (type == 'CUST' || type == 'C') {
          await _fetchAndSetCustomer(id);
        } else {
          AppSnackBar.error(
            title: "Invalid Code",
            message: "This QR code is not for a customer.",
          );
        }
      } else {
        if (type == 'ITEM' || type == 'I') {
          await _fetchAndSetItem(id);
        } else {
          AppSnackBar.error(
            title: "Invalid Code",
            message: "This QR code is not for an inventory item.",
          );
        }
      }
    } catch (e) {
      log("Error handling scanned data: $e");
      AppSnackBar.error(title: "Error", message: "Failed to process QR code");
    }
  }

  Future<void> _fetchAndSetCustomer(String id) async {
    // Need customer service to fetch customer by ID
    // Assuming you have access to a CustomerService or similar
    final CustomerService customerService = Get.find();
    final UserService userService = Get.find();
    final shopId = await userService.getShopIdFromStorage();

    if (shopId != null) {
      final doc = await customerService.getCustomerOnce(shopId, id);
      if (doc.exists) {
        selectedCustomer.value = CustomerModel.fromSnapshot(
          doc as DocumentSnapshot<Map<String, dynamic>>,
        );
        AppSnackBar.success(
          title: "Customer Added",
          message: "${selectedCustomer.value!.firstName} elected",
        );
      } else {
        AppSnackBar.warning(title: "Not Found", message: "Customer not found");
      }
    }
  }

  Future<void> _fetchAndSetItem(String id) async {
    // Need inventory service
    final InventoryService inventoryService = InventoryService();
    final UserService userService = Get.find();
    final shopId = await userService.getShopIdFromStorage();

    if (shopId != null) {
      final doc = await inventoryService.getInventoryItemOnce(
        shopId: shopId,
        itemId: id,
      );
      if (doc.exists) {
        final item = InventoryModel.fromSnapshot(
          doc as DocumentSnapshot<Map<String, dynamic>>,
        );
        if (!selectedItems.any((i) => i.id == item.id)) {
          selectedItems.add(item);
          calculateTotal();
          AppSnackBar.success(
            title: "Item Added",
            message: "${item.name} added",
          );
        } else {
          AppSnackBar.info(title: "Info", message: "Item already added");
        }
      } else {
        AppSnackBar.warning(title: "Not Found", message: "Item not found");
      }
    }
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
    try {
      if (selectedItems.isEmpty) {
        estimatedTotal.value = 0.0;
        return;
      }

      final item = selectedItems.first;
      final double dailyRate = item.rentalRateDay.toDouble();
      final double hourlyRate = item.rentalRateHour.toDouble();

      final startDateTime = DateTime(
        startDate.value.year,
        startDate.value.month,
        startDate.value.day,
        startTime.value.hour,
        startTime.value.minute,
      );

      final dueDateTime = DateTime(
        dueDate.value.year,
        dueDate.value.month,
        dueDate.value.day,
        dueTime.value.hour,
        dueTime.value.minute,
      );

      if (dueDateTime.isBefore(startDateTime) || dueDateTime == startDateTime) {
        estimatedTotal.value = 0.0;
        return;
      }

      final Duration difference = dueDateTime.difference(startDateTime);
      if (rentType.value == RentType.hourly) {
        final int hours = difference.inHours;
        final int minutes = difference.inMinutes % 60;
        double total = (hours * hourlyRate).toDouble();
        if (minutes > 0) {
          total += hourlyRate;
        }
        estimatedTotal.value = total;
      } else {
        final int days = difference.inDays;
        int hours = difference.inHours % 24;
        final int minutes = difference.inMinutes % 60;
        if (minutes > 0) {
          hours++;
        }
        double total = (days * dailyRate).toDouble();
        double remainingHoursCost = (hours * hourlyRate).toDouble();

        if (remainingHoursCost > dailyRate) {
          total += dailyRate;
        } else {
          total += remainingHoursCost;
        }
        estimatedTotal.value = total;
      }

      log('Estimated Total Rental: \$${estimatedTotal.value}');
    } catch (e, stackTrace) {
      log('Error in calculateTotal: $e', error: e, stackTrace: stackTrace);
      AppSnackBar.error(
        title: 'Calculation Error',
        message: 'Could not calculate the total rental cost.',
      );
      estimatedTotal.value = 0.0;
    }
  }

  void proceedToAgreement() {
    if (selectedCustomer.value == null) {
      AppSnackBar.error(
        title: "Missing Info",
        message: "Please select a customer",
      );
      return;
    }
    if (selectedItems.isEmpty) {
      AppSnackBar.error(
        title: "Missing Info",
        message: "Please add at least one item",
      );
      return;
    }

    // Create agreement data model
    final agreementData = InitRentalModel(
      customer: selectedCustomer.value!,
      items: selectedItems,
      startDate: startDate.value,
      startTime: startTime.value,
      dueDate: dueDate.value,
      dueTime: dueTime.value,
      rentType: rentType.value,
    );

    // Pass data model to the Agreement Wizard
    Get.toNamed(Routes.AGREEMENT_WIZARD, arguments: agreementData);
  }

  // Helper for Date Format
  String formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);
}
