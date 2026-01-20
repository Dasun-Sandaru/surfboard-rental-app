import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/customer_model.dart';

class CustomerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String logName = 'CustomerService';

  DocumentReference _shopRef(String shopId) {
    return _db.collection('shops').doc(shopId);
  }

  // ---------------------------------------------------------------------------
  // CREATE CUSTOMER
  // ---------------------------------------------------------------------------
  Future<String> addCustomer(String shopId, CustomerModel customerData) async {
    try {
      log('Creating new customer for shop: $shopId', name: logName);

      final data = customerData.toMap();
      final docRef = _shopRef(shopId).collection('customers').doc();

      await docRef.set({
        ...data,
        'id': docRef.id,
        'created_at': FieldValue.serverTimestamp(),
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
      return _shopRef(shopId).collection('customers').snapshots();
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
      ).collection('customers').doc(customerId).get();
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

      await _shopRef(shopId).collection('customers').doc(customerId).update({
        ...data.toMap(),
        'updated_at': FieldValue.serverTimestamp(),
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
      await _shopRef(shopId).collection('customers').doc(customerId).delete();
      log('Customer deleted: $customerId', name: logName);
    } catch (e) {
      log('Error deleting customer: $e', name: logName);
      rethrow;
    }
  }
}
