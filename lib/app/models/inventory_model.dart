import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';
import '../../utils/constants/a_enums.dart';

class InventoryModel {
  final String id;
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

  const InventoryModel({
    required this.id,
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
  });

  /// Computed display value
  String get displaySize => "$sizeFeet' $sizeInches\"";

  /// Firestore → Model
  factory InventoryModel.fromMap(Map<String, dynamic> data) {
    return InventoryModel(
      id: data[FirestoreFields.id] as String? ?? '',
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
    };
  }
}
