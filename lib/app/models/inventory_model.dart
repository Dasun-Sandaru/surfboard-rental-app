import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/firestore/firestore_fields.dart';
import '../../utils/constants/a_enums.dart';

class InventoryModel {
  final String id;
  final String shopId; // Added for multi-shop data isolation
  final String imageUrl;
  final String name;
  final String type;
  final String brand;

  /// Size (NUMERIC)
  final int sizeFeet;
  final int sizeInches;
  final int sizeTotalInches;

  final int volume;
  final String color;
  final int purchaseCost;
  final String damageFeeRule;
  final int rentalRateHour;
  final int rentalRateDay;
  final String note;
  final InventoryStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const InventoryModel({
    required this.id,
    this.shopId = '',
    required this.imageUrl,
    required this.name,
    required this.type,
    required this.brand,
    required this.sizeFeet,
    required this.sizeInches,
    required this.sizeTotalInches,
    required this.volume,
    required this.color,
    required this.purchaseCost,
    required this.damageFeeRule,
    required this.rentalRateHour,
    required this.rentalRateDay,
    required this.note,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  /// Computed display value
  String get displaySize => "$sizeFeet' $sizeInches\"";

  /// Firestore → Model
  factory InventoryModel.fromMap(Map<String, dynamic> data) {
    return InventoryModel(
      id: data[FirestoreFields.id] as String? ?? '',
      shopId: data[FirestoreFields.shopId] as String? ?? '',
      imageUrl: data[FirestoreFields.imageUrl] as String? ?? '',
      name: data[FirestoreFields.name] as String? ?? '',
      type: data[FirestoreFields.type] as String? ?? '',
      brand: data[FirestoreFields.brand] as String? ?? '',

      sizeFeet: (data[FirestoreFields.sizeFeet] as num?)?.toInt() ?? 0,
      sizeInches: (data[FirestoreFields.sizeInches] as num?)?.toInt() ?? 0,
      sizeTotalInches:
          (data[FirestoreFields.sizeTotalInches] as num?)?.toInt() ?? 0,

      volume: (data[FirestoreFields.volume] as num?)?.toInt() ?? 0,
      color: data[FirestoreFields.color] as String? ?? '',
      purchaseCost: (data[FirestoreFields.purchaseCost] as num?)?.toInt() ?? 0,
      damageFeeRule: data[FirestoreFields.damageFeeRule] as String? ?? '',
      rentalRateHour:
          (data[FirestoreFields.rentalRateHour] as num?)?.toInt() ?? 0,
      rentalRateDay:
          (data[FirestoreFields.rentalRateDay] as num?)?.toInt() ?? 0,
      note: data[FirestoreFields.note] as String? ?? '',

      status: InventoryStatus.values.firstWhere(
        (e) => e.name == data[FirestoreFields.status],
        orElse: () => InventoryStatus.available,
      ),

      createdAt: data[FirestoreFields.createdAt] != null
          ? (data[FirestoreFields.createdAt] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data[FirestoreFields.updatedAt] != null
          ? (data[FirestoreFields.updatedAt] as Timestamp).toDate()
          : null,
    );
  }

  /// Firestore → Model
  factory InventoryModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    return InventoryModel.fromMap(snapshot.data()!);
  }

  /// Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.id: id,
      FirestoreFields.shopId: shopId,
      FirestoreFields.imageUrl: imageUrl,
      FirestoreFields.name: name,
      FirestoreFields.type: type,
      FirestoreFields.brand: brand,

      FirestoreFields.sizeFeet: sizeFeet,
      FirestoreFields.sizeInches: sizeInches,
      FirestoreFields.sizeTotalInches: sizeTotalInches,

      FirestoreFields.volume: volume,
      FirestoreFields.color: color,
      FirestoreFields.purchaseCost: purchaseCost,
      FirestoreFields.damageFeeRule: damageFeeRule,
      FirestoreFields.rentalRateHour: rentalRateHour,
      FirestoreFields.rentalRateDay: rentalRateDay,
      FirestoreFields.note: note,

      FirestoreFields.status: status.name,
      FirestoreFields.createdAt: Timestamp.fromDate(createdAt),
      FirestoreFields.updatedAt: updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : null,
    };
  }

  /// CopyWith method for immutable updates
  InventoryModel copyWith({
    String? id,
    String? shopId,
    String? imageUrl,
    String? name,
    String? type,
    String? brand,
    int? sizeFeet,
    int? sizeInches,
    int? sizeTotalInches,
    int? volume,
    String? color,
    int? purchaseCost,
    String? damageFeeRule,
    int? rentalRateHour,
    int? rentalRateDay,
    String? note,
    InventoryStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return InventoryModel(
      id: id ?? this.id,
      shopId: shopId ?? this.shopId,
      imageUrl: imageUrl ?? this.imageUrl,
      name: name ?? this.name,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      sizeFeet: sizeFeet ?? this.sizeFeet,
      sizeInches: sizeInches ?? this.sizeInches,
      sizeTotalInches: sizeTotalInches ?? this.sizeTotalInches,
      volume: volume ?? this.volume,
      color: color ?? this.color,
      purchaseCost: purchaseCost ?? this.purchaseCost,
      damageFeeRule: damageFeeRule ?? this.damageFeeRule,
      rentalRateHour: rentalRateHour ?? this.rentalRateHour,
      rentalRateDay: rentalRateDay ?? this.rentalRateDay,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
