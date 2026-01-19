import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/app/models/customer_model.dart';

class CustomerService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference shopRef(String shopId) {
    return _db.collection('shops').doc(shopId);
  }

  Future<void> addCustomer(String shopId, CustomerModel customerData) async {
    final data = customerData.toMap();

    final docRef = shopRef(shopId).collection('customers').doc();
    await docRef.set({...data, 'id': docRef.id});
  }

  Stream<QuerySnapshot> getCustomersStream(String shopId) {
    return shopRef(shopId).collection('customers').snapshots();
  }

  Future<DocumentSnapshot> getCustomerOnce(String shopId, String customerId) {
    return shopRef(shopId).collection('customers').doc(customerId).get();
  }

  Future<void> updateCustomer(
    String shopId,
    String customerId,
    Map<String, dynamic> data,
  ) async {
    await shopRef(shopId).collection('customers').doc(customerId).update(data);
  }

  Future<void> deleteCustomer(String shopId, String customerId) async {
    await shopRef(shopId).collection('customers').doc(customerId).delete();
  }
}
