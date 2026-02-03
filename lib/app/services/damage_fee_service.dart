import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/damage_fee_model.dart';
import '../../data/firestore/firestore_collections.dart';
import '../../data/firestore/firestore_fields.dart';

class DamageFeeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String logName = 'DamageFeeService';

  // ---------------------------------------------------------------------------
  // FETCH DAMAGE RULES FROM FIRESTORE
  // ---------------------------------------------------------------------------
  Future<List<DamageFeeModel>> fetchDamageRules({
    required String shopId,
    required String itemId,
  }) async {
    try {
      log(
        'Fetching damage rules for shopId: $shopId, itemId: $itemId',
        name: logName,
      );

      final snapshot = await _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.inventory)
          .doc(itemId)
          .collection(FirestoreCollections.damageFees)
          .orderBy(FirestoreFields.createdAt, descending: true)
          .get();

      final damageRules = snapshot.docs.map((doc) {
        final data = doc.data();
        data[FirestoreFields.id] = doc.id;
        return DamageFeeModel.fromJson(data);
      }).toList();

      log('Fetched ${damageRules.length} damage rules', name: logName);
      return damageRules;
    } catch (e) {
      log('Error fetching damage rules: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // ADD DAMAGE RULE TO FIRESTORE
  // ---------------------------------------------------------------------------
  Future<DamageFeeModel> addDamageRule({
    required String shopId,
    required String itemId,
    required DamageFeeModel damageRule,
  }) async {
    try {
      log(
        'Adding damage rule for shopId: $shopId, itemId: $itemId',
        name: logName,
      );

      final docRef = await _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.inventory)
          .doc(itemId)
          .collection(FirestoreCollections.damageFees)
          .add({
            ...damageRule.toMap(),
            FirestoreFields.createdAt: FieldValue.serverTimestamp(),
            FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
          });

      final addedRule = damageRule.copyWith(id: docRef.id);
      log('Added damage rule with ID: ${addedRule.id}', name: logName);
      return addedRule;
    } catch (e) {
      log('Error adding damage rule: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // UPDATE DAMAGE RULE IN FIRESTORE
  // ---------------------------------------------------------------------------
  Future<void> updateDamageRule({
    required String shopId,
    required String itemId,
    required DamageFeeModel damageRule,
  }) async {
    try {
      if (damageRule.id == null || damageRule.id!.isEmpty) {
        throw Exception('Rule ID is required for update');
      }

      log('Updating damage rule: ${damageRule.id}', name: logName);

      await _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.inventory)
          .doc(itemId)
          .collection(FirestoreCollections.damageFees)
          .doc(damageRule.id)
          .update({
            ...damageRule.toMap(),
            FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
          });

      log('Updated damage rule: ${damageRule.id}', name: logName);
    } catch (e) {
      log('Error updating damage rule: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // DELETE DAMAGE RULE FROM FIRESTORE
  // ---------------------------------------------------------------------------
  Future<void> deleteDamageRule({
    required String shopId,
    required String itemId,
    required String ruleId,
  }) async {
    try {
      log('Deleting damage rule: $ruleId', name: logName);

      await _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.inventory)
          .doc(itemId)
          .collection(FirestoreCollections.damageFees)
          .doc(ruleId)
          .delete();

      log('Deleted damage rule: $ruleId', name: logName);
    } catch (e) {
      log('Error deleting damage rule: $e', name: logName);
      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // STREAM DAMAGE RULES FROM FIRESTORE
  // ---------------------------------------------------------------------------
  Stream<List<DamageFeeModel>> streamDamageRules({
    required String shopId,
    required String itemId,
  }) {
    try {
      log(
        'Streaming damage rules for shopId: $shopId, itemId: $itemId',
        name: logName,
      );

      final query = _db
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.inventory)
          .doc(itemId)
          .collection(FirestoreCollections.damageFees)
          .orderBy(FirestoreFields.createdAt, descending: true);

      return query.snapshots().map((snapshot) {
        final damageRules = snapshot.docs.map((doc) {
          final data = doc.data();
          data[FirestoreFields.id] = doc.id;
          return DamageFeeModel.fromJson(data);
        }).toList();
        log('Streamed ${damageRules.length} damage rules', name: logName);
        return damageRules;
      });
    } catch (e) {
      log('Error streaming damage rules: $e', name: logName);
      return Stream.value([]); // Return empty stream on error
    }
  }
}