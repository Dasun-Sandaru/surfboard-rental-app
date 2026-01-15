import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference shopRef(String shopId) {
    return _db.collection('shops').doc(shopId);
  }

  /// GET SHOP USERS STREAM
  Stream<QuerySnapshot> getShopUsers(String shopId) {
    return shopRef(shopId).collection('members').snapshots();
  }

  // INSERT INVENTORY ITEM
  Future<void> saveInventoryItem(String shopId, Map<String, dynamic> data) async {
  final docRef = shopRef(shopId).collection('inventory').doc();

  await docRef.set({
    ...data,
    'id': docRef.id,
  });
}

}
