import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Global user data
  Future<DocumentSnapshot> getGlobalUser(String uid) {
    return _db.collection('users_global').doc(uid).get();
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
}
