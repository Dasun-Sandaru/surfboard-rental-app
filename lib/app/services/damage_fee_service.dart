import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:surfboard_rental_app/app/models/damage_fee_model.dart';

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
          .collection('shops')
          .doc(shopId)
          .collection('inventory')
          .doc(itemId)
          .collection('damage_fees')
          .orderBy('created_at', descending: true)
          .get();

      final damageRules = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
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
          .collection('shops')
          .doc(shopId)
          .collection('inventory')
          .doc(itemId)
          .collection('damage_fees')
          .add({
            ...damageRule.toMap(),
            'created_at': FieldValue.serverTimestamp(),
            'updated_at': FieldValue.serverTimestamp(),
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
          .collection('shops')
          .doc(shopId)
          .collection('inventory')
          .doc(itemId)
          .collection('damage_fees')
          .doc(damageRule.id)
          .update({
            ...damageRule.toMap(),
            'updated_at': FieldValue.serverTimestamp(),
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
          .collection('shops')
          .doc(shopId)
          .collection('inventory')
          .doc(itemId)
          .collection('damage_fees')
          .doc(ruleId)
          .delete();

      log('Deleted damage rule: $ruleId', name: logName);
    } catch (e) {
      log('Error deleting damage rule: $e', name: logName);
      rethrow;
    }
  }
}
