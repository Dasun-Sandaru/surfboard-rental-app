import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';
import 'package:surfboard_rental_app/utils/constants/a_enums.dart';

class ActivityLogModel {
  final String? id;
  final String shopId;
  final String actorId;
  final String actorName;
  final ActivityType activityType;
  final String description;
  final String entityId;
  final String entityType; // 'Rental', 'Payment', 'Customer', 'Inventory'
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  const ActivityLogModel({
    this.id,
    required this.shopId,
    required this.actorId,
    required this.actorName,
    required this.activityType,
    required this.description,
    required this.entityId,
    required this.entityType,
    required this.timestamp,
    this.metadata,
  });

  factory ActivityLogModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return ActivityLogModel(
      id: doc.id,
      shopId: data[FirestoreFields.shopId] as String,
      actorId: data[FirestoreFields.actorId] as String,
      actorName: data[FirestoreFields.actorName] as String,
      activityType: enumFromString(
        ActivityType.values,
        data[FirestoreFields.activityType],
        ActivityType.undefined,
      ),
      description: data[FirestoreFields.description] as String,
      entityId: data[FirestoreFields.entityId] as String,
      entityType: data[FirestoreFields.entityType] as String,
      timestamp: (data[FirestoreFields.timestamp] as Timestamp).toDate(),
      metadata: data[FirestoreFields.metadata] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FirestoreFields.shopId: shopId,
      FirestoreFields.actorId: actorId,
      FirestoreFields.actorName: actorName,
      FirestoreFields.activityType: activityType.name,
      FirestoreFields.description: description,
      FirestoreFields.entityId: entityId,
      FirestoreFields.entityType: entityType,
      FirestoreFields.timestamp: Timestamp.fromDate(timestamp),
      FirestoreFields.metadata: metadata,
    };
  }
}
