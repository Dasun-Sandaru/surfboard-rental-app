class AgreementTemplateModel {
  final String? id;
  final String shopId;
  final String templateName;
  final String? description;
  final Map<String, String> sections;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  AgreementTemplateModel({
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
  factory AgreementTemplateModel.fromMap(
    Map<String, dynamic> data,
    String docId,
  ) {
    return AgreementTemplateModel(
      id: docId,
      shopId: data['shop_id'] ?? '',
      templateName: data['template_name'] ?? 'Default Template',
      description: data['description'],
      sections: Map<String, String>.from(data['sections'] ?? {}),
      isDefault: data['is_default'] ?? false,
      createdAt: (data['created_at'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as dynamic)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert to Firestore document format
  Map<String, dynamic> toMap() {
    return {
      'shop_id': shopId,
      'template_name': templateName,
      'description': description,
      'sections': sections,
      'is_default': isDefault,
      'created_at': createdAt,
      'updated_at': updatedAt,
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
