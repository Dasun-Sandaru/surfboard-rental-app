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
    List<String>? statuses,
    String? sizeFeet,
    String? sizeInches,
    bool? isLessThan,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) {
    int totalInches = 0;

    // Start with the base query for the shop's inventory, ordered by size_total_inches
    // and limited by the specified count.
    Query query = shopRef(
      shopId,
    ).collection('inventory').orderBy('size_total_inches').limit(limit);

    // Apply type filtering if types are provided
    if (types != null && types.isNotEmpty) {
      query = query.where('type', whereIn: types);
    }

    // Apply status filtering if statuses are provided
    if (statuses != null && statuses.isNotEmpty) {
      query = query.where('status', whereIn: statuses);
    }

    // Apply size filtering if sizeFeet is provided
    if (sizeFeet != null && sizeFeet.isNotEmpty) {
      final feet = int.tryParse(sizeFeet) ?? 0;
      final inches = int.tryParse(sizeInches ?? '0') ?? 0;

      totalInches = (feet * 12) + inches;

      // Apply 'less than or equal to' or 'greater than or equal to' based on isLessThan flag
      if (isLessThan == true) {
        query = query.where(
          'size_total_inches',
          isLessThanOrEqualTo: totalInches, // Corrected: Pass int directly
        );
      } else {
        query = query.where(
          'size_total_inches',
          isGreaterThanOrEqualTo: totalInches, // Corrected: Pass int directly
        );
      }
    }

    // Apply pagination starting after the last fetched document
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    // Log the query parameters for debugging purposes
    log(
      'Query Parameters: types=$types, statuses=$statuses, sizeFeet=$sizeFeet, sizeInches=$sizeInches, totalInches=$totalInches, isLessThan=$isLessThan, lastDocument=${lastDocument?.id}, limit=$limit',
      name: 'InventoryService', // Adding a name for easier log filtering
    );

    // Execute the query and return the result
    return query.get();
  }

  /// GET SINGLE INVENTORY ITEM
  Stream<DocumentSnapshot> getInventoryItem({
    required String shopId,
    required String itemId,
  }) {
    return shopRef(shopId).collection('inventory').doc(itemId).snapshots();
  }

  /// UPDATE INVENTORY ITEM
  Future<void> updateInventoryItem({
    required String shopId,
    required String itemId,
    required Map<String, dynamic> data,
  }) async {
    await shopRef(shopId).collection('inventory').doc(itemId).update(data);
  }

  /// GET SINGLE INVENTORY ITEM (ONE TIME)
  Future<DocumentSnapshot> getInventoryItemOnce({
    required String shopId,
    required String itemId,
  }) {
    return shopRef(shopId).collection('inventory').doc(itemId).get();
  }
}


  // // Example 1: Get first page of all inventory for a shop
  // print('Fetching initial inventory...');
  // QuerySnapshot snapshot1 = await inventoryService.getInventoryPage(
  //   shopId: 'shop123',
  //   limit: 2,
  // );
  // snapshot1.docs.forEach((doc) => print('Doc 1: ${doc.data()}'));
  // print('---');

  // // Example 2: Get next page
  // print('Fetching next page of inventory...');
  // QuerySnapshot snapshot2 = await inventoryService.getInventoryPage(
  //   shopId: 'shop123',
  //   lastDocument: snapshot1.docs.last,
  //   limit: 2,
  // );
  // snapshot2.docs.forEach((doc) => print('Doc 2: ${doc.data()}'));
  // print('---');

  // // Example 3: Filter by type and size (e.g., surfboards less than 7 feet)
  // print('Fetching surfboards less than 7 feet...');
  // QuerySnapshot filteredSnapshot = await inventoryService.getInventoryPage(
  //   shopId: 'shop123',
  //   types: ['surfboard'],
  //   sizeFeet: '6',
  //   sizeInches: '11', // 6 feet 11 inches = 83 inches
  //   isLessThan: true,
  //   limit: 5,
  // );
  // filteredSnapshot.docs.forEach((doc) => print('Filtered Doc: ${doc.data()}'));
  // print('---');

  // // Example 4: Filter by type and size (e.g., paddleboards greater than or equal to 10 feet)
  // print('Fetching paddleboards greater than or equal to 10 feet...');
  // QuerySnapshot filteredSnapshot2 = await inventoryService.getInventoryPage(
  //   shopId: 'shop123',
  //   types: ['paddleboard'],
  //   sizeFeet: '10',
  //   sizeInches: '0', // 10 feet 0 inches = 120 inches
  //   isLessThan: false,
  //   limit: 5,
  // );
  // filteredSnapshot2.docs.forEach((doc) => print('Filtered Doc 2: ${doc.data()}'));
  // print('---');



