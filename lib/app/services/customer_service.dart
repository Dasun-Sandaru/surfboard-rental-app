import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_collections.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';
import 'package:surfboard_rental_app/app/services/activity_log_service.dart';
import 'package:surfboard_rental_app/utils/constants/a_enums.dart';

import '../models/customer_model.dart';

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
          description:
              "Added customer ${customerData.firstName} ${customerData.lastName}",
          entityId: docRef.id,
          entityType: 'Customer',
          transaction: transaction,
        );
      });

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
      ).collection(FirestoreCollections.customers).snapshots();
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
      return await _shopRef(
        shopId,
      ).collection(FirestoreCollections.customers).doc(customerId).get();
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
          description: "Deleted customer $customerId",
          entityId: customerId,
          entityType: 'Customer',
          transaction: transaction,
        );
      });

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

      return await query.get();
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

      log('Customer rental stats updated: $customerId', name: logName);
    } catch (e) {
      log('Error updating customer rental stats: $e', name: logName);
      rethrow;
    }
  }
}
