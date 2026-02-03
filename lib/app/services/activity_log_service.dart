import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/activity_log_model.dart';
import 'auth_service.dart';
import 'user_service.dart';
import '../../data/firestore/firestore_collections.dart';
import '../../data/firestore/firestore_fields.dart';
import '../../utils/constants/a_enums.dart';

class ActivityLogService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String logName = 'ActivityLogService';

  // Dependencies for actor info
  // Note: Using Get.find() inside might be risky if service is called from background/isolate,
  // but fine for standard GetX usage.

  CollectionReference _logsRef(String shopId) {
    return _db
        .collection(FirestoreCollections.shops)
        .doc(shopId)
        .collection(FirestoreCollections.activityLogs);
  }

  /// Create a log entry.
  /// Optionally accepts a [transaction] to include the log in an atomic write.
  Future<void> logActivity({
    required String shopId,
    required ActivityType type,
    required String description,
    required String entityId,
    required String entityType, // e.g. 'Rental', 'Payment'
    Map<String, dynamic>? metadata,
    Transaction? transaction,
  }) async {
    try {
      // 1. Resolve Actor Info asynchronously (if not provided in metadata, which is rare for server logs,
      // but here we are on client).
      // Ideally, we get this from AuthService/UserService cache to avoid extra reads.

      String actorId = 'SYSTEM';
      String actorName = 'System';

      try {
        if (Get.isRegistered<AuthService>()) {
          final authService = Get.find<AuthService>();
          final user = authService.currentUser;
          if (user != null) {
            actorId = user.uid;
            // Best effort attempt to get name. In a real app, `AuthService` should cache the current user profile.
            // For now, we'll try to get it if we can, or default to email/uid.
            // A better approach: The caller should pass actor info if known.
            // Optimization: If UserService has cached user, use it.
            if (Get.isRegistered<UserService>()) {
              Get.find<UserService>();
              // This might trigger a fetch if not cached, which is slow for a log.
              // We will skip deep fetch and rely on Auth Display Name if available.
              actorName = user.displayName ?? user.email ?? 'Staff';
            }
          }
        }
      } catch (e) {
        // Fallback if GetX isn't ready or services missing
        log('Could not resolve actor: $e', name: logName);
      }

      final logEntry = ActivityLogModel(
        shopId: shopId,
        actorId: actorId,
        actorName: actorName,
        activityType: type,
        description: description,
        entityId: entityId,
        entityType: entityType,
        timestamp: DateTime.now(),
        metadata: metadata,
      );

      final docRef = _logsRef(shopId).doc();

      if (transaction != null) {
        transaction.set(docRef, logEntry.toMap());
        log('Activity logged (Transaction): ${type.name}', name: logName);
      } else {
        await docRef.set(logEntry.toMap());
        log('Activity logged: ${type.name}', name: logName);
      }
    } catch (e) {
      log('Failed to log activity: $e', name: logName, error: e);
      // We do NOT rethrow here because logging failure should not crash the main action (usually).
    }
  }

  Stream<List<ActivityLogModel>> streamLogs(String shopId, {int limit = 50}) {
    return _logsRef(shopId)
        .orderBy(FirestoreFields.timestamp, descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) => ActivityLogModel.fromSnapshot(
                  doc as DocumentSnapshot<Map<String, dynamic>>,
                ),
              )
              .toList();
        });
  }
}