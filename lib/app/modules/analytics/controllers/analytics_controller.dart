import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/firestore/firestore_collections.dart';
import '../../../../data/firestore/firestore_fields.dart';
import '../../../../utils/constants/a_enums.dart';
import '../../../../utils/storage/app_storage.dart';
import '../../../models/inventory_model.dart';
import '../../../models/rental_model.dart';
import '../../../services/firestore_usage_service.dart';

class AnalyticsController extends GetxController {
  final isLoading = false.obs;

  // Selected Date Range (Defaults to last 30 days)
  final startDate = Rx<DateTime?>(null);
  final endDate = Rx<DateTime?>(null);

  // Financial Metrics
  final totalRevenue = 0.0.obs;
  final averageOrderValue = 0.0.obs;

  // Rental Counts
  final totalRentals = 0.obs;
  final activeRentals = 0.obs;
  final overdueRentals = 0.obs;
  final completedRentals = 0.obs;

  // Chart Data Sets
  final revenueTimeSeries = <DateTime, double>{}.obs;
  final surfboardTypeUtilization = <String, int>{}.obs;
  final inventoryStatusDistribution = <String, int>{}.obs;
  final boardPopularity = <String, int>{}.obs;

  String? shopId;

  @override
  void onInit() {
    super.onInit();
    // Default to last 30 days
    final now = DateTime.now();
    startDate.value = now.subtract(const Duration(days: 30));
    endDate.value = now;
    
    _loadShopIdAndFetch();
  }

  Future<void> _loadShopIdAndFetch() async {
    shopId = AppLocalStorage().readData<String>(FirestoreFields.shopId);
    if (shopId != null) {
      await fetchAnalytics();
    } else {
      Get.snackbar('error'.tr, 'shop_not_found'.tr);
    }
  }

  Future<void> fetchAnalytics() async {
    if (shopId == null) return;
    try {
      isLoading.value = true;

      // 1. Fetch all rentals for this shop
      final rentalsSnapshot = await FirebaseFirestore.instance
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.rentals)
          .get();

      FirestoreUsageService.to.trackQuerySnapshot(rentalsSnapshot);

      final allRentals = rentalsSnapshot.docs
          .map((doc) => RentalModel.fromSnapshot(doc))
          .toList();

      // 2. Fetch all inventory for this shop
      final inventorySnapshot = await FirebaseFirestore.instance
          .collection(FirestoreCollections.shops)
          .doc(shopId)
          .collection(FirestoreCollections.inventory)
          .get();

      FirestoreUsageService.to.trackQuerySnapshot(inventorySnapshot);

      final allInventory = inventorySnapshot.docs
          .map((doc) => InventoryModel.fromSnapshot(doc))
          .toList();

      // 3. Filter rentals by selected date range in memory
      final filteredRentals = allRentals.where((rental) {
        final date = rental.createdAt;
        if (startDate.value != null && date.isBefore(startDate.value!)) {
          return false;
        }
        // Include the entire end day
        if (endDate.value != null && date.isAfter(endDate.value!.add(const Duration(days: 1)))) {
          return false;
        }
        return true;
      }).toList();

      // 4. Process Rental & Financial Metrics
      double revSum = 0.0;
      int active = 0;
      int overdue = 0;
      int completed = 0;

      final dailyRevenue = <DateTime, double>{};
      final popularMap = <String, int>{};

      for (var rental in filteredRentals) {
        revSum += rental.amountPaid;

        switch (rental.status) {
          case RentalStatus.active:
            active++;
            break;
          case RentalStatus.overdue:
            overdue++;
            break;
          case RentalStatus.completed:
            completed++;
            break;
          default:
            break;
        }

        // Daily Revenue Time Series
        final dayKey = DateUtils.dateOnly(rental.createdAt);
        dailyRevenue[dayKey] = (dailyRevenue[dayKey] ?? 0.0) + rental.amountPaid;

        // Board Popularity (by cached item name)
        final boardName = rental.cachedItemName ?? 'Unknown Board';
        popularMap[boardName] = (popularMap[boardName] ?? 0) + 1;
      }

      totalRevenue.value = revSum;
      totalRentals.value = filteredRentals.length;
      activeRentals.value = active;
      overdueRentals.value = overdue;
      completedRentals.value = completed;
      averageOrderValue.value = filteredRentals.isNotEmpty ? revSum / filteredRentals.length : 0.0;

      // Sort and assign revenue series
      revenueTimeSeries.assignAll(Map.fromEntries(
        dailyRevenue.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
      ));

      // Limit popularity to top 5 boards
      final sortedPopularity = popularMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      boardPopularity.assignAll(Map.fromEntries(sortedPopularity.take(5)));

      // 5. Process Inventory Status & Utilization Metrics
      final statusMap = <String, int>{};
      final typeMap = <String, int>{};

      for (var item in allInventory) {
        statusMap[item.status.name] = (statusMap[item.status.name] ?? 0) + 1;
        
        // Surfboard type
        typeMap[item.type] = (typeMap[item.type] ?? 0) + 1;
      }

      inventoryStatusDistribution.assignAll(statusMap);
      surfboardTypeUtilization.assignAll(typeMap);

    } catch (e) {
      log('Error loading analytics: $e');
      Get.snackbar('error'.tr, 'failed_load_analytics'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: startDate.value != null && endDate.value != null
          ? DateTimeRange(start: startDate.value!, end: endDate.value!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                  surface: Theme.of(context).colorScheme.surface,
                  onSurface: Theme.of(context).colorScheme.onSurface,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      startDate.value = picked.start;
      endDate.value = picked.end;
      await fetchAnalytics();
    }
  }
}
