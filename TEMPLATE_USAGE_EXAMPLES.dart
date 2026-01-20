/// Agreement Template System - Usage Examples
///
/// This file contains practical examples of how to use the new agreement
/// template system throughout your application.

import 'package:surfboard_rental_app/app/models/agreement_template_model.dart';
import 'package:surfboard_rental_app/app/services/agreement_template_service.dart';
import 'package:surfboard_rental_app/app/services/pdf_service.dart';

// ============================================================================
// EXAMPLE 1: Creating a New Template
// ============================================================================
Future<void> createCustomAgreementTemplate() async {
  final templateService = AgreementTemplateService();

  final templateId = await templateService.createTemplate(
    shopId: 'shop_123',
    templateName: 'Premium Renter Agreement',
    description: 'Agreement with additional insurance clause',
    sections: {
      'header': 'PREMIUM SURFBOARD RENTAL AGREEMENT',
      'use_of_equipment': '''The renter agrees to:
• Use the surfboard safely and only for surfing in permitted areas
• Not allow anyone else to use the equipment
• Follow all local beach and surf rules
• Not surf under the influence of alcohol or drugs
• Return equipment at agreed time''',
      'assumption_of_risk':
          'The renter understands that surfing is a dangerous activity and accepts full responsibility for any injury, accident, or loss that may occur while using the rented equipment. Additional insurance is available upon request.',
      'liability_waiver':
          'The renter releases and agrees not to hold the rental company responsible for any injury, damage, or loss resulting from the use of the surfboard or accessories, except in cases of equipment malfunction.',
      'damage_responsibility':
          '''The renter is fully responsible for the surfboard and accessories during the rental period. The renter agrees to pay for:
• Dings, cracks, breaks, snapped boards, or fin damage
• Broken or lost leashes or fins
• Water damage caused by unrepaired dings
• Loss or theft of the surfboard or accessories

Normal wear from proper use is acceptable. Any damage beyond normal wear will be charged.''',
      'condition_of_equipment':
          'The renter confirms the equipment was received in good condition and agrees to return it in the same condition, excluding normal wear.',
      'governing_law':
          'This agreement is governed by the laws of Brazil, specifically the state where the rental occurs.',
      'signature_statement':
          'I have read and agree to all terms of this agreement and have received a copy.',
    },
    isDefault: false,
  );

  print('Created template: $templateId');
}

// ============================================================================
// EXAMPLE 2: Retrieving and Using Templates
// ============================================================================
Future<void> fetchAndDisplayTemplates(String shopId) async {
  final templateService = AgreementTemplateService();

  // Get all templates for the shop
  final templates = await templateService.getShopTemplates(shopId);

  print('Shop has ${templates.length} templates:');
  for (var template in templates) {
    print(
      '- ${template.templateName} (${template.isDefault ? 'DEFAULT' : 'custom'})',
    );
    if (template.description != null) {
      print('  Description: ${template.description}');
    }
  }

  // Get the default template
  final defaultTemplate = await templateService.getDefaultTemplate(shopId);
  if (defaultTemplate != null) {
    print('Default template: ${defaultTemplate.templateName}');
  }
}

// ============================================================================
// EXAMPLE 3: Generating PDF with Default Template
// ============================================================================
Future<void> generatePdfWithDefaultTemplate({
  required String shopId,
  // ... other required parameters
}) async {
  final pdfService = PdfService();

  // The service automatically uses the default template when templateId is not provided
  final pdfBytes = await pdfService.generateAgreementPdf(
    rentalData: rentalData,
    shopData: shopData,
    shopId:
        shopId, // REQUIRED: The service uses this to find the default template
    rentalFee: 75.00,
    deposit: 150.00,
    selectedDamageFees: damageFees,
    customerSignature: signatureImage,
    // templateId parameter is optional - defaults to default template
  );

  // Save or send the PDF
  await savePdfFile(pdfBytes, 'rental_agreement.pdf');
}

// ============================================================================
// EXAMPLE 4: Generating PDF with Specific Template
// ============================================================================
Future<void> generatePdfWithSpecificTemplate({
  required String shopId,
  required String templateId,
  // ... other required parameters
}) async {
  final pdfService = PdfService();

  final pdfBytes = await pdfService.generateAgreementPdf(
    rentalData: rentalData,
    shopData: shopData,
    shopId: shopId,
    rentalFee: 75.00,
    deposit: 150.00,
    selectedDamageFees: damageFees,
    customerSignature: signatureImage,
    templateId: templateId, // Use specific template instead of default
  );

  return pdfBytes;
}

