class DamageFeeModel {
  final String? id;
  final String itemId;
  final double feeAmount;
  final String description;
  final bool activeStatus;
  final String damageType;

  DamageFeeModel({
    this.id,
    required this.itemId,
    required this.feeAmount,
    required this.description,
    required this.activeStatus,
    required this.damageType,
  });

  /// Create a new damage fee rule without ID (for adding new rules)
  factory DamageFeeModel.create({
    required String itemId,
    required double feeAmount,
    required String description,
    required String damageType,
  }) {
    return DamageFeeModel(
      id: null,
      itemId: itemId,
      feeAmount: feeAmount,
      description: description,
      activeStatus: true,
      damageType: damageType,
    );
  }

  /// Create a DamageFeeModel from Firestore JSON
  factory DamageFeeModel.fromJson(Map<String, dynamic> json) {
    return DamageFeeModel(
      id: json['id'] as String?,
      itemId: (json['item_id'] ?? 'ALL') as String,
      feeAmount: ((json['fee_amount'] ?? 0.0) as num).toDouble(),
      description: (json['description'] ?? '') as String,
      activeStatus: (json['active_status'] ?? true) as bool,
      damageType: (json['damage_type'] ?? '') as String,
    );
  }

  /// Convert DamageFeeModel to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'item_id': itemId,
      'fee_amount': feeAmount,
      'description': description,
      'active_status': activeStatus,
      'damage_type': damageType,
    };
  }

  /// Create a copy with modified fields
  DamageFeeModel copyWith({
    String? id,
    String? itemId,
    double? feeAmount,
    String? description,
    bool? activeStatus,
    String? damageType,
  }) {
    return DamageFeeModel(
      id: id ?? this.id,
      itemId: itemId ?? this.itemId,
      feeAmount: feeAmount ?? this.feeAmount,
      description: description ?? this.description,
      activeStatus: activeStatus ?? this.activeStatus,
      damageType: damageType ?? this.damageType,
    );
  }

  @override
  String toString() {
    return 'DamageFeeModel(id: $id, itemId: $itemId, feeAmount: $feeAmount, description: $description, activeStatus: $activeStatus, damageType: $damageType)';
  }
}
