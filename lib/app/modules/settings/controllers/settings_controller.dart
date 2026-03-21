import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../services/auth_service.dart';
import '../../../services/shop_service.dart';
import '../../../services/user_service.dart';
import '../../../../data/firestore/firestore_fields.dart';
import '../../../../utils/constants/a_enums.dart';

import '../../../../utils/common/app_snack_bar.dart';
import '../views/inventory_config_view.dart';
import '../views/edit_profile_view.dart';
import '../views/edit_shop_view.dart';
import '../views/access_control_view.dart';
import '../../../../app/services/config_service.dart';
import '../../../../utils/helper/rental_calculator.dart';

class SettingsController extends GetxController {
  final UserService _userService = Get.find();
  final ShopService _shopService = Get.find();
  final AuthService _authService = Get.find();
  final ConfigService _configService = Get.find();

  void updateConfig({
    String? newCurrency,
    String? newDateFormat,
    String? newTimeZone,
    int? newHourlyGrace,
    int? newDailyGrace,
    double? newTaxRate,
    bool? newIsTaxEnabled,
  }) {
    _configService.updateConfig(
      newCurrency: newCurrency,
      newDateFormat: newDateFormat,
      newTimeZone: newTimeZone,
      newHourlyGrace: newHourlyGrace,
      newDailyGrace: newDailyGrace,
      newTaxRate: newTaxRate,
      newIsTaxEnabled: newIsTaxEnabled,
    );
  }

  final Rx<Map<String, dynamic>> userProfile = Rx<Map<String, dynamic>>({});
  final Rx<Map<String, dynamic>> shopProfile = Rx<Map<String, dynamic>>({});

  // -- Text Controllers for Edit Profile --
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();

  // -- Text Controllers for Edit Shop --
  final shopNameController = TextEditingController();
  final shopLocationController = TextEditingController();
  final shopContactController = TextEditingController();

  // -- Text Controller for Dialogs (Inventory) --
  final textInputController = TextEditingController();

  // -- Inventory Configuration Data --
  final RxList<String> brands = <String>[
    "Channel Islands",
    "Firewire",
    "Pyzel",
    "Lost",
    "JS Industries",
    "Torq",
  ].obs;

  final RxList<SurfBoardType> boardTypes = RxList<SurfBoardType>.from(
    SurfBoardType.values,
  );

  final RxString currency = 'USD'.obs;
  final List<String> availableCurrencies = ['USD', 'EUR', 'LKR', 'AUD', 'GBP'];

  RxString get currentLanguage => _configService.languageCode;
  final Map<String, String> supportedLanguages = {
    'en': 'English',
    'si': 'සිංහල',
  };

  // -- Rental Configuration --
  final GlobalKey<FormState> rentalConfigFormKey = GlobalKey<FormState>();
  final defaultHourlyRateController = TextEditingController();
  final defaultDailyRateController = TextEditingController();
  final taxRateController = TextEditingController();
  final RxBool isTaxEnabled = false.obs;

  final hourlyGracePeriodController = TextEditingController();
  final dailyGracePeriodController = TextEditingController();

  // -- Price Simulator State --
  final Rx<RentType> simRentType = RentType.hourly.obs;
  final RxInt simDurationDays = 0.obs;
  final RxInt simDurationHours = 1.obs;
  final RxInt simDurationMinutes = 0.obs;
  final RxDouble simulatedPrice = 0.0.obs;

  // -- Date & Time Configuration --
  final RxString dateFormat = 'dd/MM/yyyy'.obs;
  final List<String> availableDateFormats = [
    'dd/MM/yyyy',
    'MM/dd/yyyy',
    'yyyy-MM-dd',
    'dd MMM yyyy',
    'MMM dd, yyyy',
  ];

