import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/app/models/agreement_template_model.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_collections.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';

class AgreementTemplateService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String logName = 'AgreementTemplateService';

  /// Create a new agreement template
  Future<String> createTemplate({
    required String shopId,
    required String templateName,
    required Map<String, String> sections,
    String? description,
    bool isDefault = false,
  }) async {
    try {
      log(
        'Creating agreement template: $templateName for shop: $shopId',
        name: logName,
      );

      final now = DateTime.now();
      final templateRef = _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.agreementTemplates)
          .doc();

      final template = AgreementTemplateModel(
        shopId: shopId,
        templateName: templateName,
        description: description,
        sections: sections,
        isDefault: isDefault,
        createdAt: now,
        updatedAt: now,
      );

      await templateRef.set(template.toMap());
      log('Template created: ${templateRef.id}', name: logName);

      return templateRef.id;
    } catch (e) {
      log('Error creating template: $e', name: logName);
      rethrow;
    }
  }

  /// Get all templates for a shop
  Future<List<AgreementTemplateModel>> getShopTemplates(String shopId) async {
    try {
      log('Fetching templates for shop: $shopId', name: logName);

      final snapshot = await _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.agreementTemplates)
          .orderBy(FirestoreFields.createdAt, descending: true)
          .get();

      final templates = snapshot.docs
          .map((doc) => AgreementTemplateModel.fromMap(doc.data(), doc.id))
          .toList();

      log('Found ${templates.length} templates', name: logName);
      return templates;
    } catch (e) {
      log('Error fetching templates: $e', name: logName);
      rethrow;
    }
  }

  /// Get a single template by ID
  Future<AgreementTemplateModel?> getTemplate({
    required String shopId,
    required String templateId,
  }) async {
    try {
      log('Fetching template: $templateId', name: logName);

      final doc = await _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.agreementTemplates)
          .doc(templateId)
          .get();

      if (!doc.exists) {
        log('Template not found: $templateId', name: logName);
        return null;
      }

      return AgreementTemplateModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      log('Error fetching template: $e', name: logName);
      rethrow;
    }
  }

  /// Get the default template for a shop
  Future<AgreementTemplateModel?> getDefaultTemplate(String shopId) async {
    try {
      log('Fetching default template for shop: $shopId', name: logName);

      final snapshot = await _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.agreementTemplates)
          .where(FirestoreFields.isDefault, isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        log('No default template found', name: logName);
        return null;
      }

      return AgreementTemplateModel.fromMap(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );
    } catch (e) {
      log('Error fetching default template: $e', name: logName);
      rethrow;
    }
  }

  /// Update an agreement template
  Future<void> updateTemplate({
    required String shopId,
    required String templateId,
    String? templateName,
    String? description,
    Map<String, String>? sections,
    bool? isDefault,
  }) async {
    try {
      log('Updating template: $templateId', name: logName);

      final updates = <String, dynamic>{
        FirestoreFields.updatedAt: DateTime.now(),
      };

      if (templateName != null) {
        updates[FirestoreFields.templateName] = templateName;
      }
      if (description != null) {
        updates[FirestoreFields.description] = description;
      }
      if (sections != null) {
        updates[FirestoreFields.section] = sections;
      }
      if (isDefault != null) {
        updates[FirestoreFields.isDefault] = isDefault;
      }

      await _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.agreementTemplates)
          .doc(templateId)
          .update(updates);

      log('Template updated: $templateId', name: logName);
    } catch (e) {
      log('Error updating template: $e', name: logName);
      rethrow;
    }
  }

  /// Delete an agreement template
  Future<void> deleteTemplate({
    required String shopId,
    required String templateId,
  }) async {
    try {
      log('Deleting template: $templateId', name: logName);

      await _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.agreementTemplates)
          .doc(templateId)
          .delete();

      log('Template deleted: $templateId', name: logName);
    } catch (e) {
      log('Error deleting template: $e', name: logName);
      rethrow;
    }
  }

  /// Set a template as default (only one per shop)
  Future<void> setDefaultTemplate({
    required String shopId,
    required String templateId,
  }) async {
    try {
      log('Setting template as default: $templateId', name: logName);

      final batch = _db.batch();

      // Get all templates for this shop
      final allTemplates = await getShopTemplates(shopId);

      // Remove default from all templates
      for (var template in allTemplates) {
        if (template.id != null && template.isDefault) {
          batch.update(
            _db
                .collection(FirestoreCollections.shops)
                .doc(shopId)
                .collection(FirestoreCollections.agreementTemplates)
                .doc(template.id),
            {FirestoreFields.isDefault: false},
          );
        }
      }

      // Set the new default
      batch.update(
        _db
            .collection(FirestoreCollections.shops)
            .doc(shopId)
            .collection(FirestoreCollections.agreementTemplates)
            .doc(templateId),
        {
          FirestoreFields.isDefault: true,
          FirestoreFields.updatedAt: DateTime.now(),
        },
      );

      await batch.commit();
      log('Default template set: $templateId', name: logName);
    } catch (e) {
      log('Error setting default template: $e', name: logName);
      rethrow;
    }
  }

  /// Create default template for a shop (called on shop creation)
  Future<String> createDefaultTemplate(String shopId) async {
    try {
      log('Creating default template for shop: $shopId', name: logName);

      final defaultSections = _getDefaultSections();

      return await createTemplate(
        shopId: shopId,
        templateName: 'Default Agreement',
        description: 'Default surfboard rental agreement',
        sections: defaultSections,
        isDefault: true,
      );
    } catch (e) {
      log('Error creating default template: $e', name: logName);
      rethrow;
    }
  }

  /// Get default sections template
  Map<String, String> _getDefaultSections() {
    return {
      'header': 'SURFBOARD RENTAL AGREEMENT',
      'use_of_equipment_title': '3. USE OF EQUIPMENT',
      'use_of_equipment':
          'The renter agrees to:\n• Use the surfboard safely and only for surfing\n• Not allow anyone else to use the equipment\n• Follow all local beach and surf rules\n• Not surf under the influence of alcohol or drugs',
      'assumption_of_risk_title': '4. ASSUMPTION OF RISK',
      'assumption_of_risk':
          'The renter understands that surfing is a dangerous activity and accepts full responsibility for any injury, accident, or loss that may occur while using the rented equipment.',
      'liability_waiver_title': '5. LIABILITY WAIVER',
      'liability_waiver':
          'The renter releases and agrees not to hold the rental company responsible for any injury, damage, or loss resulting from the use of the surfboard or accessories.',
      'damage_responsibility_title': '6. DAMAGE, LOSS, OR THEFT',
      'damage_responsibility':
          'The renter is fully responsible for the surfboard and accessories during the rental period. The renter agrees to pay for:\n• Dings, cracks, breaks, snapped boards, or fin damage\n• Broken or lost leashes or fins\n• Water damage caused by unrepaired dings\n• Loss or theft of the surfboard or accessories\n\nNormal wear from proper use is acceptable. Any damage beyond normal wear will be charged.\n\nIf the board is lost, stolen, or damaged beyond repair, the renter agrees to pay the full replacement value.',
      'condition_of_equipment_title': '7. CONDITION OF EQUIPMENT',
      'condition_of_equipment':
          'The renter confirms the equipment was received in good condition and agrees to return it in the same condition, excluding normal wear.',
      'governing_law_title': '8. GOVERNING LAW',
      'governing_law':
          'This agreement is governed by the laws of your jurisdiction.',
      'signature_statement':
          'I have read and agree to all terms of this agreement.',
    };
  }
}
