import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// ======================
  /// AUTH
  /// ======================
  User? get currentUser => _auth.currentUser;

  /// ======================
  /// USER PROFILE (GLOBAL)
  /// ======================
  ///
  Future<void> createUserProfile({
    required String userId,
    required String name,
    required String email,
    required String phone,
    required String shopId,
    required bool isAdmin,
  }) async {
    await _db.collection('users').doc(userId).set({
      'name': name,
      'email': email,
      'phone': phone,
      'is_active': true,
      'verified': isAdmin ? true : false,
      'role': isAdmin ? 'admin' : 'staff',
      'shop_id': shopId,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Future<UserModel?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!, doc.id);
  }

  /// Fetch role
  Future<({String shopId, String role})> getUserMembership(
    String userId,
  ) async {
    final doc = await _db.collection('users').doc(userId).get();

    if (!doc.exists) {
      throw Exception('User profile not found');
    }

    final data = doc.data()!;

    final role = data['role'] as String?;
    final shopId = data['shop_id'] as String?;

    if (role == null || shopId == null) {
      throw Exception('User not assigned to a shop');
    }

    return (role: role, shopId: shopId);
  }

  Future<String> getShopId() async {
    final doc = await _db.collection('users').doc(_auth.currentUser!.uid).get();
    return doc['shop_id'] as String;
  }

  Future<bool> isUserActive(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return false;

    return doc['is_active'] == true;
  }

  Future<bool> userExistsByEmail(String email) async {
    final snap = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return snap.docs.isNotEmpty;
  }

  /// ======================
  /// CREATE SHOP (ADMIN)
  /// ======================
  Future<String> createShopWithOwner({
    required String shopName,
    required String location,
    required String contactNumber,
  }) async {
    final uid = _auth.currentUser!.uid;
    final shopRef = _db.collection('shops').doc();

    final batch = _db.batch();

    /// Shop
    batch.set(shopRef, {
      'name': shopName,
      'location': location,
      'contact_number': contactNumber,
      'created_date': FieldValue.serverTimestamp(),
      'owner_admin_uid': uid,
      'shop_code': _generateShopCode(),
    });

    /// Membership
    batch.set(shopRef.collection('members').doc(uid), {
      'role': 'admin',
      'added_at': FieldValue.serverTimestamp(),
      'uid': uid,
    });

    await batch.commit();
    return shopRef.id;
  }

  /// ======================
  /// ADD STAFF TO SHOP
  /// ======================
  Future<void> addStaffToShop({
    required String shopId,
    required String userId,
  }) async {
    await _db
        .collection('shops')
        .doc(shopId)
        .collection('members')
        .doc(userId)
        .set({
          'role': 'staff',
          'added_at': FieldValue.serverTimestamp(),
          'uid': userId,
        });
  }

  /// ======================
  /// UPDATE USER PROFILE
  /// ======================
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone'] = phone;

    await _db.collection('users').doc(userId).update(data);
  }

  /// ======================
  /// CHANGE ACTIVE STATUS
  /// ======================
  Future<void> changeUserActiveStatus(String userId, bool isActive) async {
    await _db.collection('users').doc(userId).update({'is_active': isActive});
  }

  /// ======================
  /// REMOVE USER FROM SHOP
  /// ======================
  Future<void> removeUserFromShop({
    required String shopId,
    required String userId,
  }) async {
    await _db
        .collection('shops')
        .doc(shopId)
        .collection('members')
        .doc(userId)
        .delete();
  }

  /// ======================
  /// UTIL
  /// ======================
  String _generateShopCode() {
    final num = DateTime.now().millisecondsSinceEpoch % 10000;
    return 'SURF-$num';
  }
}
