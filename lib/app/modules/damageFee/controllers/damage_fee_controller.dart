import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:surfboard_rental_app/app/models/damage_fee_model.dart';
import 'package:surfboard_rental_app/app/services/damage_fee_service.dart';
import 'package:surfboard_rental_app/utils/constants/a_enums.dart';
import 'package:surfboard_rental_app/utils/common/custom_dropdown.dart';
import 'package:surfboard_rental_app/utils/common/app_snack_bar.dart';

import 'package:surfboard_rental_app/app/services/user_service.dart';

class DamageFeeController extends GetxController {
  final DamageFeeService _damageFeeService = DamageFeeService();
  final UserService _userService = Get.find();

  // State Variables
  final RxList<DamageFeeModel> damageRules = <DamageFeeModel>[].obs;
  final RxBool isLoading = false.obs;

  // Shop ID & Item ID
  String? shopId;
  late String itemId;

  // Controllers for Add/Edit Dialog
  final typeController = TextEditingController();
  final descController = TextEditingController();
  final feeController = TextEditingController();
  final RxString selectedDamageType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      shopId = await _userService.getShopIdFromStorage();

      // Get item ID from navigation arguments
      if (Get.arguments == null || Get.arguments is! String) {
        throw Exception('Item ID is required. Please pass a valid item ID.');
      }
      itemId = Get.arguments as String;

