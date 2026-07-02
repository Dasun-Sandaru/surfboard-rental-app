import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/firestore/firestore_collections.dart';
import '../../data/firestore/firestore_fields.dart';

import '../../utils/constants/a_enums.dart';
import '../../utils/storage/app_storage.dart';
import '../models/user_model.dart';
import 'agreement_template_service.dart';
import 'firestore_usage_service.dart';

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AppLocalStorage _storage = AppLocalStorage();
  static const String logName = 'UserService';

  // ---------------------------------------------------------------------------
  // AUTH GETTERS
  // ---------------------------------------------------------------------------
  User? get currentUser => _auth.currentUser;
  String? get currentUid => _auth.currentUser?.uid;

  // ---------------------------------------------------------------------------
  // GET SHOP ID FROM LOCAL STORAGE
  // ---------------------------------------------------------------------------
  Future<String?> getShopIdFromStorage() async {
    try {
      log('Getting shop ID from storage', name: logName);
      return _storage.readData(FirestoreFields.shopId) as String?;
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

      final shopRef = _db.collection(FirestoreCollections.shops).doc();
      final userRef = _db.collection(FirestoreCollections.users).doc(uid);
      final memberRef = shopRef.collection('members').doc(uid);

      batch.set(userRef, {
        FirestoreFields.name: name,
        FirestoreFields.email: email,
        FirestoreFields.phone: phone,
        FirestoreFields.isActive: true,
        FirestoreFields.verified: true,
        FirestoreFields.role: UserRole.admin.name,
        FirestoreFields.shopId: shopRef.id,
        FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      });

      batch.set(shopRef, {
        FirestoreFields.businessName: shopName,
        FirestoreFields.location: shopLocation,
        FirestoreFields.contactNumber: shopContactNumber,
        FirestoreFields.createdAt: FieldValue.serverTimestamp(),
        FirestoreFields.ownerAdminUid: uid,
      });

      batch.set(memberRef, {
        FirestoreFields.name: name,
        FirestoreFields.email: email,
        FirestoreFields.phone: phone,
        FirestoreFields.role: UserRole.admin.name,
        FirestoreFields.isActive: true,
        FirestoreFields.verified: true,
        FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      });

      await batch.commit();
      FirestoreUsageService.to.trackWrite(3);
      log('Admin registered successfully', name: logName);

      // Create Default Agreement Template for the new shop
      try {
        final templateService = AgreementTemplateService();
        await templateService.createDefaultTemplate(shopRef.id);
        log(
          'Default agreement template created for shop: ${shopRef.id}',
          name: logName,
        );
      } catch (e) {
        log(
          'Error creating default template during registration: $e',
          name: logName,
        );
        // We don't rethrow here because the main registration was successful
      }
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

      final userRef = _db.collection(FirestoreCollections.users).doc(uid);
      final memberRef = _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection('members')
          .doc(uid);

      batch.set(userRef, {
        FirestoreFields.name: name,
        FirestoreFields.email: email,
        FirestoreFields.phone: phone,
        FirestoreFields.role: UserRole.staff.name,
        FirestoreFields.shopId: shopId,
        FirestoreFields.isActive: true,
        FirestoreFields.verified: false,
        FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      });

      batch.set(memberRef, {
        FirestoreFields.name: name,
        FirestoreFields.email: email,
        FirestoreFields.phone: phone,
        FirestoreFields.role: UserRole.staff.name,
        FirestoreFields.isActive: true,
        FirestoreFields.verified: false,
        FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      });

      await batch.commit();
      FirestoreUsageService.to.trackWrite(2);
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
      final doc = await _db
          .collection(FirestoreCollections.users)
          .doc(userId)
          .get();
      FirestoreUsageService.to.trackDocumentSnapshot(doc);
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
      final doc = await _db
          .collection(FirestoreCollections.users)
          .doc(userId)
          .get();
      FirestoreUsageService.to.trackDocumentSnapshot(doc);

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
          .collection(FirestoreCollections.users)
          .doc(_auth.currentUser!.uid)
          .get();
      FirestoreUsageService.to.trackDocumentSnapshot(doc);
      return doc[FirestoreFields.shopId] as String;
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
      final doc = await _db
          .collection(FirestoreCollections.users)
          .doc(userId)
          .get();
      FirestoreUsageService.to.trackDocumentSnapshot(doc);
      if (!doc.exists) return false;

      return doc[FirestoreFields.isActive] == true;
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
          .collection(FirestoreCollections.users)
          .where(FirestoreFields.email, isEqualTo: email)
          .limit(1)
          .get();
      FirestoreUsageService.to.trackQuerySnapshot(snap);

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
      if (name != null) data[FirestoreFields.name] = name;
      if (phone != null) data[FirestoreFields.phone] = phone;

      await _db.collection(FirestoreCollections.users).doc(userId).update(data);
      FirestoreUsageService.to.trackWrite(1);
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
      batch.update(_db.collection(FirestoreCollections.users).doc(userId), {
        FirestoreFields.isActive: isActive,
      });

      // Update minimal member info for real-time listing
      batch.update(
        _db
            .collection(FirestoreCollections.shops)
            .doc(shopId)
            .collection('members')
            .doc(userId),
        {FirestoreFields.isActive: isActive},
      );

      await batch.commit();
      FirestoreUsageService.to.trackWrite(2);
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
      batch.update(_db.collection(FirestoreCollections.users).doc(userId), {
        FirestoreFields.verified: verified,
      });

      // Update minimal member info for real-time listing
      batch.update(
        _db
            .collection(FirestoreCollections.shops)
            .doc(shopId)
            .collection('members')
            .doc(userId),
        {FirestoreFields.verified: verified},
      );

      await batch.commit();
      FirestoreUsageService.to.trackWrite(2);
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
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection('members')
          .doc(userId)
          .delete();
      FirestoreUsageService.to.trackDelete(1);
      log('User removed from shop: $userId', name: logName);
    } catch (e) {
      log('Error removing user from shop: $e', name: logName);
      rethrow;
    }
  }
}
