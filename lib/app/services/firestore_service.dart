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

  /// INSERT INVENTORY ITEM
  Future<void> saveInventoryItem(
    String shopId,
    Map<String, dynamic> data,
  ) async {
    final docRef = shopRef(shopId).collection('inventory').doc();

    await docRef.set({...data, 'id': docRef.id});
  }

  /// GET INVENTORY ITEMS STREAM
  Future<QuerySnapshot> getInventoryPage({
    required String shopId,
    List<String>? types,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) {
    Query query = shopRef(shopId)
        .collection('inventory')
        // .orderBy('createdAt', descending: true)
        .limit(limit);

    if (types != null && types.isNotEmpty) {
      query = query.where('type', whereIn: types);
    }

    // if (lastDocument != null) {
    //   query = query.startAfterDocument(lastDocument);
    // }

    return query.get();
  }
}
