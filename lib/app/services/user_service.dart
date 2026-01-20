import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../utils/constants/a_enums.dart';
import '../../utils/storage/app_storage.dart';
import '../models/user_model.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AppLocalStorage _storage = AppLocalStorage();
  static const String logName = 'UserService';

  // ---------------------------------------------------------------------------
  // AUTH GETTERS
  // ---------------------------------------------------------------------------
  User? get currentUser => _auth.currentUser;

  // ---------------------------------------------------------------------------
  // GET SHOP ID FROM LOCAL STORAGE
  // ---------------------------------------------------------------------------
  Future<String?> getShopIdFromStorage() async {
    try {
      log('Getting shop ID from storage', name: logName);
      return _storage.readData('shop_id') as String?;
    } catch (e) {
      log('Error getting shop ID from storage: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // REGISTER ADMIN WITH SHOP
  // ---------------------------------------------------------------------------
  Future<void> registerAdminWithShop({
    required String uid,
    required String shopName,
    required String shopLocation,
    required String shopContactNumber,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      log('Registering admin user with shop', name: logName);
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
      log('Admin registered successfully', name: logName);
    } catch (e) {
      log('Error registering admin: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // REGISTER STAFF
  // ---------------------------------------------------------------------------
  Future<void> registerStaff({
    required String shopId,
    required String uid,
    required String name,
    required String email,
    required String phone,
  }) async {
    try {
      log('Registering staff user for shop: $shopId', name: logName);
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
      log('Staff registered successfully', name: logName);
    } catch (e) {
      log('Error registering staff: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // FETCH USER
  // ---------------------------------------------------------------------------
  Future<UserModel?> getUser(String userId) async {
    try {
      log('Fetching user: $userId', name: logName);
      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists) return null;

      return UserModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      log('Error fetching user: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // FETCH USER MEMBERSHIP
  // ---------------------------------------------------------------------------
  Future<UserModel> getUserMembership(String userId) async {
    try {
      log('Fetching user membership: $userId', name: logName);
      final doc = await _db.collection('users').doc(userId).get();

      if (!doc.exists) {
        throw Exception('User profile not found');
      }

      final user = UserModel.fromMap(doc.data()!, doc.id);

      if (user.shopId == null) {
        throw Exception('User not assigned to a shop');
      }

      return user;
    } catch (e) {
      log('Error fetching user membership: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // FETCH USER'S SHOP ID
  // ---------------------------------------------------------------------------
  Future<String> getShopId() async {
    try {
      log('Fetching shop ID for current user', name: logName);
      final doc = await _db
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      return doc['shop_id'] as String;
    } catch (e) {
      log('Error fetching shop ID: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // CHECK IF USER IS ACTIVE
  // ---------------------------------------------------------------------------
  Future<bool> isUserActive(String userId) async {
    try {
      log('Checking if user is active: $userId', name: logName);
      final doc = await _db.collection('users').doc(userId).get();
      if (!doc.exists) return false;

      return doc['is_active'] == true;
    } catch (e) {
      log('Error checking user status: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // CHECK IF USER EXISTS BY EMAIL
  // ---------------------------------------------------------------------------
  Future<bool> userExistsByEmail(String email) async {
    try {
      log('Checking if user exists: $email', name: logName);
      final snap = await _db
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      return snap.docs.isNotEmpty;
    } catch (e) {
      log('Error checking user existence: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE USER PROFILE
  // ---------------------------------------------------------------------------
  Future<void> updateUserProfile({
    required String userId,
    String? name,
    String? phone,
  }) async {
    try {
      log('Updating user profile: $userId', name: logName);
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (phone != null) data['phone'] = phone;

      await _db.collection('users').doc(userId).update(data);
      log('User profile updated: $userId', name: logName);
    } catch (e) {
      log('Error updating user profile: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE USER ACTIVE STATUS
  // ---------------------------------------------------------------------------
  Future<void> updateUserStatus({
    required String userId,
    required String shopId,
    required bool isActive,
  }) async {
    try {
      log('Updating user status: $userId, isActive: $isActive', name: logName);
      final batch = _db.batch();

      // Update global user profile
      batch.update(_db.collection('users').doc(userId), {
        'is_active': isActive,
      });

      // Update minimal member info for real-time listing
      batch.update(
        _db.collection('shops').doc(shopId).collection('members').doc(userId),
        {'is_active': isActive},
      );

      await batch.commit();
      log('User status updated: $userId', name: logName);
    } catch (e) {
      log('Error updating user status: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE USER VERIFICATION STATUS
  // ---------------------------------------------------------------------------
  Future<void> updateUserVerification({
    required String userId,
    required String shopId,
    required bool verified,
  }) async {
    try {
      log(
        'Updating user verification: $userId, verified: $verified',
        name: logName,
      );
      final batch = _db.batch();

      // Update global user profile
      batch.update(_db.collection('users').doc(userId), {'verified': verified});

      // Update minimal member info for real-time listing
      batch.update(
        _db.collection('shops').doc(shopId).collection('members').doc(userId),
        {'verified': verified},
      );

      await batch.commit();
      log('User verification updated: $userId', name: logName);
    } catch (e) {
      log('Error updating user verification: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // REMOVE USER FROM SHOP
  // ---------------------------------------------------------------------------
  Future<void> removeUserFromShop({
    required String shopId,
    required String userId,
  }) async {
    try {
      log('Removing user from shop: $shopId, userId: $userId', name: logName);
      await _db
          .collection('shops')
          .doc(shopId)
          .collection('members')
          .doc(userId)
          .delete();
      log('User removed from shop: $userId', name: logName);
    } catch (e) {
      log('Error removing user from shop: $e', name: logName);
      rethrow;
    }
  }
}
