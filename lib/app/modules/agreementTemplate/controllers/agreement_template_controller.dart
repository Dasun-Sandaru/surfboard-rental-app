import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:surfboard_rental_app/app/modules/agreementTemplate/views/add_edit_agreement_template_view.dart';
import 'package:surfboard_rental_app/utils/common/app_dialogs.dart';

import '../../../models/agreement_template_model.dart';
import '../../../services/agreement_template_service.dart';
import '../../../services/user_service.dart';

class AgreementTemplateController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final UserService _userService = Get.find();
  final AgreementTemplateService _templateService = AgreementTemplateService();
  final searchTextController = TextEditingController();
  final templateNameController = TextEditingController();
  final contentController = TextEditingController();

  final isEditing = false.obs;
  final isLoading = false.obs;
  final _editedTemplate = Rx<AgreementTemplateModel?>(null);

  final RxList<AgreementTemplateModel> templates =
      <AgreementTemplateModel>[].obs;
  String? shopId;

  @override
  Future<void> onInit() async {
    super.onInit();
    isLoading.value = true;
    shopId = await _userService.getShopIdFromStorage();
    if (shopId != null) {
      await fetchTemplates();
    }
    isLoading.value = false;
  }

  Future<void> fetchTemplates() async {
    if (shopId == null) return;
    isLoading.value = true;
    try {
      final fetchedTemplates = await _templateService.getShopTemplates(shopId!);
      templates.assignAll(fetchedTemplates);
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch templates.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void addTemplate() {
    isEditing.value = false;
    _editedTemplate.value = null;
    templateNameController.clear();
    contentController.clear();
    Get.to(() => const AddEditAgreementTemplateView());
  }

  void editTemplate(AgreementTemplateModel template) {
    isEditing.value = true;
    _editedTemplate.value = template;
    templateNameController.text = template.templateName;
    // Assuming 'content' is the key for the main section.
    // This might need adjustment based on your data structure.
    contentController.text = template.sections['content'] ?? '';
    Get.to(() => const AddEditAgreementTemplateView());
  }

  Future<void> saveTemplate() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        final sections = {'content': contentController.text};
        if (isEditing.value && _editedTemplate.value != null) {
          // Update existing template
          await _templateService.updateTemplate(
            shopId: shopId!,
            templateId: _editedTemplate.value!.id!,
            templateName: templateNameController.text,
            sections: sections,
          );
        } else {
          // Add new template
          await _templateService.createTemplate(
            shopId: shopId!,
            templateName: templateNameController.text,
            sections: sections,
          );
        }
        await fetchTemplates(); // Refresh the list
        Get.back(); // Go back to the list view
        Get.snackbar(
          "Success",
          "Template saved successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        Get.snackbar(
          "Error",
          "Failed to save template.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  void previewTemplate() {
    // 1. Create sample data
    final customer = {"name": "John Doe", "email": "john.doe@example.com"};
    final rental = {
      "startDate": DateFormat('MMM dd, yyyy').format(DateTime.now()),
      "endDate": DateFormat(
        'MMM dd, yyyy',
      ).format(DateTime.now().add(const Duration(days: 3))),
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
        style: const TextStyle(fontSize: 14),
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

  void addDefaultTemplate() {
    AgreementTemplateService agreementTemplateService =
        AgreementTemplateService();
    agreementTemplateService.createDefaultTemplate(shopId!);
  }
}