  final RxString timeZone = 'UTC'.obs;
  // A simplified list of major timezones.
  final List<String> availableTimeZones = [
    'UTC',
    'Asia/Colombo',
    'Asia/Dubai',
    'Europe/London',
    'Europe/Paris',
    'Europe/Berlin',
    'America/New_York',
    'America/Los_Angeles',
    'America/Chicago',
    'Australia/Sydney',
    'Pacific/Honolulu',
    'Asia/Tokyo',
    'Asia/Singapore',
  ];

  // -- Access Control --

  bool get isAdmin => userProfile.value[FirestoreFields.role] == 'admin';

  bool hasPermission(String key) {
    if (isAdmin) return true;
    return staffAccessRules[key] ?? false;
  }

  // Initialize with false by default for better security, or true if previously assumed
  final RxMap<String, bool> staffAccessRules = <String, bool>{
    // Operations
    'new_rental': true,
    'rentals': true, // Active Rentals
    'rental_history': true,
    'alerts': true,
    'qr_scanner': true,

    // Inventory
    'inventory_view': true,
    'inventory_view_damage_fees': true,
    'inventory_add': false,
    'inventory_edit': false,
    'inventory_delete': false,

    // Customers
    'customers_view': true,
    'customers_add': true,
    'customers_edit': true,
    'customer_contact': false, // Can't call, msg, email
    // Financials & Reporting
    'payments': true, // Might want to restrict
    'damage_fee': true, // Might want to restrict
    'reports': false,

    // Settings & Configuration
    'settings_view_shop': true,
    'settings_edit_shop': false,
    'settings_edit_currency': false,
    'settings_edit_date_format': false,
    'settings_edit_timezone': false,
    'settings_edit_rental_logic': true,
    'settings_manage_access': false,
    'shop_setup': false,
    'agreement_template': false,
  }.obs;

  final Map<String, String> accessRouteLabels = {
    'new_rental': 'New Rental',
    'rentals': 'Active Rentals',
    'rental_history': 'Rental History',
    'alerts': 'Alerts & Notifications',
    'qr_scanner': 'QR Scanner',

    'inventory_view': 'View Inventory',
    'inventory_view_damage_fees': 'View Damage Fees',
    'inventory_add': 'Add Items',
    'inventory_edit': 'Edit Items',
    'inventory_delete': 'Delete Items',

    'customers_view': 'View Customers',
    'customers_add': 'Add Customers',
    'customers_edit': 'Edit Customers',
    'customer_contact': 'Contact Customers (Call/Msg/Email)',

    'payments': 'Payments & Transactions',
    'damage_fee': 'Damage Fee Configuration',
    'reports': 'Reports & Analytics',

    'settings_view_shop': 'View Shop Details',
    'settings_edit_shop': 'Edit Shop Details',
    'settings_edit_currency': 'Edit Currency',
    'settings_edit_date_format': 'Edit Date Format',
    'settings_edit_timezone': 'Edit Time Zone',
    'settings_edit_rental_logic': 'Edit Rental Pricing Logic',
    'settings_manage_access': 'Manage Access Rules',
    'shop_setup': 'Shop Configuration',
    'agreement_template': 'Agreement Templates',
  };

  final List<Map<String, dynamic>> accessGroups = [
    {
      'title': 'operations_group', // "Operations"
      'keys': [
        'new_rental',
        'rentals',
        'rental_history',
        'qr_scanner',
        'alerts',
      ],
    },
    {
      'title': 'inventory_group',
      'keys': [
        'inventory_view',
        'inventory_view_damage_fees',
        'inventory_add',
        'inventory_edit',
        'inventory_delete',
      ],
    },
    {
      'title': 'Customer Management',
      'keys': [
        'customers_view',
        'customers_add',
        'customers_edit',
        'customer_contact',
      ],
    },
    {
      'title': 'financials_group', // "Financials"
      'keys': ['payments', 'damage_fee'],
    },
    {
      'title': 'analytics_group', // "Analytics"
      'keys': ['reports'],
    },
    {
      'title': 'configuration_group', // "Configuration"
      'keys': [
        'settings_view_shop',
        'settings_edit_shop',
        'settings_edit_currency',
        'settings_edit_date_format',
        'settings_edit_timezone',
        'settings_edit_rental_logic',
        'settings_manage_access',
        'shop_setup',
        'agreement_template',
      ],
    },
  ];

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Get current user's data
      final currentUser = _authService.currentUser;
      if (currentUser == null) throw 'User not logged in';

