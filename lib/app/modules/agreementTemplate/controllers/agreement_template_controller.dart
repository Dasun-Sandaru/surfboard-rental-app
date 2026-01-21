import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:surfboard_rental_app/app/modules/agreementTemplate/views/add_edit_agreement_template_view.dart';
import 'package:surfboard_rental_app/utils/common/app_dialogs.dart';

class AgreementTemplateController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final searchTextController = TextEditingController();
  final templateNameController = TextEditingController();
  final contentController = TextEditingController();

  final isEditing = false.obs;
  final _editedTemplate = Rx<Map<String, dynamic>>({});

  // Dummy Template Data
  final RxList<Map<String, dynamic>> templates = <Map<String, dynamic>>[
    {
      "id": "1",
      "templateName": "Standard Daily Rental",
      "sections": {"content": "This is the content for Standard Daily Rental."},
      "updatedAt": "Oct 26, 2023",
    },
    {
      "id": "2",
      "templateName": "Waiver & Liability - Minors",
      "sections": {
        "content": "This is the content for Waiver & Liability - Minors."
      },
      "updatedAt": "Oct 15, 2023",
    },
    {
      "id": "3",
      "templateName": "Group Lesson Agreement",
      "sections": {"content": "This is the content for Group Lesson Agreement."},
      "updatedAt": "Sep 30, 2023",
    },
    {
      "id": "4",
      "templateName": "Advanced Equipment Policy",
      "sections": {"content": "This is the content for Advanced Equipment Policy."},
      "updatedAt": "Sep 12, 2023",
    },
  ].obs;

  void addTemplate() {
    isEditing.value = false;
    _editedTemplate.value = {};
    templateNameController.clear();
    contentController.clear();
    Get.to(() => const AddEditAgreementTemplateView());
  }

  void editTemplate(Map<String, dynamic> template) {
    isEditing.value = true;
    _editedTemplate.value = template;
    templateNameController.text = template['templateName'];
    contentController.text = template['sections']['content'];
    Get.to(() => const AddEditAgreementTemplateView());
  }

  void saveTemplate() {
    if (formKey.currentState!.validate()) {
      if (isEditing.value) {
        // Update existing template
        final index = templates
            .indexWhere((t) => t['id'] == _editedTemplate.value['id']);
        if (index != -1) {
          templates[index] = {
            "id": _editedTemplate.value['id'],
            "templateName": templateNameController.text,
            "sections": {"content": contentController.text},
            "updatedAt": "Nov 03, 2023", // Ideally use a date formatter
          };
        }
      } else {
        // Add new template
        templates.add({
          "id": (templates.length + 1).toString(),
          "templateName": templateNameController.text,
          "sections": {"content": contentController.text},
          "updatedAt": "Nov 03, 2023", // Ideally use a date formatter
        });
      }
      templates.refresh();
      Get.back(); // Go back to the list view
      Get.snackbar(
        "Success",
        "Template saved successfully!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  void previewTemplate() {
    // 1. Create sample data
    final customer = {
      "name": "John Doe",
      "email": "john.doe@example.com",
    };
    final rental = {
      "startDate": DateFormat('MMM dd, yyyy').format(DateTime.now()),
      "endDate": DateFormat('MMM dd, yyyy')
          .format(DateTime.now().add(const Duration(days: 3))),
      "totalCost": "150.00",
    };

    // 2. Get the template content
    String content = contentController.text;

    // 3. Replace placeholders
    content = content.replaceAll('{{customer.name}}', customer['name']!);
    content = content.replaceAll('{{customer.email}}', customer['email']!);
    content = content.replaceAll('{{rental.startDate}}', rental['startDate']!);
    content = content.replaceAll('{{rental.endDate}}', rental['endDate']!);
    content = content.replaceAll('{{rental.totalCost}}', rental['totalCost']!);

    // 4. Show the preview dialog
    AppDialogs.defaultDialog(
      context: Get.context!,
      title: "Template Preview",
      contentWidget: Text(
        content,
        style: const TextStyle(color: textGrey, fontSize: 14),
      ),
      confirmText: "Close",
      onConfirm: () => Get.back(),
    );
  }

  @override
  void onClose() {
    searchTextController.dispose();
    templateNameController.dispose();
    contentController.dispose();
    super.onClose();
  }
}