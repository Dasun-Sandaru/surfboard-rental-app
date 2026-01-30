import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:surfboard_rental_app/app/services/auth_service.dart';
import 'package:surfboard_rental_app/app/services/shop_service.dart';
import 'package:surfboard_rental_app/app/services/user_service.dart';
import 'package:surfboard_rental_app/data/firestore/firestore_fields.dart';
import 'package:surfboard_rental_app/utils/constants/a_enums.dart';

import '../../../../utils/common/app_snack_bar.dart';
import '../views/inventory_config_view.dart';
import '../views/edit_profile_view.dart';
import '../views/edit_shop_view.dart';
import '../../../../app/services/config_service.dart';

class SettingsController extends GetxController {
  final UserService _userService = Get.find();
  final ShopService _shopService = Get.find();
  final AuthService _authService = Get.find();
  final ConfigService _configService = Get.find();

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
    'es': 'Spanish',
    'si': 'Sinhala',
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

    double price = 0.0;

    if (simRentType.value == RentType.hourly) {
      int hours = simDurationHours.value;
      final minutes = simDurationMinutes.value;

      // Logic: Minimum 1 hour
      if (hours == 0 && minutes == 0) hours = 1;

      // Logic: Grace Period
      if (minutes > hourlyGrace) {
        hours += 1;
      }

      price = hours * hourlyRate;
    } else {
      int days = simDurationDays.value;
      final hours = simDurationHours.value;
      final minutes = simDurationMinutes.value;

      // Logic: Minimum 1 day
      if (days == 0 && hours == 0 && minutes == 0) days = 1;

      // Convert excess time to minutes
      final excessMinutes = (hours * 60) + minutes;

      // Logic: Grace Period for extra day
      if (excessMinutes > dailyGrace) {
        days += 1;
      }

      price = days * dailyRate;
    }

    // Apply Tax if enabled
    if (isTaxEnabled.value) {
      final tax = double.tryParse(taxRateController.text.trim()) ?? 0.0;
      price += (price * tax / 100);
    }

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
              "Select Currency",
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
              "Select Date Format",
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
              "Select Time Zone",
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
              "Select Language",
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
      title: "Logout",
      middleText: "Are you sure you want to logout?",
      textConfirm: "Yes",
      textCancel: "No",
      confirmTextColor: Colors.white,
      onConfirm: () {
        // Auth Logic
        Get.back();
        Get.offAllNamed('/login');
      },
    );
  }

  // Generic function to add item to a list
  void addItem(String title, RxList<dynamic> list) {
    textInputController.clear();
    Get.defaultDialog(
      title: "Add $title",
      content: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: textInputController,
          decoration: InputDecoration(
            hintText: "Enter $title name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      textConfirm: "Add",
      textCancel: "Cancel",
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
      title: "Remove Item",
      middleText: "Delete '$item' from the list?",
      textConfirm: "Delete",
      textCancel: "Cancel",
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
}
