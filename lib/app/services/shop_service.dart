import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/firestore/firestore_collections.dart';
import '../../data/firestore/firestore_fields.dart';

class ShopService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String logName = 'ShopService';

  DocumentReference _shopRef(String shopId) {
    return _db.collection(FirestoreCollections.shops).doc(shopId);
  }

  // ---------------------------------------------------------------------------
  // CREATE SHOP WITH OWNER
  // ---------------------------------------------------------------------------
  Future<String> createShopWithOwner({
    required String shopName,
    required String location,
    required String contactNumber,
  }) async {
    try {
      log('Creating new shop: $shopName', name: logName);
      final uid = _auth.currentUser!.uid;
      final shopRef = _db.collection(FirestoreCollections.shops).doc();

      final batch = _db.batch();

      batch.set(shopRef, {
        FirestoreFields.businessName: shopName,
        FirestoreFields.location: location,
        FirestoreFields.contactNumber: contactNumber,
        FirestoreFields.createdAt: FieldValue.serverTimestamp(),
        FirestoreFields.ownerAdminUid: uid,
        FirestoreFields.shopCode: _generateShopCode(),
      });

      await batch.commit();
      log('Shop created: ${shopRef.id}', name: logName);
      return shopRef.id;
    } catch (e) {
      log('Error creating shop: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // GET SHOP DETAILS ONCE
  // ---------------------------------------------------------------------------
  Future<DocumentSnapshot> getShop(String shopId) {
    try {
      log('Fetching shop details once for: $shopId', name: logName);
      return _shopRef(shopId).get();
    } catch (e) {
      log('Error fetching shop details: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE SHOP DETAILS
  // ---------------------------------------------------------------------------
  Future<void> updateShop({
    required String shopId,
    String? name,
    String? location,
    String? contactNumber,
  }) async {
    try {
      log('Updating shop details for: $shopId', name: logName);
      final data = <String, dynamic>{};
      if (name != null) data[FirestoreFields.businessName] = name;
      if (location != null) data[FirestoreFields.location] = location;
      if (contactNumber != null) {
        data[FirestoreFields.contactNumber] = contactNumber;
      }

      await _shopRef(shopId).update(data);
      log('Shop details updated for: $shopId', name: logName);
    } catch (e) {
      log('Error updating shop details: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE SHOP FIELDS GENERIC
  // ---------------------------------------------------------------------------
  Future<void> updateShopFields(
    String shopId,
    Map<String, dynamic> data,
  ) async {
    try {
      log('Updating shop fields for: $shopId', name: logName);
      await _shopRef(shopId).update(data);
      log('Shop fields updated for: $shopId', name: logName);
    } catch (e) {
      log('Error updating shop fields: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // GET SHOP MEMBERS STREAM
  // ---------------------------------------------------------------------------
  Stream<QuerySnapshot> getShopMembers(String shopId) {
    try {
      log('Getting shop members stream for: $shopId', name: logName);
      return _shopRef(
        shopId,
      ).collection('members').snapshots(); // Constant for 'members' ??
    } catch (e) {
      log('Error creating shop members stream: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // GET SHOP MEMBERS ONCE
  // ---------------------------------------------------------------------------
  Future<QuerySnapshot> getShopMembersOnce(String shopId) async {
    try {
      log('Fetching shop members once for: $shopId', name: logName);
      return await _shopRef(shopId).collection('members').get();
    } catch (e) {
      log('Error fetching shop members: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // ADD MEMBER TO SHOP
  // ---------------------------------------------------------------------------
  Future<void> addMemberToShop({
    required String shopId,
    required String userId,
    required String role,
  }) async {
    try {
      log('Adding member to shop: $shopId, userId: $userId', name: logName);
      await _shopRef(shopId).collection('members').doc(userId).set({
        FirestoreFields.role: role,
        'added_at': FieldValue.serverTimestamp(),
      });
      log('Member added to shop: $userId', name: logName);
    } catch (e) {
      log('Error adding member: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // REMOVE MEMBER FROM SHOP
  // ---------------------------------------------------------------------------
  Future<void> removeMemberFromShop({
    required String shopId,
    required String userId,
  }) async {
    try {
      log('Removing member from shop: $shopId, userId: $userId', name: logName);
      await _shopRef(shopId).collection('members').doc(userId).delete();
      log('Member removed from shop: $userId', name: logName);
    } catch (e) {
      log('Error removing member: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // HELPER METHODS
  // ---------------------------------------------------------------------------
  String _generateShopCode() {
    final num = DateTime.now().millisecondsSinceEpoch % 10000;
    return 'SURF-$num';
  }
}