      final userModel = await _userService.getUser(currentUser.uid);
      if (userModel == null) throw 'User data not found in Firestore';

      userProfile.value = {
        FirestoreFields.name: userModel.name,
        FirestoreFields.role: userModel.role.name,
        FirestoreFields.email: userModel.email,
        FirestoreFields.phone: userModel.phone,
        "image": '',
      };

      // Get shop data
      final shopId = await _userService.getShopIdFromStorage();
      if (shopId == null) throw 'Shop ID not found in storage';

      final shopDoc = await _shopService.getShop(shopId);
      if (!shopDoc.exists) throw 'Shop data not found in Firestore';
      final shopData = shopDoc.data() as Map<String, dynamic>;
      shopProfile.value = {
        FirestoreFields.businessName:
            shopData[FirestoreFields.businessName] ?? 'No Shop Name',
        FirestoreFields.location:
            shopData[FirestoreFields.location] ?? 'No Location',
        FirestoreFields.id: shopDoc.id,
        FirestoreFields.contactNumber:
            shopData[FirestoreFields.contactNumber] ?? 'No Contact Number',
      };

      currency.value = shopData[FirestoreFields.currency] ?? 'USD';
      dateFormat.value = shopData[FirestoreFields.dateFormat] ?? 'dd/MM/yyyy';
      timeZone.value = shopData[FirestoreFields.timeZone] ?? 'UTC';

      // Sync Global Config
      _configService.updateConfig(
        newCurrency: currency.value,
        newDateFormat: dateFormat.value,
        newTimeZone: timeZone.value,
        newHourlyGrace:
            shopData[FirestoreFields.hourlyGracePeriodMinutes] ?? 15,
        newDailyGrace: shopData[FirestoreFields.dailyGracePeriodHours] ?? 1,
        newTaxRate:
            (shopData[FirestoreFields.taxRate] as num?)?.toDouble() ?? 0.0,
        newIsTaxEnabled: shopData[FirestoreFields.isTaxEnabled] ?? false,
      );

      // Load Rental Config
      defaultHourlyRateController.text =
          (shopData[FirestoreFields.defaultHourlyRate] ?? '').toString();
      defaultDailyRateController.text =
          (shopData[FirestoreFields.defaultDailyRate] ?? '').toString();
      taxRateController.text = (shopData[FirestoreFields.taxRate] ?? '')
          .toString();
      isTaxEnabled.value = shopData[FirestoreFields.isTaxEnabled] ?? false;

      hourlyGracePeriodController.text =
          (shopData[FirestoreFields.hourlyGracePeriodMinutes] ?? 15).toString();
      dailyGracePeriodController.text =
          (shopData[FirestoreFields.dailyGracePeriodHours] ?? 1).toString();

      // Load Access Rules
      final accessData =
          shopData[FirestoreFields.staffAccess] as Map<String, dynamic>?;
      if (accessData != null) {
        staffAccessRules.assignAll(
          accessData.map((key, value) => MapEntry(key, value as bool)),
        );
      }

      // Update ConfigService with EFFECTIVE rules
      final effectiveRules = <String, bool>{};

      // We iterate over known keys to ensure complete map
      for (var key in staffAccessRules.keys) {
        if (isAdmin) {
          effectiveRules[key] = true;
        } else {
          effectiveRules[key] = staffAccessRules[key] ?? false;
        }
      }
      // Also ensure keys that might be missing from staffAccessRules but present in defaults are handled?
      // staffAccessRules was initialized with defaults. assignAll overwrites it.
      // If DB has partial data, assignAll might lose keys if accessData is partial.
      // But usually we save the whole map.
      // If isAdmin, we just want full access for other modules using ConfigService.
      if (isAdmin) {
        // Fill all known keys with true
        for (var k in accessRouteLabels.keys) {
          effectiveRules[k] = true;
        }
      }

