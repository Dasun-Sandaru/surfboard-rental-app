import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationTriggerModel {
  final String id;
  final String rentalId;
  final String shopId;
  final DateTime expectedReturnTime;
  final String status;
  final String title;
  final String body;
  final String customerName;
  final String itemName;

  NotificationTriggerModel({
    required this.id,
    required this.rentalId,
    required this.shopId,
    required this.expectedReturnTime,
    required this.status,
    required this.title,
    required this.body,
    required this.customerName,
    required this.itemName,
  });

  factory NotificationTriggerModel.fromSnapshot(
      DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) {
      throw StateError('Missing data for NotificationTriggerModel');
    }

    return NotificationTriggerModel(
      id: snapshot.id,
      rentalId: data['rentalId'] ?? '',
      shopId: data['shopId'] ?? '',
      expectedReturnTime: (data['expectedReturnTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'pending',
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      customerName: data['customerName'] ?? '',
      itemName: data['itemName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rentalId': rentalId,
      'shopId': shopId,
      'expectedReturnTime': Timestamp.fromDate(expectedReturnTime),
      'status': status,
      'title': title,
      'body': body,
      'customerName': customerName,
      'itemName': itemName,
    };
  }
}
