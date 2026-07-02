import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/firestore/firestore_collections.dart';
import '../../data/firestore/firestore_fields.dart';
import 'activity_log_service.dart';
import '../../utils/constants/a_enums.dart';

import '../models/customer_model.dart';
import 'firestore_usage_service.dart';

class CustomerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String logName = 'CustomerService';
  final ActivityLogService _activityLogService = ActivityLogService();

  DocumentReference _shopRef(String shopId) {
    return _db.collection(FirestoreCollections.shops).doc(shopId);
  }

  // ---------------------------------------------------------------------------
  // CREATE CUSTOMER
  // ---------------------------------------------------------------------------
  Future<String> addCustomer(String shopId, CustomerModel customerData) async {
    try {
      log('Creating new customer for shop: $shopId', name: logName);

      final data = customerData.toMap();
      final docRef = _shopRef(
        shopId,
      ).collection(FirestoreCollections.customers).doc();

      // Using transaction for atomicity with log
      await _db.runTransaction((transaction) async {
        transaction.set(docRef, {
          ...data,
          FirestoreFields.id: docRef.id,
          FirestoreFields.createdAt: FieldValue.serverTimestamp(),
        });

        await _activityLogService.logActivity(
          shopId: shopId,
          type: ActivityType.add_customer,
          description: 'log_add_customer',
          entityId: docRef.id,
          entityType: 'Customer',
          metadata: {
            'customerName': '${customerData.firstName} ${customerData.lastName}',
          },
          transaction: transaction,
        );
      });

      FirestoreUsageService.to.trackWrite(2);
      log('Customer created: ${docRef.id}', name: logName);
      return docRef.id;
    } catch (e) {
      log('Error creating customer: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // GET CUSTOMERS STREAM
  // ---------------------------------------------------------------------------
  Stream<QuerySnapshot> getCustomersStream(String shopId) {
    try {
      log('Getting customers stream for shop: $shopId', name: logName);
      return _shopRef(
        shopId,
      ).collection(FirestoreCollections.customers).snapshots().map((snapshot) {
        FirestoreUsageService.to.trackQuerySnapshot(snapshot);
        return snapshot;
      });
    } catch (e) {
      log('Error creating customers stream: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // GET SINGLE CUSTOMER ONCE
  // ---------------------------------------------------------------------------
  Future<DocumentSnapshot> getCustomerOnce(
    String shopId,
    String customerId,
  ) async {
    try {
      log('Fetching customer: $customerId', name: logName);
      final doc = await _shopRef(
        shopId,
      ).collection(FirestoreCollections.customers).doc(customerId).get();
      FirestoreUsageService.to.trackDocumentSnapshot(doc);
      return doc;
    } catch (e) {
      log('Error fetching customer: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE CUSTOMER
  // ---------------------------------------------------------------------------
  Future<void> updateCustomer(
    String shopId,
    String customerId,
    CustomerModel data,
  ) async {
    try {
      log('Updating customer: $customerId', name: logName);

      await _shopRef(
        shopId,
      ).collection(FirestoreCollections.customers).doc(customerId).update({
        ...data.toMap(),
        FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
      });

      FirestoreUsageService.to.trackWrite(1);
      log('Customer updated: $customerId', name: logName);
    } catch (e) {
      log('Error updating customer: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE CUSTOMER
  // ---------------------------------------------------------------------------
  Future<void> deleteCustomer(String shopId, String customerId) async {
    try {
      log('Deleting customer: $customerId', name: logName);

      final docRef = _shopRef(
        shopId,
      ).collection(FirestoreCollections.customers).doc(customerId);

      // Using transaction for atomicity with log
      await _db.runTransaction((transaction) async {
        transaction.delete(docRef);

        await _activityLogService.logActivity(
          shopId: shopId,
          type: ActivityType.undefined, // or delete_customer if enum exists
          description: 'log_delete_customer',
          entityId: customerId,
          entityType: 'Customer',
          metadata: {
            'customerId': customerId,
          },
          transaction: transaction,
        );
      });

      FirestoreUsageService.to.trackDelete(1);
      FirestoreUsageService.to.trackWrite(1);
      log('Customer deleted: $customerId', name: logName);
    } catch (e) {
      log('Error deleting customer: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // GET CUSTOMER COUNT
  // ---------------------------------------------------------------------------
  Future<int> getCustomerCount(String shopId) async {
    try {
      log('Counting customers for shop: $shopId', name: logName);
      final aggregateQuery = await _shopRef(
        shopId,
      ).collection(FirestoreCollections.customers).count().get();
      FirestoreUsageService.to.trackRead(1);
      return aggregateQuery.count ?? 0;
    } catch (e) {
      log('Error counting customers: $e', name: logName);
      rethrow;
    }
  }

  Future<QuerySnapshot> getCustomersPage({
    required String shopId,
    required int limit,
    DocumentSnapshot? startAfter,
    String? searchTerm,
  }) async {
    try {
      log('Fetching customers page for shop: $shopId', name: logName);
      Query query = _shopRef(shopId).collection(FirestoreCollections.customers);

      if (searchTerm != null && searchTerm.isNotEmpty) {
        query = query
            .where(
              FirestoreFields.nameLowercase,
              isGreaterThanOrEqualTo: searchTerm.toLowerCase(),
            )
            .where(
              FirestoreFields.nameLowercase,
              isLessThan: '${searchTerm.toLowerCase()}z',
            )
            .limit(20);
      } else {
        query = query
            .orderBy(FirestoreFields.createdAt, descending: true)
            .limit(limit);

        if (startAfter != null) {
          query = query.startAfterDocument(startAfter);
        }
      }

      final snapshot = await query.get();
      FirestoreUsageService.to.trackQuerySnapshot(snapshot);
      return snapshot;
    } catch (e) {
      log('Error fetching customers page: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE CUSTOMER RENTAL STATS
  // ---------------------------------------------------------------------------
  /// Updates the customer's rental statistics.
  /// Called when a new rental is created (increment) or cancelled (decrement).
  /// Note: RentalService.createRental already handles this in a transaction.
  /// This method is for edge cases or manual corrections.
  Future<void> updateCustomerRentalStats({
    required String shopId,
    required String customerId,
    int incrementBy = 1,
    bool updateLastRentalDate = true,
  }) async {
    try {
      log('Updating rental stats for customer: $customerId', name: logName);

      final customerRef = _shopRef(
        shopId,
      ).collection(FirestoreCollections.customers).doc(customerId);

      final updateData = <String, dynamic>{
        FirestoreFields.rentalsCount: FieldValue.increment(incrementBy),
      };

      if (updateLastRentalDate && incrementBy > 0) {
        updateData[FirestoreFields.lastRentalDate] =
            FieldValue.serverTimestamp();
      }

      await customerRef.update(updateData);
      FirestoreUsageService.to.trackWrite(1);

      log('Customer rental stats updated: $customerId', name: logName);
    } catch (e) {
      log('Error updating customer rental stats: $e', name: logName);
      rethrow;
    }
  }

  Stream<int> streamCustomerCount(String shopId) {
    return _shopRef(shopId)
        .collection(FirestoreCollections.customers)
        .snapshots()
        .map((snapshot) {
      FirestoreUsageService.to.trackQuerySnapshot(snapshot);
      return snapshot.docs.length;
    });
  }

  // ---------------------------------------------------------------------------
  // RATE CUSTOMER
  // ---------------------------------------------------------------------------
  Future<void> rateCustomer({
    required String shopId,
    required String customerId,
    required double rating,
  }) async {
    try {
      log('Rating customer: $customerId with $rating', name: logName);
      final customerRef = _shopRef(
        shopId,
      ).collection(FirestoreCollections.customers).doc(customerId);

      await customerRef.update({
        FirestoreFields.rating: FieldValue.increment(rating),
        FirestoreFields.ratingCount: FieldValue.increment(1),
      });
      FirestoreUsageService.to.trackWrite(1);

      log('Customer rated successfully: $customerId', name: logName);
    } catch (e) {
      log('Error rating customer: $e', name: logName);
      rethrow;
    }
  }
}
