import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddInventoryController extends GetxController {
  // -- Form Keys & Controllers --
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final brandController = TextEditingController();
  final typeController = TextEditingController();
  final colorController = TextEditingController();
  final costController = TextEditingController();
  final volumeController = TextEditingController();
  final rentalRateController = TextEditingController();
  final rentalRateDayController = TextEditingController();
  final notesController = TextEditingController();


  // Size Controllers
  final sizeFeetController = TextEditingController();
  final sizeInchesController = TextEditingController();

  // Selected Dropdown Value
  final RxString selectedBrand = ''.obs;
  final RxString boardName =
      'Enter the details of the surfboard you want to add to your inventory.'
          .obs;

  // Dummy Brands List
  final List<String> brandList = [
    "Channel Islands",
    "Firewire",
    "Pyzel",
    "Lost",
    "JS Industries",
    "Other",
  ];

  List<String> list = ['Developer', 'Designer', 'Consultant', 'Student'];

  void saveItem() {
    if (formKey.currentState!.validate()) {
      // Logic to combine size
      String feet = sizeFeetController.text.trim();
      String inches = sizeInchesController.text.trim();

      // Default to 0 if empty
      if (feet.isEmpty) feet = "0";
      if (inches.isEmpty) inches = "0";

      final String formattedSize = "$feet' $inches\"";

      // Here you would create the Item Object and send to Firebase
      print("Saving Item: ${typeController.text} - $formattedSize");

      Get.back();
      Get.snackbar(
        "Success",
        "Inventory item added successfully",
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    }
  }

  void updateBoardName(String size, String brand, String volume, String type) {
    /// Format -: Size Brand Volume ex: 5' 9" Kelly Slater 34L Shortboard
    boardName.value = "$size $brand $volume $type";
  }

  @override
  void onClose() {
    brandController.dispose();
    typeController.dispose();
    colorController.dispose();
    costController.dispose();
    sizeFeetController.dispose();
    sizeInchesController.dispose();
    volumeController.dispose();
    rentalRateController.dispose();
    rentalRateDayController.dispose();
    notesController.dispose();
    super.onClose();
  }
}
