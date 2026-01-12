import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// ======================
  /// GET CURRENT USER
  /// ======================
  User? get currentUser => _auth.currentUser;

  /// ======================
  /// GET USER GLOBAL DATA
  /// ======================

  Future<UserModel?> getUserGlobalData(String userId) async {
    final DocumentSnapshot doc = await _firestore
        .collection('users_global')
        .doc(userId)
        .get();

    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  /// ======================
  /// GET USER ROLE
  /// ======================

  Future<String?> getUserRole() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users_global').doc(uid).get();

    if (!doc.exists) return null;

    return doc.data()?['role'] as String?;
  }

  /// ======================
  /// GET SHOP ID
  /// ======================
  Future<String?> getShopId() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    final doc = await _firestore.collection('users_global').doc(uid).get();

    if (!doc.exists) return null;

    return doc.data()?['shop_id'] as String?;
  }

  /// ======================
  /// CHECK IF USER EXISTS BY EMAIL
  /// ======================
  Future<bool> userExistsByEmail(String email) async {
    final snapshot = await _firestore
        .collection('users_global')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }

  /// ======================
  /// CREATE SHOP (ADMIN)
  /// ======================
  Future<void> createShopWithOwner({
    required String userId,
    required String shopName,
    required String location,
    required String contactNumber,
    required String ownerName,
    required String ownerEmail,
    required String phone,
  }) async {
    final shopRef = _firestore.collection('shops').doc();
    final shopId = shopRef.id;
    final shopCode = _generateShopCode();

    final batch = _firestore.batch();

    batch.set(shopRef, {
      'name': shopName,
      'location': location,
      'contact_number': contactNumber,
      'created_date': FieldValue.serverTimestamp(),
      'owner_admin_uid': userId,
      'shop_code': shopCode,
    });

    batch.set(_firestore.collection('users_global').doc(userId), {
      'name': ownerName,
      'email': ownerEmail,
      'role': 'admin',
      'shop_id': shopId,
      'phone': phone,
      'is_active': true,
      'created_at': FieldValue.serverTimestamp(),
    });

    batch.set(shopRef.collection('users').doc(userId), {
      'name': ownerName,
      'email': ownerEmail,
      'role': 'admin',
      'phone': phone,
      'is_active': true,
      'created_at': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// ======================
  /// CREATE STAFF
  /// ======================
  Future<void> createStaffUser({
    required String userId,
    required String shopId,
    required String name,
    required String email,
    required String phone,
  }) async {
    final batch = _firestore.batch();

    batch.set(_firestore.collection('users_global').doc(userId), {
      'name': name,
      'email': email,
      'role': 'staff',
      'shop_id': shopId,
      'phone': phone,
      'is_active': true,
      'created_at': FieldValue.serverTimestamp(),
    });

    batch.set(
      _firestore
          .collection('shops')
          .doc(shopId)
          .collection('users')
          .doc(userId),
      {
        'name': name,
        'email': email,
        'role': 'staff',
        'phone': phone,
        'verified': false,
        'is_active': true,
        'created_at': FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();
  }

  /// ======================
  /// CHANGE ACTIVE STATUS
  /// ======================
  Future<void> changeActiveStatus(
    String userId,
    String shopId,
    bool isActive,
  ) async {
    final batch = _firestore.batch();

    batch.update(_firestore.collection('users_global').doc(userId), {
      'is_active': isActive,
    });

    batch.update(
      _firestore
          .collection('shops')
          .doc(shopId)
          .collection('users')
          .doc(userId),
      {'is_active': isActive},
    );

    await batch.commit();
  }

  /// ======================
  /// DELETE USER
  /// ======================
  Future<void> deleteUser(String userId, String shopId) async {
    final batch = _firestore.batch();
    batch.update(_firestore.collection('users_global').doc(userId), {
      'is_active': false,
    });
    batch.update(
      _firestore
          .collection('shops')
          .doc(shopId)
          .collection('users')
          .doc(userId),
      {'is_active': false},
    );

    await batch.commit();
  }

  String _generateShopCode() {
    final num = DateTime.now().millisecondsSinceEpoch % 10000;
    return 'SURF-$num';
  }
}