      _configService.updateAccessRules(effectiveRules);
    } catch (e) {
      AppSnackBar.error(title: 'Error Loading Data', message: e.toString());
    }
  }

  // -- Actions --

  void editPersonalInfo() {
    // Initialize controllers with current data
    nameController.text = userProfile.value[FirestoreFields.name] ?? '';
    phoneController.text = userProfile.value[FirestoreFields.phone] ?? '';
    emailController.text = userProfile.value[FirestoreFields.email] ?? '';

    // Navigate to Edit Profile View
    Get.to(() => EditProfileView());
  }

  Future<void> saveProfile() async {
    final newName = nameController.text.trim();
    final newPhone = phoneController.text.trim();

    if (newName.isEmpty) {
      AppSnackBar.error(title: "Error", message: "Name cannot be empty");
      return;
    }

    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        await _userService.updateUserProfile(
          userId: currentUser.uid,
          name: newName,
          phone: newPhone.isNotEmpty ? newPhone : null,
        );

        Get.back(); // Close Edit Profile View
        _loadData(); // Refresh data
        AppSnackBar.success(
          title: "Success",
          message: "Profile updated successfully",
        );
      }
    } catch (e) {
      AppSnackBar.error(title: "Update Failed", message: e.toString());
    }
  }

  void editShopDetails() {
    // Initialize controllers with current shop data
    shopNameController.text =
        shopProfile.value[FirestoreFields.businessName] ?? '';
    shopLocationController.text =
        shopProfile.value[FirestoreFields.location] ?? '';
    shopContactController.text =
        shopProfile.value[FirestoreFields.contactNumber] ?? '';

    // Navigate to Edit Shop View
    Get.to(() => EditShopView());
  }

  Future<void> saveShopDetails() async {
    final newName = shopNameController.text.trim();
    final newLocation = shopLocationController.text.trim();
    final newContactNumber = shopContactController.text.trim();

    final canEdit = staffAccessRules['settings_edit_shop'] ?? false;
    if (!canEdit) {
      AppSnackBar.error(
        title: "Access Denied",
        message: "You don't have permission to edit shop details",
      );
      return;
    }

    if (newName.isEmpty) {
      AppSnackBar.error(title: "Error", message: "Shop Name cannot be empty");
      return;
    }

    try {
      final shopId = shopProfile.value[FirestoreFields.id];
      if (shopId != null) {
        await _shopService.updateShop(
          shopId: shopId,
          name: newName,
          location: newLocation,
          contactNumber: newContactNumber,
        );

        Get.back();
        _loadData();
        AppSnackBar.success(
          title: "Success",
          message: "Shop details updated successfully",
        );
      }
    } catch (e) {
      AppSnackBar.error(title: "Update Failed", message: e.toString());
    }
  }

  Future<void> saveRentalConfig() async {
    if (!rentalConfigFormKey.currentState!.validate()) {
      return;
    }

    try {
      final shopId = shopProfile.value[FirestoreFields.id];
      if (shopId == null) return;

      final hourlyRate =
          double.tryParse(defaultHourlyRateController.text.trim()) ?? 0.0;
      final dailyRate =
          double.tryParse(defaultDailyRateController.text.trim()) ?? 0.0;
      final taxRate = double.tryParse(taxRateController.text.trim()) ?? 0.0;
      final hourlyGrace =
          int.tryParse(hourlyGracePeriodController.text.trim()) ?? 15;
      final dailyGrace =
          int.tryParse(dailyGracePeriodController.text.trim()) ?? 1;

      await _shopService.updateShopFields(shopId, {
        FirestoreFields.defaultHourlyRate: hourlyRate,
        FirestoreFields.defaultDailyRate: dailyRate,
        FirestoreFields.taxRate: taxRate,
        FirestoreFields.isTaxEnabled: isTaxEnabled.value,
        FirestoreFields.hourlyGracePeriodMinutes: hourlyGrace,
        FirestoreFields.dailyGracePeriodHours: dailyGrace,
      });

      // Update global config immediately
      _configService.updateConfig(
        newHourlyGrace: hourlyGrace,
        newDailyGrace: dailyGrace,
        newTaxRate: taxRate,
        newIsTaxEnabled: isTaxEnabled.value,
      );

      Get.back(); // Close dialog or view
      _loadData();
      AppSnackBar.success(
        title: "Success",
        message: "Rental configuration updated",
      );
    } catch (e) {
      AppSnackBar.error(
        title: "Error",
        message: "Failed to save configuration",
      );
    }
  }

  void calculateSimulatedPrice() {
    final hourlyRate =
        double.tryParse(defaultHourlyRateController.text.trim()) ?? 0.0;
    final dailyRate =
        double.tryParse(defaultDailyRateController.text.trim()) ?? 0.0;
    final hourlyGrace =
        int.tryParse(hourlyGracePeriodController.text.trim()) ?? 15;
    final dailyGrace =
        int.tryParse(dailyGracePeriodController.text.trim()) ?? 1;

    final startDateTime = DateTime.now();
    DateTime dueDateTime;

    if (simRentType.value == RentType.hourly) {
      dueDateTime = startDateTime.add(Duration(
        hours: simDurationHours.value,
        minutes: simDurationMinutes.value,
      ));
    } else {
      dueDateTime = startDateTime.add(Duration(
        days: simDurationDays.value,
        hours: simDurationHours.value,
        minutes: simDurationMinutes.value,
      ));
    }

    final tax = double.tryParse(taxRateController.text.trim()) ?? 0.0;

    final price = RentalCalculator.calculateEstimatedTotal(
      startDateTime: startDateTime,
      dueDateTime: dueDateTime,
      rentType: simRentType.value,
      hourlyRate: hourlyRate,
      dailyRate: dailyRate,
      hourlyGraceMinutes: hourlyGrace,
      dailyGraceHours: dailyGrace,
      isTaxEnabled: isTaxEnabled.value,
      taxRate: tax,
    );

    simulatedPrice.value = price;
    log("Simulated Price: ${simulatedPrice.value}");
  }

  void showCurrencyPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "select_currency".tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Get.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...availableCurrencies.map(
              (c) => ListTile(
                title: Text(c),
                trailing: currency.value == c
                    ? Icon(Icons.check, color: Get.theme.primaryColor)
                    : null,
                onTap: () {
                  updateCurrency(c);
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateCurrency(String newCurrency) async {
    try {
      final shopId = shopProfile.value[FirestoreFields.id];
      if (shopId == null) return;

      await _shopService.updateShopFields(shopId, {
        FirestoreFields.currency: newCurrency,
      });
      currency.value = newCurrency;
      _configService.updateConfig(newCurrency: newCurrency);
      AppSnackBar.success(
        title: "Success",
        message: "Currency updated to $newCurrency",
      );
    } catch (e) {
      AppSnackBar.error(title: "Error", message: "Failed to update currency");
    }
  }

  void showDateFormatPicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "select_date_format".tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Get.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...availableDateFormats.map(
              (f) => ListTile(
                title: Text(f),
                trailing: dateFormat.value == f
                    ? Icon(Icons.check, color: Get.theme.primaryColor)
                    : null,
                onTap: () {
                  updateDateFormat(f);
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateDateFormat(String newFormat) async {
    try {
      final shopId = shopProfile.value[FirestoreFields.id];
      if (shopId == null) return;

      await _shopService.updateShopFields(shopId, {
        FirestoreFields.dateFormat: newFormat,
      });
      dateFormat.value = newFormat;
      _configService.updateConfig(newDateFormat: newFormat);
      AppSnackBar.success(title: "Success", message: "Date format updated");
    } catch (e) {
      AppSnackBar.error(
        title: "Error",
        message: "Failed to update date format",
      );
    }
  }

  void showTimeZonePicker() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.5,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          children: [
            Text(
              "select_time_zone".tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Get.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: availableTimeZones.length,
                itemBuilder: (context, index) {
                  final tz = availableTimeZones[index];
                  return ListTile(
                    title: Text(tz),
                    trailing: timeZone.value == tz
                        ? Icon(Icons.check, color: Get.theme.primaryColor)
                        : null,
                    onTap: () {
                      updateTimeZone(tz);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> updateTimeZone(String newTimeZone) async {
    try {
      final shopId = shopProfile.value[FirestoreFields.id];
      if (shopId == null) return;

      await _shopService.updateShopFields(shopId, {
        FirestoreFields.timeZone: newTimeZone,
      });
      timeZone.value = newTimeZone;
      _configService.updateConfig(newTimeZone: newTimeZone);
      AppSnackBar.success(title: "Success", message: "Time zone updated");
    } catch (e) {
      AppSnackBar.error(title: "Error", message: "Failed to update time zone");
    }
  }

  void showLanguagePicker() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Get.theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "select_language".tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Get.theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            ...supportedLanguages.entries.map((entry) {
              final code = entry.key;
              final name = entry.value;
              return ListTile(
                title: Text(name),
                trailing: currentLanguage.value == code
                    ? Icon(Icons.check, color: Get.theme.primaryColor)
                    : null,
                onTap: () {
                  updateLanguage(code);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void updateLanguage(String langCode) {
    _configService.updateLanguage(langCode);
    Get.back();
  }

  void logout() {
    Get.defaultDialog(
      title: "logout".tr,
      middleText: "logout_confirm_msg".tr,
      textConfirm: "yes".tr,
      textCancel: "no".tr,
      confirmTextColor: Colors.white,
      onConfirm: () async {
        Get.back(); // Close dialog
        await _authService.signOut();
        // AuthController will handle the redirection to SIGN_IN or SPLASH based on state
      },
    );
  }

  // Generic function to add item to a list
  void addItem(String title, RxList<dynamic> list) {
    textInputController.clear();
    Get.defaultDialog(
      title: "${'add'.tr} $title",
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: textInputController,
          decoration: InputDecoration(
            hintText: "${'enter_name'.tr} $title",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      textConfirm: "add".tr,
      textCancel: "cancel".tr,
      confirmTextColor: Colors.white,
      onConfirm: () {
        if (textInputController.text.isNotEmpty) {
          list.add(textInputController.text.trim());
          Get.back();
          AppSnackBar.success(
            title: 'Success',
            message: '$title added successfully',
          );
        }
      },
    );
  }

  // Generic function to remove item
  void removeItem(dynamic item, RxList<dynamic> list) {
    Get.defaultDialog(
      title: "remove_item".tr,
      middleText: "delete_confirm_msg".tr,
      textConfirm: "delete".tr,
      textCancel: "cancel".tr,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () {
        list.remove(item);
        Get.back();
      },
    );
  }

  void navigateToInventorySettings() {
    Get.to(() => const InventoryConfigView());
  }

  void navigateToAccessControl() {
    Get.to(() => const AccessControlView());
  }

  Future<void> toggleAccess(String key, bool value) async {
    staffAccessRules[key] = value;

    // Save to Firestore
    try {
      final shopId = shopProfile.value[FirestoreFields.id];
      if (shopId != null) {
        await _shopService.updateShopFields(shopId, {
          FirestoreFields.staffAccess: staffAccessRules,
        });
      }

      // Sync with global config service immediately
      if (!isAdmin) {
        _configService.updateAccessRules(staffAccessRules);
      }
    } catch (e) {
      AppSnackBar.error(title: "Error", message: "Failed to save access rule");
      // Revert on failure
      staffAccessRules[key] = !value;
    }
  }
}