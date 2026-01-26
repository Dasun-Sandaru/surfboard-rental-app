import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_collections.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';

import '../models/customer_model.dart';

class CustomerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String logName = 'CustomerService';

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

      await docRef.set({
        ...data,
        FirestoreFields.id: docRef.id,
        FirestoreFields.createdAt: FieldValue.serverTimestamp(),
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
      await _shopRef(
        shopId,
      ).collection(FirestoreCollections.customers).doc(customerId).delete();
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
              'name_lowercase', // Needs optimization (TODO: add to FirestoreFields if used widely)
              isGreaterThanOrEqualTo: searchTerm.toLowerCase(),
            )
            .where('name_lowercase', isLessThan: '${searchTerm.toLowerCase()}z')
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
}
