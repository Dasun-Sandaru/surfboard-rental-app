import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/common/app_snack_bar.dart';
import '../../../../utils/storage/app_storage.dart';
import '../../../services/firestore_usage_service.dart';
import '../../../services/shop_service.dart';
import '../../../services/user_service.dart';
import '../../../models/shop_model.dart';

class BillingController extends GetxController {
  final UserService _userService = Get.find();
  final ShopService _shopService = Get.find();
  
  final isLoading = false.obs;
  final isMockData = false.obs;
  
  String? shopId;
  Rx<ShopModel?> shop = Rx<ShopModel?>(null);

  // Firestore Counters
  final totalReads = 0.obs;
  final totalWrites = 0.obs;
  final totalDeletes = 0.obs;

  // Custom Billing Rates & Configs
  final rateReads = 0.06.obs; // per 100,000
  final rateWrites = 0.18.obs; // per 100,000
  final rateDeletes = 0.02.obs; // per 100,000
  final markupPercent = 10.0.obs;
  final exchangeRate = 300.0.obs; // USD to LKR/local currency
  
  // Historical Daily Usage
  final dailyUsage = <String, Map<String, int>>{}.obs;

  // Text Controllers for settings
  final rateReadsController = TextEditingController();
  final rateWritesController = TextEditingController();
  final rateDeletesController = TextEditingController();
  final markupController = TextEditingController();
  final exchangeRateController = TextEditingController();

  // Calculated Bills
  double get baseUsdCost {
    final readsCost = (totalReads.value / 100000.0) * rateReads.value;
    final writesCost = (totalWrites.value / 100000.0) * rateWrites.value;
    final deletesCost = (totalDeletes.value / 100000.0) * rateDeletes.value;
    return readsCost + writesCost + deletesCost;
  }

