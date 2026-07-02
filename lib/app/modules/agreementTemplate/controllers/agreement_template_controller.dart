import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/helper/a_formatter.dart';
import '../views/add_edit_agreement_template_view.dart';
import '../views/agreement_preview_view.dart';
import '../../../../data/firestore/firestore_fields.dart';
import '../../../../utils/common/app_snack_bar.dart';

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
  final RxList<AgreementTemplateModel> filteredTemplates =
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
    searchTextController.addListener(_filterTemplates);
    isLoading.value = false;
  }

  Future<void> fetchTemplates() async {
    if (shopId == null) return;
    isLoading.value = true;
    try {
      final fetchedTemplates = await _templateService.getShopTemplates(shopId!);
      templates.assignAll(fetchedTemplates);
      _filterTemplates();
    } catch (e) {
      AppSnackBar.error(title: "Error", message: "Failed to fetch templates.");
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
        AppSnackBar.success(
          title: "Success",
          message: "Template saved successfully!",
        );
      } catch (e) {
        AppSnackBar.error(title: "Error", message: "Failed to save template.");
      } finally {
        isLoading.value = false;
      }
    }
  }

  void previewTemplate() {
    // 1. Create sample data
    final customer = {
      FirestoreFields.name: "John Doe",
      FirestoreFields.email: "john.doe@example.com",
    };
    final rental = {
      "startDate": AFormatter.formatDate(DateTime.now()),
      "endDate": AFormatter.formatDate(
        DateTime.now().add(const Duration(days: 3)),
      ),
      "totalCost": "150.00",
    };

    // 2. Get the template content
    String content = contentController.text;

    // 3. Replace placeholders
    content = content.replaceAll(
      '{{customer.name}}',
      customer[FirestoreFields.name]!,
    );
    content = content.replaceAll(
      '{{customer.email}}',
      customer[FirestoreFields.email]!,
    );
    content = content.replaceAll('{{rental.startDate}}', rental['startDate']!);
    content = content.replaceAll('{{rental.endDate}}', rental['endDate']!);
    content = content.replaceAll('{{rental.totalCost}}', rental['totalCost']!);

    // 4. Navigate to preview screen
    Get.to(() => const AgreementPreviewView(), arguments: content);
  }

  void _filterTemplates() {
    final query = searchTextController.text.toLowerCase();
    if (query.isEmpty) {
      filteredTemplates.assignAll(templates);
    } else {
      filteredTemplates.assignAll(
        templates.where((t) => t.templateName.toLowerCase().contains(query)),
      );
    }
  }

  @override
  void onClose() {
    searchTextController.dispose();
    templateNameController.dispose();
    contentController.dispose();
    super.onClose();
  }

  final List<String> availablePlaceholders = [
    '{{customer.name}}',
    '{{customer.email}}',
    '{{customer.phone}}',
    '{{customer.passport}}',
    '{{rental.date}}',
    '{{rental.startTime}}',
    '{{rental.returnTime}}',
    '{{rental.item}}',
    '{{rental.rate}}',
    '{{rental.totalCost}}',
    '{{shop.name}}',
    '{{shop.phone}}',
  ];

  void loadDefaultContent() {
    contentController.text = """
RENTAL AGREEMENT

This Rental Agreement ("Agreement") is made and entered into on {{rental.date}}, by and between:

Lessor: {{shop.name}} ("Shop")
Phone: {{shop.phone}}

Lessee: {{customer.name}} ("Customer")
Phone: {{customer.phone}}
ID/Passport: {{customer.passport}}

1. EQUIPMENT
The Shop agrees to rent the following equipment to the Customer:
Item: {{rental.item}}

2. RENTAL PERIOD
Start Time: {{rental.startTime}}
Expected Return Time: {{rental.returnTime}}

3. CHARGES
Rate: {{rental.rate}}
Total Estimated Cost: {{rental.totalCost}}

4. LIABILITY
The Customer agrees to return the equipment in the same condition as received. The Customer acknowledges that they are responsible for any loss, theft, or damage to the equipment during the rental period.

5. WAIVER
The Customer hereby releases, waives, discharges and covenants not to sue the Shop from any liability, claims, demands, action and causes of action whatsoever arising out of or related to any loss, damage, or injury, including death, that may be sustained by the Customer.

Signed: ___________________________
Date: _____________________________
""";
  }

  void insertPlaceholder(String placeholder) {
    final text = contentController.text;
    final selection = contentController.selection;

    if (selection.isValid) {
      final newText = text.replaceRange(
        selection.start,
        selection.end,
        placeholder,
      );
      contentController.text = newText;
      contentController.selection = TextSelection.collapsed(
        offset: selection.start + placeholder.length,
      );
    } else {
      contentController.text = text + placeholder;
      contentController.selection = TextSelection.collapsed(
        offset: contentController.text.length,
      );
    }
  }

  void addDefaultTemplate() {
    AgreementTemplateService agreementTemplateService =
        AgreementTemplateService();
    agreementTemplateService.createDefaultTemplate(shopId!);
  }
}
