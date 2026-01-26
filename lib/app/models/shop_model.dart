import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';

class ShopModel {
  final String? id;
  final String businessName;
  final String location;
  final String phone;
  final String shopCode;
  final String ownerAdminUid;

  const ShopModel({
    this.id,
    required this.businessName,
    required this.location,
    required this.phone,
    required this.shopCode,
    required this.ownerAdminUid,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.businessName: businessName,
      FirestoreFields.location: location,
      FirestoreFields.contactNumber: phone,
      FirestoreFields.shopCode: shopCode,
      FirestoreFields.ownerAdminUid: ownerAdminUid,
    };
  }
}