  double get markupAmount => baseUsdCost * (markupPercent.value / 100.0);
  double get finalUsdCost => baseUsdCost + markupAmount;
  double get finalCurrencyCost => finalUsdCost * exchangeRate.value;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;
    try {
      shopId = await _userService.getShopIdFromStorage();
      if (shopId != null) {
        final shopDoc = await _shopService.getShop(shopId!);
        if (shopDoc.exists) {
          shop.value = ShopModel.fromSnapshot(shopDoc as DocumentSnapshot<Map<String, dynamic>>);
        }
        
        // Load custom billing configs from local storage (if previously configured)
        final storage = AppLocalStorage();
        rateReads.value = storage.readData<double>('billing_rate_reads') ?? 0.06;
        rateWrites.value = storage.readData<double>('billing_rate_writes') ?? 0.18;
        rateDeletes.value = storage.readData<double>('billing_rate_deletes') ?? 0.02;
        markupPercent.value = storage.readData<double>('billing_markup_percent') ?? 10.0;
        exchangeRate.value = storage.readData<double>('billing_exchange_rate') ?? 300.0;
        
        await fetchUsageData();
      }
    } catch (e) {
      log('Error loading billing initial data: $e', name: 'BillingController');
      AppSnackBar.error(title: 'Error', message: 'failed_load_billing'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUsageData() async {
    if (shopId == null) return;
    
    // If mock data is active, we don't fetch from Firestore
    if (isMockData.value) {
      _generateMockUsage();
      return;
    }

    try {
      isLoading.value = true;
      
      // Force sync local un-synced operations first
      await FirestoreUsageService.to.syncNow();
      
      final now = DateTime.now();
      final monthStr = "${now.year}-${now.month.toString().padLeft(2, '0')}";
      
      // Fetch monthly usage
      final monthlyDoc = await FirebaseFirestore.instance
          .collection('shops')
          .doc(shopId)
          .collection('billing_usage')
          .doc('months')
          .collection('history')
          .doc(monthStr)
          .get();
      
      if (monthlyDoc.exists && monthlyDoc.data() != null) {
        final data = monthlyDoc.data()!;
        totalReads.value = (data['reads'] as num?)?.toInt() ?? 0;
        totalWrites.value = (data['writes'] as num?)?.toInt() ?? 0;
        totalDeletes.value = (data['deletes'] as num?)?.toInt() ?? 0;
      } else {
        totalReads.value = 0;
        totalWrites.value = 0;
        totalDeletes.value = 0;
      }

      // Fetch daily history for this month
      final daysSnapshot = await FirebaseFirestore.instance
          .collection('shops')
          .doc(shopId)
          .collection('billing_usage')
          .doc('days')
          .collection('history')
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: '$monthStr-01')
          .where(FieldPath.documentId, isLessThanOrEqualTo: '$monthStr-31')
          .get();
      
      final tempUsage = <String, Map<String, int>>{};
      for (var doc in daysSnapshot.docs) {
        final data = doc.data();
        tempUsage[doc.id] = {
          'reads': (data['reads'] as num?)?.toInt() ?? 0,
          'writes': (data['writes'] as num?)?.toInt() ?? 0,
          'deletes': (data['deletes'] as num?)?.toInt() ?? 0,
        };
      }
      
      // Fill in days that have no data with zero counts
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      for (int i = 1; i <= daysInMonth; i++) {
        final dayStr = "$monthStr-${i.toString().padLeft(2, '0')}";
        if (!tempUsage.containsKey(dayStr)) {
          tempUsage[dayStr] = {'reads': 0, 'writes': 0, 'deletes': 0};
        }
      }
      
      dailyUsage.value = tempUsage;
    } catch (e) {
      log('Error fetching billing usage: $e', name: 'BillingController');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleMockData(bool value) {
    isMockData.value = value;
    if (value) {
      _generateMockUsage();
    } else {
      fetchUsageData();
    }
  }

  void _generateMockUsage() {
    // Generate realistic multi-tenant usage for demonstration
    totalReads.value = 145000;
    totalWrites.value = 24000;
    totalDeletes.value = 1500;

    final now = DateTime.now();
    final monthStr = "${now.year}-${now.month.toString().padLeft(2, '0')}";
    final tempUsage = <String, Map<String, int>>{};
    
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    for (int i = 1; i <= daysInMonth; i++) {
      final dayStr = "$monthStr-${i.toString().padLeft(2, '0')}";
      
      // Seed random-looking but smooth daily curves
      final int reads = 2000 + (i % 7 * 500) + (i % 5 * 800) + (i == 15 ? 12000 : 0);
      final int writes = 300 + (i % 6 * 150) + (i % 4 * 200) + (i == 15 ? 3000 : 0);
      final int deletes = 10 + (i % 8 * 15);
      
      tempUsage[dayStr] = {
        'reads': reads,
        'writes': writes,
        'deletes': deletes,
      };
    }
    dailyUsage.value = tempUsage;
  }

  void openConfigureRatesDialog() {
    rateReadsController.text = rateReads.value.toString();
    rateWritesController.text = rateWrites.value.toString();
    rateDeletesController.text = rateDeletes.value.toString();
    markupController.text = markupPercent.value.toString();
    exchangeRateController.text = exchangeRate.value.toString();
  }

  void saveConfigurations() {
    try {
      final reads = double.tryParse(rateReadsController.text) ?? 0.06;
      final writes = double.tryParse(rateWritesController.text) ?? 0.18;
      final deletes = double.tryParse(rateDeletesController.text) ?? 0.02;
      final markup = double.tryParse(markupController.text) ?? 10.0;
      final exchange = double.tryParse(exchangeRateController.text) ?? 300.0;

      rateReads.value = reads;
      rateWrites.value = writes;
      rateDeletes.value = deletes;
      markupPercent.value = markup;
      exchangeRate.value = exchange;

      final storage = AppLocalStorage();
      storage.saveData('billing_rate_reads', reads);
      storage.saveData('billing_rate_writes', writes);
      storage.saveData('billing_rate_deletes', deletes);
      storage.saveData('billing_markup_percent', markup);
      storage.saveData('billing_exchange_rate', exchange);

      AppSnackBar.success(
        title: 'settings_saved'.tr,
        message: 'billing_config_saved_msg'.tr,
      );
      Get.back();
    } catch (e) {
      AppSnackBar.error(title: 'Error', message: 'failed_save_config'.tr);
    }
  }
}
