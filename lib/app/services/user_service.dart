import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/constants/a_enums.dart';
import '../../utils/storage/app_storage.dart';
import '../models/user_model.dart';

class UserService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  final _storage = AppLocalStorage();

  /// AUTH
  User? get currentUser => _auth.currentUser;

  /// USER SHOP ID FROM LOCAL STORAGE
  Future<String?> getShopIdFromStorage() async =>
      _storage.readData('shop_id') as String?;

  /// REGISTER ADMIN WITH SHOP
  Future<void> registerAdminWithShop({
    required String uid,
    required String shopName,
    required String shopLocation,
    required String shopContactNumber,
    required String name,
    required String email,
    required String phone,
  }) async {
    final batch = _db.batch();

    final shopRef = _db.collection('shops').doc();
    final userRef = _db.collection('users').doc(uid);
    final memberRef = shopRef.collection('members').doc(uid);

    batch.set(userRef, {
      'name': name,
      'email': email,
      'phone': phone,
      'is_active': true,
      'verified': true,
      'role': UserRole.admin.name,
      'shop_id': shopRef.id,
      'created_at': FieldValue.serverTimestamp(),
    });

    batch.set(shopRef, {
      'name': shopName,
      'location': shopLocation,
      'contact_number': shopContactNumber,
      'created_at': FieldValue.serverTimestamp(),
      'owner_admin_uid': uid,
    });

    batch.set(memberRef, {
      'name': name,
      'email': email,
      'phone': phone,
      'role': UserRole.admin.name,
      'is_active': true,
      'verified': true,
      'created_at': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// REGISTER STAFF
  Future<void> registerStaff({
    required String shopId,
    required String uid,
    required String name,
    required String email,
    required String phone,
  }) async {
    final batch = _db.batch();

    final userRef = _db.collection('users').doc(uid);
    final memberRef = _db
        .collection('shops')
        .doc(shopId)
        .collection('members')
        .doc(uid);

    batch.set(userRef, {
      'name': name,
      'email': email,
      'phone': phone,
      'role': UserRole.staff.name,
      'shop_id': shopId,
      'is_active': true,
      'verified': false,
      'created_at': FieldValue.serverTimestamp(),
    });

    batch.set(memberRef, {
      'name': name,
      'email': email,
      'phone': phone,
      'role': UserRole.staff.name,
      'is_active': true,
      'verified': false,
      'created_at': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// FETCH USER
  Future<UserModel?> getUser(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return null;

    return UserModel.fromMap(doc.data()!, doc.id);
  }

  /// Fetch USER'S ROLE
  Future<UserModel> getUserMembership(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();

    if (!doc.exists) {
      throw Exception('User profile not found');
    }

    final user = UserModel.fromMap(doc.data()!, doc.id);

    if (user.shopId == null) {
      throw Exception('User not assigned to a shop');
    }

    return user;
  }

  /// FETCH USER'S SHOP ID
  Future<String> getShopId() async {
    final doc = await _db.collection('users').doc(_auth.currentUser!.uid).get();
    return doc['shop_id'] as String;
  }

  /// FETCH SHOP MEMBER STATUS
  Future<bool> isUserActive(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (!doc.exists) return false;

    return doc['is_active'] == true;
  }

  /// CHECK IF USER EXISTS BY EMAIL
  Future<bool> userExistsByEmail(String email) async {
    final snap = await _db
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    return snap.docs.isNotEmpty;
  }

  /// UPDATE USER PROFILE
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

  /// CHANGE ACTIVE STATUS
  Future<void> updateUserStatus({
    required String userId,
    required String shopId,
    required bool isActive,
  }) async {
    final batch = _db.batch();

    // Update global user profile
    batch.update(_db.collection('users').doc(userId), {'is_active': isActive});

    // Update minimal member info for real-time listing
    batch.update(
      _db.collection('shops').doc(shopId).collection('members').doc(userId),
      {'is_active': isActive},
    );

    await batch.commit();
  }

  /// CHANGE VERIFICATION STATUS
  Future<void> updateUserVerification({
    required String userId,
    required String shopId,
    required bool verified,
  }) async {
    final batch = _db.batch();

    // Update global user profile
    batch.update(_db.collection('users').doc(userId), {'verified': verified});

    // Update minimal member info for real-time listing
    batch.update(
      _db.collection('shops').doc(shopId).collection('members').doc(userId),
      {'verified': verified},
    );

    await batch.commit();
  }

  /// REMOVE USER FROM SHOP
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
}
