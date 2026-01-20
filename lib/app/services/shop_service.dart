import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ShopService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static const String logName = 'ShopService';

  DocumentReference _shopRef(String shopId) {
    return _db.collection('shops').doc(shopId);
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
      final shopRef = _db.collection('shops').doc();

      final batch = _db.batch();

      batch.set(shopRef, {
        'name': shopName,
        'location': location,
        'contact_number': contactNumber,
        'created_date': FieldValue.serverTimestamp(),
        'owner_admin_uid': uid,
        'shop_code': _generateShopCode(),
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
      log('Error fetching shop details: $e', name:logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // GET SHOP MEMBERS STREAM
  // ---------------------------------------------------------------------------
  Stream<QuerySnapshot> getShopMembers(String shopId) {
    try {
      log('Getting shop members stream for: $shopId', name: logName);
      return _shopRef(shopId).collection('members').snapshots();
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
        'role': role,
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
