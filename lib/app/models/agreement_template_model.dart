import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';

class AgreementTemplateModel {
  final String? id;
  final String shopId;
  final String templateName;
  final String? description;
  final Map<String, String> sections;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AgreementTemplateModel({
    this.id,
    required this.shopId,
    required this.templateName,
    this.description,
    required this.sections,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create agreement template from Firestore document
  factory AgreementTemplateModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return AgreementTemplateModel(
      id: doc.id,
      shopId: data[FirestoreFields.shopId] ?? '',
      templateName: data[FirestoreFields.templateName] ?? 'Default Template',
      description: data[FirestoreFields.description],
      sections: Map<String, String>.from(data[FirestoreFields.section] ?? {}),
      isDefault: data[FirestoreFields.isDefault] ?? false,
      createdAt: (data[FirestoreFields.createdAt] as Timestamp).toDate(),
      updatedAt: (data[FirestoreFields.updatedAt] as Timestamp).toDate(),
    );
  }

  /// Create agreement template from Firestore document (legacy/helper)
  factory AgreementTemplateModel.fromMap(
    Map<String, dynamic> data,
    String docId,
  ) {
    return AgreementTemplateModel(
      id: docId,
      shopId: data[FirestoreFields.shopId] ?? '',
      templateName: data[FirestoreFields.templateName] ?? 'Default Template',
      description: data[FirestoreFields.description],
      sections: Map<String, String>.from(data[FirestoreFields.section] ?? {}),
      isDefault: data[FirestoreFields.isDefault] ?? false,
      createdAt: data[FirestoreFields.createdAt] is Timestamp
          ? (data[FirestoreFields.createdAt] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data[FirestoreFields.updatedAt] is Timestamp
          ? (data[FirestoreFields.updatedAt] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Convert to Firestore document format
  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.shopId: shopId,
      FirestoreFields.templateName: templateName,
      FirestoreFields.description: description,
      FirestoreFields.section: sections,
      FirestoreFields.isDefault: isDefault,
      FirestoreFields.createdAt: Timestamp.fromDate(createdAt),
      FirestoreFields.updatedAt: Timestamp.fromDate(updatedAt),
    };
  }

  /// Create a copy with modified fields
  AgreementTemplateModel copyWith({
    String? id,
    String? shopId,
    String? templateName,
    String? description,
    Map<String, String>? sections,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AgreementTemplateModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      templateName: templateName ?? this.templateName,
      description: description ?? this.description,
      sections: sections ?? this.sections,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
