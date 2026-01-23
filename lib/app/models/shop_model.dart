import 'package:cloud_firestore/cloud_firestore.dart';

class ShopModel {
  final String? id;
  final String businessName;
  final String location;
  final String phone;
  final String shopCode;
  final String ownerAdminUid;

  ShopModel({
    this.id,
    required this.businessName,
    required this.location,
    required this.phone,
    required this.shopCode,
    required this.ownerAdminUid,
  });

  // Factory constructor to create a ShopModel from a Firestore document
  factory ShopModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ShopModel(
      id: doc.id,
      businessName: data['name'] ?? '',
      location: data['location'] ?? '',
      phone: data['contact_number'] ?? '',
      shopCode: data['shop_code'] ?? '',
      ownerAdminUid: data['owner_admin_uid'] ?? '',
    );
  }
}