import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:surfboard_rental_app/app/services/shop_service.dart';
import 'package:surfboard_rental_app/app/services/user_service.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';
import 'package:flutter/material.dart';
import 'package:surfboard_rental_app/utils/storage/app_storage.dart';

class ConfigService extends GetxService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static const String logName = 'ConfigService';

  // -- App Configurations --

  // Known permission keys
  static const List<String> _permissionKeys = [
    'new_rental',
    'rentals',
    'rental_history',
    'alerts',
    'qr_scanner',
    'inventory_view',
    'inventory_view_damage_fees',
    'inventory_add',
    'inventory_edit',
    'inventory_delete',
    'customers_view',
    'customers_add',
    'customers_edit',
    'customer_contact',
    'payments',
    'damage_fee',
    'reports',
    'settings_view_shop',
    'settings_edit_shop',
    'settings_edit_currency',
    'settings_edit_date_format',
    'settings_edit_timezone',
    'settings_edit_rental_logic',
    'settings_manage_access',
    'shop_setup',
    'agreement_template',
  ];

  final RxString currency = 'USD'.obs;
  final RxString dateFormat = 'dd/MM/yyyy'.obs;
  final RxString timeZone = 'UTC'.obs;

  // -- Pricing & Rental Configurations --
  final RxInt hourlyGracePeriodMinutes = 15.obs;
  final RxInt dailyGracePeriodHours = 1.obs; // In hours
  final RxDouble taxRate = 0.0.obs;
  final RxBool isTaxEnabled = false.obs;

  // -- Language Configuration --
  final RxString languageCode = 'en'.obs;

  final RxBool isMaintenanceMode = false.obs;
  final RxString maintenanceMessage =
      'App is currently under maintenance. Please try again later.'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedLanguage();
    _listenToMaintenanceConfig();
    loadShopConfig();
  }

  void _loadSavedLanguage() {
    try {
      final savedLang = AppLocalStorage().readData<String>('lang');
      if (savedLang != null) {
        languageCode.value = savedLang;
      } else {
        languageCode.value = Get.deviceLocale?.languageCode ?? 'en';
      }
    } catch (e) {
      log('Error loading saved language: $e', name: logName);
    }
  }

  void updateLanguage(String langCode) {
    try {
      Get.updateLocale(Locale(langCode));
      languageCode.value = langCode;
      AppLocalStorage().saveData('lang', langCode);
      log('Language updated to $langCode', name: logName);
    } catch (e) {
      log('Error updating language: $e', name: logName);
    }
  }

  Future<void> loadShopConfig() async {
    try {
      // Ensure services are available
      if (!Get.isRegistered<UserService>() ||
          !Get.isRegistered<ShopService>()) {
        log('UserService or ShopService not registered yet', name: logName);
        return;
      }

      final userService = Get.find<UserService>();
      final shopService = Get.find<ShopService>();

      final shopId = await userService.getShopIdFromStorage();
      if (shopId != null) {
        final shopDoc = await shopService.getShop(shopId);
        if (shopDoc.exists) {
          final data = shopDoc.data() as Map<String, dynamic>;

          if (data[FirestoreFields.currency] != null) {
            currency.value = data[FirestoreFields.currency];
          }
          if (data[FirestoreFields.dateFormat] != null) {
            dateFormat.value = data[FirestoreFields.dateFormat];
          }
          if (data[FirestoreFields.timeZone] != null) {
            timeZone.value = data[FirestoreFields.timeZone];
          }

          // Pricing Config
          if (data[FirestoreFields.hourlyGracePeriodMinutes] != null) {
            hourlyGracePeriodMinutes.value =
                data[FirestoreFields.hourlyGracePeriodMinutes];
          }
          if (data[FirestoreFields.dailyGracePeriodHours] != null) {
            dailyGracePeriodHours.value =
                data[FirestoreFields.dailyGracePeriodHours];
          }
          if (data[FirestoreFields.taxRate] != null) {
            taxRate.value = (data[FirestoreFields.taxRate] as num).toDouble();
          }
          if (data[FirestoreFields.isTaxEnabled] != null) {
            isTaxEnabled.value = data[FirestoreFields.isTaxEnabled];
          }

          log(
            'Shop config loaded: Currency=${currency.value}, '
            'DateFmt=${dateFormat.value}, TZ=${timeZone.value}, '
            'GraceH=${hourlyGracePeriodMinutes.value}, GraceD=${dailyGracePeriodHours.value}, '
            'Tax=${isTaxEnabled.value ? taxRate.value : "Disabled"}',
            name: logName,
          );
          // Load Access Rules
          bool isAdmin = false;
          final currentUser = await userService.getUser(
            userService.currentUid ?? '',
          );
          if (currentUser != null && currentUser.role.name == 'admin') {
            isAdmin = true;
          }

          if (isAdmin) {
            final adminRules = <String, bool>{};
            for (var key in _permissionKeys) {
              adminRules[key] = true;
            }
            updateAccessRules(adminRules);
          } else {
            // Load from Shop
            if (data[FirestoreFields.staffAccess] != null) {
              updateAccessRules(
                data[FirestoreFields.staffAccess] as Map<String, dynamic>,
              );
            }
          }
        }
      }
    } catch (e) {
      log('Error loading shop config: $e', name: logName);
    }
  }

  void updateConfig({
    String? newCurrency,
    String? newDateFormat,
    String? newTimeZone,
    int? newHourlyGrace,
    int? newDailyGrace,
    double? newTaxRate,
    bool? newIsTaxEnabled,
  }) {
    if (newCurrency != null) currency.value = newCurrency;
    if (newDateFormat != null) dateFormat.value = newDateFormat;
    if (newTimeZone != null) timeZone.value = newTimeZone;

    if (newHourlyGrace != null) hourlyGracePeriodMinutes.value = newHourlyGrace;
    if (newDailyGrace != null) dailyGracePeriodHours.value = newDailyGrace;
    if (newTaxRate != null) taxRate.value = newTaxRate;
    if (newIsTaxEnabled != null) isTaxEnabled.value = newIsTaxEnabled;
  }

  // -- Access Control --
  final RxMap<String, bool> staffAccessRules = <String, bool>{}.obs;

  void updateAccessRules(Map<String, dynamic> newRules) {
    // Safely cast to Map<String, bool>
    final castedRules = <String, bool>{};
    newRules.forEach((key, value) {
      if (value is bool) {
        castedRules[key] = value;
      }
    });
    staffAccessRules.assignAll(castedRules);
    log('Access rules updated: $staffAccessRules', name: logName);
  }

  void _listenToMaintenanceConfig() {
    try {
      log('Listening to maintenance config', name: logName);
      _db
          .collection('config')
          .doc('maintenance')
          .snapshots()
          .listen(
            (snapshot) {
              if (snapshot.exists && snapshot.data() != null) {
                final data = snapshot.data()!;
                isMaintenanceMode.value = data['is_active'] ?? false;
                if (data['message'] != null) {
                  maintenanceMessage.value = data['message'];
                }
                log(
                  'Maintenance mode updated: ${isMaintenanceMode.value}',
                  name: logName,
                );
              }
            },
            onError: (e) {
              log('Error listening to maintenance config: $e', name: logName);
            },
          );
    } catch (e) {
      log('Error initializing maintenance listener: $e', name: logName);
    }
  }

  Future<ConfigService> init() async {
    return this;
  }
}
