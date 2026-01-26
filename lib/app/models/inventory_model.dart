import 'package:cloud_firestore/cloud_firestore.dart';
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
  final Timestamp createdAt;

  InventoryModel({
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
      id: data['id'] as String,
      imageUrl: data['image_url'] as String,
      name: data['name'] as String,
      type: data['type'] as String,
      brand: data['brand'] as String,

      sizeFeet: (data['size_feet'] as num).toInt(),
      sizeInches: (data['size_inches'] as num).toInt(),
      sizeTotalInches: (data['size_total_inches'] as num).toInt(),

      volume: (data['volume'] as num).toInt(),
      color: data['color'] as String,
      purchaseCost: (data['purchase_cost'] as num).toInt(),
      damageFeeRule: data['damage_fee_rule'] as String,
      rentalRateHour: (data['rental_rate_hour'] as num).toInt(),
      rentalRateDay: (data['rental_rate_day'] as num).toInt(),
      note: data['note'] as String,

      status: InventoryStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => InventoryStatus.available,
      ),

      createdAt: data['created_at'] as Timestamp,
    );
  }

  /// Firestore → Model
  factory InventoryModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return InventoryModel.fromMap(snapshot.data()!);
  }

  /// Model → Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'image_url': imageUrl,
      'name': name,
      'type': type,
      'brand': brand,

      'size_feet': sizeFeet,
      'size_inches': sizeInches,
      'size_total_inches': sizeTotalInches,

      'volume': volume,
      'color': color,
      'purchase_cost': purchaseCost,
      'damage_fee_rule': damageFeeRule,
      'rental_rate_hour': rentalRateHour,
      'rental_rate_day': rentalRateDay,
      'note': note,

      'status': status.name,
      'created_at': createdAt,
    };
  }
}
