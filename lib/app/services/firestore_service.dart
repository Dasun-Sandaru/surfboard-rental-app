import 'dart:developer';

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
    String? sizeFeet,
    String? sizeInches,
    bool? isLessThan,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) {
    int totalInches = 0;

    Query query = shopRef(
      shopId,
    ).collection('inventory').orderBy('size_total_inches').limit(limit);

    if (types != null && types.isNotEmpty) {
      query = query.where('type', whereIn: types);
    }

    if (sizeFeet != null && sizeFeet.isNotEmpty) {
      final feet = int.tryParse(sizeFeet) ?? 0;
      final inches = int.tryParse(sizeInches ?? '0') ?? 0;

      totalInches = (feet * 12) + inches;

      if (isLessThan == true) {
        query = query.where(
          'size_total_inches',
          isLessThanOrEqualTo: totalInches.toString(),
        );
      } else {
        query = query.where(
          'size_total_inches',
          isGreaterThanOrEqualTo: totalInches.toString(),
        );
      }
    }

    // query = query.where('size_total_inches', isLessThanOrEqualTo: '76');

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    log(
      'Query Parameters: types=$types, sizeFeet=$sizeFeet, sizeInches=$sizeInches,totalInches=$totalInches, isLessThan=$isLessThan,lastDocument=${lastDocument?.id}, limit=$limit',
    );

    return query.get();
  }


}
