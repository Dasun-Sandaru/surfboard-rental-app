import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AgreementTemplateController extends GetxController {
  
  final searchTextController = TextEditingController();

  // Dummy Template Data
  final RxList<Map<String, dynamic>> templates = <Map<String, dynamic>>[
    {
      "id": "1",
      "title": "Standard Daily Rental",
      "updatedAt": "Oct 26, 2023",
    },
    {
      "id": "2",
      "title": "Waiver & Liability - Minors",
      "updatedAt": "Oct 15, 2023",
    },
    {
      "id": "3",
      "title": "Group Lesson Agreement",
      "updatedAt": "Sep 30, 2023",
    },
    {
      "id": "4",
      "title": "Advanced Equipment Policy",
      "updatedAt": "Sep 12, 2023",
    },
  ].obs;

  void addTemplate() {
    Get.snackbar("Action", "Create New Template");
    // Get.toNamed('/create-template');
  }

  void editTemplate(Map<String, dynamic> template) {
    Get.snackbar("Action", "Edit ${template['title']}");
    // Get.toNamed('/edit-template', arguments: template);
  }
}