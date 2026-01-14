import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Global user data
  Stream<DocumentSnapshot> getGlobalUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<DocumentSnapshot> getGlobalUser(String uid) {
    return _db.collection('users').doc(uid).get();
  }

  // Shop reference
  DocumentReference shopRef(String shopId) {
    return _db.collection('shops').doc(shopId);
  }

  // Customers
  Future<void> addCustomer(String shopId, Map<String, dynamic> data) {
    return shopRef(shopId).collection('customers').add(data);
  }

  // Inventory
  Stream<QuerySnapshot> getInventory(String shopId) {
    return shopRef(shopId).collection('inventory').snapshots();
  }

  // Rentals
  Future<void> createRental(String shopId, Map<String, dynamic> data) {
    return shopRef(shopId).collection('rentals').add(data);
  }

  // ------------------------------------------------------

  // Shop data
  Future<DocumentSnapshot> getShop(String shopId) {
    return _db.collection('shops').doc(shopId).get();
  }

  // Shop users
  Stream<DocumentSnapshot> getShopUserStream(String shopId, String uid) {
    return shopRef(shopId).collection('members').doc(uid).snapshots();
  }

  Stream<QuerySnapshot> getShopUsers(String shopId) {
    return shopRef(shopId).collection('members').snapshots();
  }
}