      log('Initialized with itemId: $itemId', name: 'DamageFeeController');
      _setupDamageRulesStream();
    } catch (e) {
      log('Error in onInit: $e', name: 'DamageFeeController');
      AppSnackBar.error(
        title: 'Initialization Error',
        message: 'Failed to initialize: $e',
      );
      Get.back();
    }
  }

  // ---------------------------------------------------------------------------
  // 1. SETUP DAMAGE RULES STREAM FROM FIRESTORE
  // ---------------------------------------------------------------------------
  void _setupDamageRulesStream() {
    try {
      if (shopId == null) {
        throw Exception('Shop ID not available');
      }
      isLoading.value = true;

      // Bind the stream
      damageRules.bindStream(
        _damageFeeService.streamDamageRules(shopId: shopId!, itemId: itemId),
      );

      // Listen for the first data event to stop the loader
      ever(damageRules, (_) => isLoading.value = false);
    } catch (e) {
      log(
        'Error setting up damage rules stream: $e',
        name: 'DamageFeeController',
      );
      AppSnackBar.error(
        title: 'Error',
        message: 'Failed to load damage rules: $e',
      );
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 2. GET DROPDOWN ITEMS FROM ENUM
  // ---------------------------------------------------------------------------
  List<DropdownItem> getDamageTypeDropdownItems() {
    return DamageTypeHelper.damageTypes.entries.map((entry) {
      return DropdownItem(
        label: entry.value.label,
        value: entry.key,
        description: entry.value.description,
      );
    }).toList();
  }

  // ---------------------------------------------------------------------------
  // 3. ADD DAMAGE RULE TO FIRESTORE
  // ---------------------------------------------------------------------------
  Future<bool> _addRule(DamageFeeModel damageRule) async {
    try {
      if (shopId == null) {
        throw Exception('Shop ID not available');
      }
      await _damageFeeService.addDamageRule(
        shopId: shopId!,
        itemId: itemId,
        damageRule: damageRule,
      );
      log(
        'Added damage rule: ${damageRule.damageType}',
        name: 'DamageFeeController',
      );
      return true;
    } catch (e) {
      log('Error adding rule: $e', name: 'DamageFeeController');
      AppSnackBar.error(title: 'Error', message: 'Failed to add rule: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 4. UPDATE DAMAGE RULE IN FIRESTORE
  // ---------------------------------------------------------------------------
  Future<bool> _updateRule(DamageFeeModel damageRule) async {
    try {
      if (shopId == null) {
        throw Exception('Shop ID not available');
      }
      if (damageRule.id == null) {
        throw Exception('Rule ID is null');
      }
      await _damageFeeService.updateDamageRule(
        shopId: shopId!,
        itemId: itemId,
        damageRule: damageRule,
      );
      log('Updated damage rule: ${damageRule.id}', name: 'DamageFeeController');
      return true;
    } catch (e) {
      log('Error updating rule: $e', name: 'DamageFeeController');
      AppSnackBar.error(title: 'Error', message: 'Failed to update rule: $e');
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // 5. DELETE DAMAGE RULE FROM FIRESTORE
  // ---------------------------------------------------------------------------
  Future<void> deleteRule(String id) async {
    try {
      if (shopId == null) {
        throw Exception('Shop ID not available');
      }
      await _damageFeeService.deleteDamageRule(
        shopId: shopId!,
        itemId: itemId,
        ruleId: id,
      );
      log('Deleted damage rule: $id', name: 'DamageFeeController');
      AppSnackBar.success(
        title: 'Success',
        message: 'Damage rule deleted successfully',
      );
    } catch (e) {
      log('Error deleting rule: $e', name: 'DamageFeeController');
      AppSnackBar.error(title: 'Error', message: 'Failed to delete rule: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 6. OPEN ADD/EDIT DIALOG
  // ---------------------------------------------------------------------------
  void openAddEditDialog({DamageFeeModel? rule}) {
    final isEdit = rule != null;

    // Reset or Populate
    if (isEdit) {
      typeController.text = rule.damageType; // This is the label
      descController.text = rule.description;
      feeController.text = rule.feeAmount.toString();
      // Find the enum key for this label to match dropdown values
      try {
        final damageKey = DamageTypeHelper.damageTypes.entries
            .firstWhere((e) => e.value.label == rule.damageType)
            .key;
        selectedDamageType.value = damageKey;
      } catch (e) {
        log('Error finding damage type key: $e', name: 'DamageFeeController');
        selectedDamageType.value = '';
      }
    } else {
      typeController.clear();
      descController.clear();
      feeController.clear();
      selectedDamageType.value = '';
    }

    Get.defaultDialog(
      title: isEdit ? "edit_damage_rule".tr : "add_damage_rule".tr,
      titleStyle: TextStyle(
        color: Colors.white,
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: const Color(0xFF182c30), // Card Dark
      contentPadding: EdgeInsets.all(16.w),
      content: Obx(
        () => Column(
          children: [
            // Damage Type Dropdown
            CustomDropdown(
              items: getDamageTypeDropdownItems(),
              selectedValue: selectedDamageType.value.isNotEmpty
                  ? selectedDamageType.value
                  : null,
              hint: "select_damage_type".tr,
              bgColor: const Color(0xFF101f22),
              textColor: Colors.white,
              hintColor: const Color(0xFF94a3b8),
              borderColor: const Color(0xFF334155),
              onChanged: (value) {
                selectedDamageType.value = value;
                // Auto-populate description from enum
                final damageData = DamageTypeHelper.damageTypes[value];
                if (damageData != null) {
                  descController.text = damageData.description;
                  typeController.text = damageData.label;
                }
              },
            ),
            SizedBox(height: 12.h),
            // Description TextField (User can modify)
            _buildDialogTextField(
              descController,
              "description_editable".tr,
              maxLine: 2,
            ),
            SizedBox(height: 12.h),
            // Fee Amount TextField
            _buildDialogTextField(
              feeController,
              "fee_amount".tr,
              isNumber: true,
            ),
          ],
        ),
      ),
      confirm: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            // Validate
            if (selectedDamageType.value.isEmpty ||
                feeController.text.isEmpty) {
              AppSnackBar.error(
                title: "Error",
                message: "Please select damage type and fee amount",
              );
              return;
            }

            // Create/Update model
            final damageRule = isEdit
                ? DamageFeeModel(
                    id: rule.id,
                    itemId: rule.itemId,
                    feeAmount: double.tryParse(feeController.text) ?? 0.0,
                    description: descController.text.trim(),
                    activeStatus: rule.activeStatus,
                    damageType: typeController.text,
                  )
                : DamageFeeModel.create(
                    itemId: itemId,
                    feeAmount: double.tryParse(feeController.text) ?? 0.0,
                    description: descController.text.trim(),
                    damageType: typeController.text,
                  );

            // Check for duplicates when adding a new rule
            if (!isEdit) {
              final isDuplicate = damageRules.any(
                (existing) =>
                    existing.damageType.toLowerCase() ==
                    damageRule.damageType.toLowerCase(),
              );
              if (isDuplicate) {
                AppSnackBar.warning(
                  title: 'Duplicate Rule',
                  message:
                      'A damage rule for "${damageRule.damageType}" already exists.',
                );
                return;
              }
            }

            bool success = false;
            if (isEdit) {
              success = await _updateRule(damageRule);
            } else {
              success = await _addRule(damageRule);
            }

            if (success) {
              Get.back();
              AppSnackBar.success(
                title: 'Success',
                message: isEdit
                    ? 'Damage rule updated successfully'
                    : 'Damage rule added successfully',
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90E2), // Primary Blue
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            isEdit ? "update".tr : "save".tr,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      cancel: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => Get.back(),
          child: Text("cancel".tr, style: TextStyle(color: Color(0xFF94a3b8))),
        ),
      ),
    );
  }

  @override
  void onClose() {
    typeController.dispose();
    descController.dispose();
    feeController.dispose();
    super.onClose();
  }

  Widget _buildDialogTextField(
    TextEditingController c,
    String hint, {
    bool isNumber = false,
    int maxLine = 1,
  }) {
    return TextField(
      controller: c,
      keyboardType: isNumber
          ? const TextInputType.numberWithOptions(decimal: true)
          : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.withValues(alpha: 0.5)),
        filled: true,
        fillColor: const Color(0xFF101f22), // BG Dark
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      ),
      maxLines: maxLine,
    );
  }
}