// ============================================================================
// EXAMPLE 5: Updating a Template
// ============================================================================
Future<void> updateTemplateContent(String shopId, String templateId) async {
  final templateService = AgreementTemplateService();

  // Get the current template
  final template = await templateService.getTemplate(
    shopId: shopId,
    templateId: templateId,
  );

  if (template != null) {
    // Modify specific sections
    final updatedSections = {...template.sections};
    updatedSections['governing_law'] =
        'This agreement is governed by the laws of the State of California.';

    // Update the template
    await templateService.updateTemplate(
      shopId: shopId,
      templateId: templateId,
      sections: updatedSections,
    );

    print('Template updated successfully');
  }
}

// ============================================================================
// EXAMPLE 6: Setting a Template as Default
// ============================================================================
Future<void> makeTemplateDefault(String shopId, String templateId) async {
  final templateService = AgreementTemplateService();

  // This automatically removes default status from other templates
  await templateService.setDefaultTemplate(
    shopId: shopId,
    templateId: templateId,
  );

  print('Template set as default');
}

// ============================================================================
// EXAMPLE 7: Initializing Default Template on Shop Creation
// ============================================================================
Future<void> createShopWithDefaultTemplate(String shopName) async {
  final templateService = AgreementTemplateService();

  // Create the shop (in your shop service)
  final shopId = await createShop(shopName);

  // Create default agreement template
  final templateId = await templateService.createDefaultTemplate(shopId);

  print('Shop created with default template: $templateId');
}

// ============================================================================
// EXAMPLE 8: Cloning a Template
// ============================================================================
Future<String> cloneTemplate(
  String shopId,
  String templateId,
  String newName,
) async {
  final templateService = AgreementTemplateService();

  // Get the original template
  final original = await templateService.getTemplate(
    shopId: shopId,
    templateId: templateId,
  );

  if (original == null) throw Exception('Template not found');

  // Create a copy with new name
  final newTemplateId = await templateService.createTemplate(
    shopId: shopId,
    templateName: newName,
    description: 'Cloned from: ${original.templateName}',
    sections: original.sections,
  );

  return newTemplateId;
}

// ============================================================================
// EXAMPLE 9: Comparing Two Templates
// ============================================================================
Future<void> compareTemplates(
  String shopId,
  String templateId1,
  String templateId2,
) async {
  final templateService = AgreementTemplateService();

  final template1 = await templateService.getTemplate(
    shopId: shopId,
    templateId: templateId1,
  );

  final template2 = await templateService.getTemplate(
    shopId: shopId,
    templateId: templateId2,
  );

  if (template1 != null && template2 != null) {
    print('Template 1: ${template1.templateName}');
    print('Template 2: ${template2.templateName}');

    // Compare sections
    for (var key in template1.sections.keys) {
      final same = template1.sections[key] == template2.sections[key];
      print('Section "$key": ${same ? 'SAME' : 'DIFFERENT'}');
    }
  }
}

// ============================================================================
// EXAMPLE 10: Bulk Update All Template Sections
// ============================================================================
Future<void> updateAllTemplatesSection(
  String shopId,
  String sectionKey,
  String newContent,
) async {
  final templateService = AgreementTemplateService();

  final templates = await templateService.getShopTemplates(shopId);

  for (var template in templates) {
    if (template.id != null) {
      final updatedSections = {...template.sections};
      updatedSections[sectionKey] = newContent;

      await templateService.updateTemplate(
        shopId: shopId,
        templateId: template.id!,
        sections: updatedSections,
      );

      print('Updated ${template.templateName}');
    }
  }
}

