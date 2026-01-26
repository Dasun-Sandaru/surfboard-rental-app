import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String logName = 'InventoryService';

  DocumentReference _shopRef(String shopId) {
    return _db.collection('shops').doc(shopId);
  }

  // ---------------------------------------------------------------------------
  // FETCH INVENTORY PAGE (with pagination and filters)
  // ---------------------------------------------------------------------------
  Future<QuerySnapshot> getInventoryPage({
    required String shopId,
    required List<String> types,
    required List<String> statuses,
    DocumentSnapshot? lastDocument,
    String? sizeFeet,
    String? sizeInches,
    bool isLessThan = false,
    int pageSize = 10,
  }) async {
    try {
      log('Fetching inventory page for shop: $shopId', name: logName);

      Query query = _shopRef(shopId).collection('inventory');

      // Apply filters
      if (types.isNotEmpty) {
        query = query.where('type', whereIn: types);
      }

      if (statuses.isNotEmpty) {
        query = query.where('status', whereIn: statuses);
      }

      // Size filter
      if (sizeFeet != null && sizeFeet.isNotEmpty) {
        final sizeValue =
            int.tryParse(sizeFeet) ?? 0; // feet as integer for comparison
        if (isLessThan) {
          query = query.where('size_feet', isLessThan: sizeValue);
        } else {
          query = query.where('size_feet', isGreaterThanOrEqualTo: sizeValue);
        }
      }

      if (sizeInches != null && sizeInches.isNotEmpty) {
        final sizeValue = int.tryParse(sizeInches) ?? 0;
        if (isLessThan) {
          query = query.where('size_inches', isLessThan: sizeValue);
        } else {
          query = query.where('size_inches', isGreaterThanOrEqualTo: sizeValue);
        }
      }

      // Pagination
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      // Execute query
      final snapshot = await query.limit(pageSize).get();

      log('Fetched ${snapshot.docs.length} inventory items', name: logName);
      return snapshot;
    } catch (e) {
      log('Error fetching inventory page: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // GET SINGLE INVENTORY ITEM (Stream)
  // ---------------------------------------------------------------------------
  Stream<DocumentSnapshot> getInventoryItem({
    required String shopId,
    required String itemId,
  }) {
    try {
      log('Getting stream for item: $itemId', name: logName);
      return _shopRef(shopId).collection('inventory').doc(itemId).snapshots();
    } catch (e) {
      log('Error creating inventory item stream: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // GET SINGLE INVENTORY ITEM (Once)
  // ---------------------------------------------------------------------------
  Future<DocumentSnapshot> getInventoryItemOnce({
    required String shopId,
    required String itemId,
  }) async {
    try {
      log('Fetching inventory item once: $itemId', name: logName);
      return await _shopRef(shopId).collection('inventory').doc(itemId).get();
    } catch (e) {
      log('Error fetching inventory item: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // CREATE INVENTORY ITEM
  // ---------------------------------------------------------------------------
  Future<String> createInventoryItem({
    required String shopId,
    required Map<String, dynamic> data,
  }) async {
    try {
      log('Creating new inventory item', name: logName);

      final docRef = _shopRef(shopId).collection('inventory').doc();
      final itemData = {
        ...data,
        'id': docRef.id,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      await docRef.set(itemData);

      log('Inventory item created: ${docRef.id}', name: logName);
      return docRef.id;
    } catch (e) {
      log('Error creating inventory item: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE INVENTORY ITEM
  // ---------------------------------------------------------------------------
  Future<void> updateInventoryItem({
    required String shopId,
    required String itemId,
    required Map<String, dynamic> data,
  }) async {
    try {
      log('Updating inventory item: $itemId', name: logName);

      final updateData = {...data, 'updated_at': FieldValue.serverTimestamp()};

      await _shopRef(
        shopId,
      ).collection('inventory').doc(itemId).update(updateData);

      log('Inventory item updated: $itemId', name: logName);
    } catch (e) {
      log('Error updating inventory item: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE INVENTORY ITEM
  // ---------------------------------------------------------------------------
  Future<void> deleteInventoryItem({
    required String shopId,
    required String itemId,
  }) async {
    try {
      log('Deleting inventory item: $itemId', name: logName);

      await _shopRef(shopId).collection('inventory').doc(itemId).delete();

      log('Inventory item deleted: $itemId', name: logName);
    } catch (e) {
      log('Error deleting inventory item: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE INVENTORY STATUS
  // ---------------------------------------------------------------------------
  Future<void> updateInventoryStatus({
    required String shopId,
    required String itemId,
    required String status,
  }) async {
    try {
      log('Updating inventory status for $itemId to $status', name: logName);

      await _shopRef(shopId).collection('inventory').doc(itemId).update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });

      log('Inventory status updated: $itemId', name: logName);
    } catch (e) {
      log('Error updating inventory status: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // ADD DAMAGE FEE TO INVENTORY ITEM
  // ---------------------------------------------------------------------------
  Future<void> addDamageFeeToItem({
    required String shopId,
    required String itemId,
    required Map<String, dynamic> feeData,
  }) async {
    try {
      log('Adding damage fee to item: $itemId', name: logName);

      final itemRef = _shopRef(shopId).collection('inventory').doc(itemId);
      final feesCollection = itemRef.collection('damage_fees');

      await feesCollection.add({
        ...feeData,
        'created_at': FieldValue.serverTimestamp(),
      });

      log('Damage fee added to item: $itemId', name: logName);
    } catch (e) {
      log('Error adding damage fee: $e', name: logName);
      rethrow;
    }
  }

  Future<int> getInventoryCountByStatus(String shopId, String status) async {
    try {
      log(
        'Counting inventory with status $status for shop: $shopId',
        name: logName,
      );
      final aggregateQuery = await _shopRef(shopId)
          .collection('inventory')
          .where('status', isEqualTo: status)
          .count()
          .get();
      return aggregateQuery.count ?? 0;
    } catch (e) {
      log('Error counting inventory: $e', name: logName);
      rethrow;
    }
  }
}
