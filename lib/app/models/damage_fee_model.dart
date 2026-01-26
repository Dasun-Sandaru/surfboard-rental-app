import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';

class DamageFeeModel {
  final String? id;
  final String itemId;
  final double feeAmount;
  final String description;
  final bool activeStatus;
  final String damageType;

  const DamageFeeModel({
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

  /// Create a DamageFeeModel from Firestore Snapshot
  factory DamageFeeModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return DamageFeeModel(
      id: doc.id,
      itemId: (data[FirestoreFields.itemId] ?? 'ALL') as String,
      feeAmount: ((data[FirestoreFields.feeAmount] ?? 0.0) as num).toDouble(),
      description: (data[FirestoreFields.description] ?? '') as String,
      activeStatus: (data[FirestoreFields.activeStatus] ?? true) as bool,
      damageType: (data[FirestoreFields.damageType] ?? '') as String,
    );
  }

  /// Create a DamageFeeModel from Firestore JSON (Legacy/Helper)
  factory DamageFeeModel.fromJson(Map<String, dynamic> json) {
    return DamageFeeModel(
      id: json[FirestoreFields.id] as String?,
      itemId: (json[FirestoreFields.itemId] ?? 'ALL') as String,
      feeAmount: ((json[FirestoreFields.feeAmount] ?? 0.0) as num).toDouble(),
      description: (json[FirestoreFields.description] ?? '') as String,
      activeStatus: (json[FirestoreFields.activeStatus] ?? true) as bool,
      damageType: (json[FirestoreFields.damageType] ?? '') as String,
    );
  }

  /// Convert DamageFeeModel to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.itemId: itemId,
      FirestoreFields.feeAmount: feeAmount,
      FirestoreFields.description: description,
      FirestoreFields.activeStatus: activeStatus,
      FirestoreFields.damageType: damageType,
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