// ============================================================================
// EXAMPLE 11: Creating Multiple Variants (Different Languages/Regions)
// ============================================================================
Future<void> createTemplateVariants(String shopId) async {
  final templateService = AgreementTemplateService();

  // English version
  final englishId = await templateService.createTemplate(
    shopId: shopId,
    templateName: 'Standard Agreement - English',
    description: 'Rental agreement in English',
    sections: {
      'header': 'SURFBOARD RENTAL AGREEMENT',
      'governing_law':
          'This agreement is governed by the laws of the United States.',
      // ... other sections in English
    },
    isDefault: true,
  );

  // Portuguese version
  await templateService.createTemplate(
    shopId: shopId,
    templateName: 'Contrato de Aluguel - Português',
    description: 'Contrato de aluguel de prancha em português',
    sections: {
      'header': 'CONTRATO DE ALUGUEL DE PRANCHA',
      'governing_law': 'Este contrato é regido pelas leis do Brasil.',
      // ... other sections in Portuguese
    },
    isDefault: false,
  );

  // Spanish version
  await templateService.createTemplate(
    shopId: shopId,
    templateName: 'Acuerdo de Alquiler - Español',
    description: 'Acuerdo de alquiler de tabla en español',
    sections: {
      'header': 'ACUERDO DE ALQUILER DE TABLA DE SURF',
      'governing_law': 'Este acuerdo se rige por las leyes de España.',
      // ... other sections in Spanish
    },
    isDefault: false,
  );
}

// ============================================================================
// EXAMPLE 12: Error Handling Best Practices
// ============================================================================
Future<void> safePdfGeneration({
  required String shopId,
  String? templateId,
  // ... other parameters
}) async {
  try {
    final pdfService = PdfService();

    // Validate inputs
    if (shopId.isEmpty) {
      throw ArgumentError('shopId cannot be empty');
    }

    // Generate PDF
    final pdfBytes = await pdfService.generateAgreementPdf(
      rentalData: rentalData,
      shopData: shopData,
      shopId: shopId,
      rentalFee: rentalFee,
      deposit: deposit,
      selectedDamageFees: damageFees,
      customerSignature: signature,
      templateId: templateId,
    );

    return pdfBytes;
  } on Exception catch (e) {
    // Handle specific errors
    if (e.toString().contains('No agreement template found')) {
      print('Error: Template not found. Creating default template...');
      // Could trigger default template creation here
    } else if (e.toString().contains('Connection refused')) {
      print('Error: Cannot connect to Firestore. Check internet connection.');
    } else {
      print('Error generating PDF: $e');
    }

    rethrow;
  }
}

// ============================================================================
// EXAMPLE 13: Template Preview Formatting
// ============================================================================
String formatTemplateForPreview(AgreementTemplateModel template) {
  final buffer = StringBuffer();

  buffer.writeln('Template: ${template.templateName}');
  buffer.writeln('Description: ${template.description ?? 'N/A'}');
  buffer.writeln('Default: ${template.isDefault ? 'YES' : 'NO'}');
  buffer.writeln('Created: ${template.createdAt}');
  buffer.writeln('');
  buffer.writeln('--- SECTIONS ---');

  template.sections.forEach((key, value) {
    buffer.writeln('\n[$key]');
    buffer.writeln(value);
  });

  return buffer.toString();
}

// ============================================================================
// EXAMPLE 14: Detecting Missing Sections
// ============================================================================
List<String> detectMissingSections(
  AgreementTemplateModel template,
  List<String> requiredSections,
) {
  final missing = <String>[];

  for (var section in requiredSections) {
    if (!template.sections.containsKey(section) ||
        template.sections[section]!.isEmpty) {
      missing.add(section);
    }
  }

  return missing;
}

// ============================================================================
// EXAMPLE 15: Template Statistics
// ============================================================================
Future<Map<String, dynamic>> getTemplateStatistics(String shopId) async {
  final templateService = AgreementTemplateService();
  final templates = await templateService.getShopTemplates(shopId);

  int totalSections = 0;
  int totalCharacters = 0;
  String longestSection = '';
  int longestSectionLength = 0;

  for (var template in templates) {
    totalSections += template.sections.length;

    for (var entry in template.sections.entries) {
      totalCharacters += entry.value.length;
      if (entry.value.length > longestSectionLength) {
        longestSectionLength = entry.value.length;
        longestSection = entry.key;
      }
    }
  }

  return {
    'total_templates': templates.length,
    'total_sections': totalSections,
    'total_characters': totalCharacters,
    'avg_sections_per_template':
        totalSections ~/ (templates.isEmpty ? 1 : templates.length),
    'longest_section': longestSection,
    'longest_section_length': longestSectionLength,
  };
}
