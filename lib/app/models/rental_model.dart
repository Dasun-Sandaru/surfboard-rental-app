import 'package:cloud_firestore/cloud_firestore.dart';

class RentalModel {
  final String? id;
  final String shopId;
  final String customerId;
  final String itemId;
  final DateTime startTime;
  final DateTime dueTime;
  final DateTime? returnTime;
  final String status;
  final String? agreementLink;
  final String rentedByUserId;

  RentalModel({
    this.id,
    required this.shopId,
    required this.customerId,
    required this.itemId,
    required this.startTime,
    required this.dueTime,
    this.returnTime,
    required this.status,
    this.agreementLink,
    required this.rentedByUserId,
  });

  // Factory constructor to create a RentalModel from a map
  factory RentalModel.fromMap(Map<String, dynamic> data, String documentId) {
    return RentalModel(
      id: documentId,
      shopId: data['shopId'] ?? '',
      customerId: data['customerId'] ?? '',
      itemId: data['itemId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      dueTime: (data['dueTime'] as Timestamp).toDate(),
      returnTime: data['returnTime'] != null
          ? (data['returnTime'] as Timestamp).toDate()
          : null,
      status: data['status'] ?? 'active',
      agreementLink: data['agreementLink'],
      rentedByUserId: data['rentedByUserId'] ?? '',
    );
  }

    // Factory constructor to create a RentalModel from a snapshot
  factory RentalModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data()!;
    return RentalModel(
      id: document.id,
      shopId: data['shopId'] ?? '',
      customerId: data['customerId'] ?? '',
      itemId: data['itemId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      dueTime: (data['dueTime'] as Timestamp).toDate(),
      returnTime: data['returnTime'] != null
          ? (data['returnTime'] as Timestamp).toDate()
          : null,
      status: data['status'] ?? 'active',
      agreementLink: data['agreementLink'],
      rentedByUserId: data['rentedByUserId'] ?? '',
    );
  }


  // Method to convert a RentalModel instance to a map
  Map<String, dynamic> toMap() {
    return {
      'shopId': shopId,
      'customerId': customerId,
      'itemId': itemId,
      'startTime': Timestamp.fromDate(startTime),
      'dueTime': Timestamp.fromDate(dueTime),
      'returnTime': returnTime != null ? Timestamp.fromDate(returnTime!) : null,
      'status': status,
      'agreementLink': agreementLink,
      'rentedByUserId': rentedByUserId,
    };
  }
}