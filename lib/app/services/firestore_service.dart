import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  DocumentReference shopRef(String shopId) {
    return _db.collection('shops').doc(shopId);
  }

  /// ═══════════════════════════════════════════════════════════════════════
  /// NOTE: This service has been refactored for better code organization.
  ///
  /// Moved to specialized services:
  /// • Inventory operations → InventoryService
  /// • Shop member management → ShopService
  /// • Customer operations → CustomerService
  ///
  /// Keep FirestoreService minimal for any remaining generic operations.
  /// ═══════════════════════════════════════════════════════════════════════
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



