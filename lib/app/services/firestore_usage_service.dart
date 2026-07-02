import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'user_service.dart';

class FirestoreUsageService extends GetxService {
  static FirestoreUsageService get to => Get.find();
  
  final _storage = GetStorage();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String _keyReads = 'fs_usage_reads';
  static const String _keyWrites = 'fs_usage_writes';
  static const String _keyDeletes = 'fs_usage_deletes';

  final RxInt accumulatedReads = 0.obs;
  final RxInt accumulatedWrites = 0.obs;
  final RxInt accumulatedDeletes = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Load persisted counts
    accumulatedReads.value = _storage.read<int>(_keyReads) ?? 0;
    accumulatedWrites.value = _storage.read<int>(_keyWrites) ?? 0;
    accumulatedDeletes.value = _storage.read<int>(_keyDeletes) ?? 0;
    log('FirestoreUsageService initialized. Persisted counts: reads=${accumulatedReads.value}, writes=${accumulatedWrites.value}, deletes=${accumulatedDeletes.value}', name: 'FirestoreUsageService');
  }

  void trackRead([int count = 1]) {
    accumulatedReads.value += count;
    _storage.write(_keyReads, accumulatedReads.value);
    _checkSync();
  }

  void trackWrite([int count = 1]) {
    accumulatedWrites.value += count;
    _storage.write(_keyWrites, accumulatedWrites.value);
    _checkSync();
  }

  void trackDelete([int count = 1]) {
    accumulatedDeletes.value += count;
    _storage.write(_keyDeletes, accumulatedDeletes.value);
    _checkSync();
  }

  void trackQuerySnapshot(QuerySnapshot snapshot) {
    int count = snapshot.docs.length;
    trackRead(count > 0 ? count : 1);
  }

  void trackDocumentSnapshot(DocumentSnapshot snapshot) {
    trackRead(1);
  }

  DateTime? _lastSyncTime;
  bool _isSyncing = false;

  void _checkSync() {
    final now = DateTime.now();
    if (_lastSyncTime == null) {
      _lastSyncTime = now;
      return;
    }

    final diff = now.difference(_lastSyncTime!);
    if (diff.inMinutes >= 5 || 
        accumulatedReads.value >= 50 || 
        accumulatedWrites.value >= 10 || 
        accumulatedDeletes.value >= 10) {
      syncNow();
    }
  }

  Future<void> syncNow() async {
    if (_isSyncing) return;

    final shopId = await _getShopId();
    if (shopId == null || shopId.isEmpty) {
      log('Cannot sync Firestore usage: shop ID not found in local storage.', name: 'FirestoreUsageService');
      return;
    }

    final readsToSync = accumulatedReads.value;
    final writesToSync = accumulatedWrites.value;
    final deletesToSync = accumulatedDeletes.value;

    if (readsToSync == 0 && writesToSync == 0 && deletesToSync == 0) return;

    _isSyncing = true;
    log('Syncing Firestore usage: reads=$readsToSync, writes=$writesToSync, deletes=$deletesToSync for shop: $shopId', name: 'FirestoreUsageService');

    try {
      final now = DateTime.now();
      final dateStr = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final monthStr = "${now.year}-${now.month.toString().padLeft(2, '0')}";

      final batch = _db.batch();

      final dailyRef = _db
          .collection('shops')
          .doc(shopId)
          .collection('billing_usage')
          .doc('days')
          .collection('history')
          .doc(dateStr);

      batch.set(dailyRef, {
        'reads': FieldValue.increment(readsToSync),
        'writes': FieldValue.increment(writesToSync),
        'deletes': FieldValue.increment(deletesToSync),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final monthlyRef = _db
          .collection('shops')
          .doc(shopId)
          .collection('billing_usage')
          .doc('months')
          .collection('history')
          .doc(monthStr);

      batch.set(monthlyRef, {
        'reads': FieldValue.increment(readsToSync),
        'writes': FieldValue.increment(writesToSync),
        'deletes': FieldValue.increment(deletesToSync),
        'updated_at': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();

      accumulatedReads.value -= readsToSync;
      accumulatedWrites.value -= writesToSync;
      accumulatedDeletes.value -= deletesToSync;

      _storage.write(_keyReads, accumulatedReads.value);
      _storage.write(_keyWrites, accumulatedWrites.value);
      _storage.write(_keyDeletes, accumulatedDeletes.value);

      _lastSyncTime = DateTime.now();
      log('Firestore usage sync completed.', name: 'FirestoreUsageService');
    } catch (e) {
      log('Failed to sync Firestore usage: $e', name: 'FirestoreUsageService');
    } finally {
      _isSyncing = false;
    }
  }

  Future<String?> _getShopId() async {
    try {
      final userService = Get.find<UserService>();
      return await userService.getShopIdFromStorage();
    } catch (e) {
      log('Error getting shop ID: $e', name: 'FirestoreUsageService');
      return null;
    }
  }
}
