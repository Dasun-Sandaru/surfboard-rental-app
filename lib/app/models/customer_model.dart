import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';

class CustomerModel {
  final String? id;
  final String firstName;
  final String lastName;
  final String phone;
  final String nic;
  final String email;
  final String notes;
  final DateTime? createdAt;
  final String? imageUrl;

  const CustomerModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.nic,
    required this.email,
    required this.notes,
    this.createdAt,
    this.imageUrl,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json[FirestoreFields.id],
      firstName: json[FirestoreFields.firstName] ?? '',
      lastName: json[FirestoreFields.lastName] ?? '',
      phone: json[FirestoreFields.phone] ?? '',
      nic: json[FirestoreFields.nic] ?? '',
      email: json[FirestoreFields.email] ?? '',
      notes: json[FirestoreFields.notes] ?? '',
      createdAt: json[FirestoreFields.createdAt] is Timestamp
          ? (json[FirestoreFields.createdAt] as Timestamp).toDate()
          : null,
      imageUrl: json[FirestoreFields.imageUrl],
    );
  }

  factory CustomerModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return CustomerModel(
      id: doc.id,
      firstName: data[FirestoreFields.firstName] ?? '',
      lastName: data[FirestoreFields.lastName] ?? '',
      phone: data[FirestoreFields.phone] ?? '',
      nic: data[FirestoreFields.nic] ?? '',
      email: data[FirestoreFields.email] ?? '',
      notes: data[FirestoreFields.notes] ?? '',
      createdAt: data[FirestoreFields.createdAt] is Timestamp
          ? (data[FirestoreFields.createdAt] as Timestamp).toDate()
          : null,
      imageUrl: data[FirestoreFields.imageUrl],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.id: id,
      FirestoreFields.firstName: firstName,
      FirestoreFields.lastName: lastName,
      FirestoreFields.phone: phone,
      FirestoreFields.nic: nic,
      FirestoreFields.email: email,
      FirestoreFields.notes: notes,
      FirestoreFields.createdAt: createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : null,
      FirestoreFields.imageUrl: imageUrl ?? '',
    };
  }
}
