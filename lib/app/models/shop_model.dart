import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';

class ShopModel {
  final String? id;
  final String businessName;
  final String location;
  final String phone;
  final String shopCode;
  final String ownerAdminUid;

  // Business Settings
  final String currency;
  final double defaultDailyRate;
  final double defaultHourlyRate;
  final bool isTaxEnabled;
  final double taxRate;

  const ShopModel({
    this.id,
    required this.businessName,
    required this.location,
    required this.phone,
    required this.shopCode,
    required this.ownerAdminUid,
    this.currency = 'LKR',
    this.defaultDailyRate = 0.0,
    this.defaultHourlyRate = 0.0,
    this.isTaxEnabled = false,
    this.taxRate = 0.0,
  });

  // Factory constructor to create a ShopModel from a Firestore document
  factory ShopModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return ShopModel(
      id: doc.id,
      businessName: data[FirestoreFields.businessName] ?? '',
      location: data[FirestoreFields.location] ?? '',
      phone: data[FirestoreFields.contactNumber] ?? '',
      shopCode: data[FirestoreFields.shopCode] ?? '',
      ownerAdminUid: data[FirestoreFields.ownerAdminUid] ?? '',
      currency: data[FirestoreFields.currency] ?? 'LKR',
      defaultDailyRate:
          (data[FirestoreFields.defaultDailyRate] as num?)?.toDouble() ?? 0.0,
      defaultHourlyRate:
          (data[FirestoreFields.defaultHourlyRate] as num?)?.toDouble() ?? 0.0,
      isTaxEnabled: data[FirestoreFields.isTaxEnabled] ?? false,
      taxRate: (data[FirestoreFields.taxRate] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.businessName: businessName,
      FirestoreFields.location: location,
      FirestoreFields.contactNumber: phone,
      FirestoreFields.shopCode: shopCode,
      FirestoreFields.ownerAdminUid: ownerAdminUid,
      FirestoreFields.currency: currency,
      FirestoreFields.defaultDailyRate: defaultDailyRate,
      FirestoreFields.defaultHourlyRate: defaultHourlyRate,
      FirestoreFields.isTaxEnabled: isTaxEnabled,
      FirestoreFields.taxRate: taxRate,
    };
  }

  /// CopyWith method for immutable updates
  ShopModel copyWith({
    String? id,
    String? businessName,
    String? location,
    String? phone,
    String? shopCode,
    String? ownerAdminUid,
    String? currency,
    double? defaultDailyRate,
    double? defaultHourlyRate,
    bool? isTaxEnabled,
    double? taxRate,
  }) {
    return ShopModel(
      id: id ?? this.id,
      businessName: businessName ?? this.businessName,
      location: location ?? this.location,
      phone: phone ?? this.phone,
      shopCode: shopCode ?? this.shopCode,
      ownerAdminUid: ownerAdminUid ?? this.ownerAdminUid,
      currency: currency ?? this.currency,
      defaultDailyRate: defaultDailyRate ?? this.defaultDailyRate,
      defaultHourlyRate: defaultHourlyRate ?? this.defaultHourlyRate,
      isTaxEnabled: isTaxEnabled ?? this.isTaxEnabled,
      taxRate: taxRate ?? this.taxRate,
    );
  }
}
