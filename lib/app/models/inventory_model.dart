import 'package:cloud_firestore/cloud_firestore.dart';

import '../../utils/constants/a_enums.dart';

class InventoryModel {
  String id;
  String name;
  String type;
  String brand;
  String sizeFeet;
  String sizeInches;
  String volume;
  String color;
  String purchaseCost;
  String damageFeeRule;
  String rentalRateHour;
  String rentalRateDay;
  String note;
  ItemStatus status;
  Timestamp createdAt;
  InventoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.brand,
    required this.sizeFeet,
    required this.sizeInches,
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

  /// Create InventoryModel from Firestore map
  factory InventoryModel.fromMap(Map<String, dynamic> data) {
    return InventoryModel(
      id: data['id'] as String,
      name: data['name'] as String,
      type: data['type'] as String,
      brand: data['brand'] as String,
      sizeFeet: data['size_feet'] as String,
      sizeInches: data['size_inches'] as String,
      volume: data['volume'] as String,
      color: data['color'] as String,
      purchaseCost: data['purchase_cost'] as String,
      damageFeeRule: data['damage_fee_rule'] as String,
      rentalRateHour: data['rental_rate_hour'] as String,
      rentalRateDay: data['rental_rate_day'] as String,
      note: data['note'] as String,
      status: ItemStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => ItemStatus.available,
      ),
      createdAt: data['created_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'type': type,
      'brand': brand,
      'size_feet': sizeFeet,
      'size_inches': sizeInches,
      'volume': volume,
      'color': color,
      'purchase_cost': purchaseCost,
      'damage_fee_rule': damageFeeRule,
      'rental_rate_hour': rentalRateHour,
      'rental_rate_day': rentalRateDay,
      'note': note,
      'status': status.toString().split('.').last,
      'created_at': createdAt,
    };
  }
}
