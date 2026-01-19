import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:surfboard_rental_app/app/models/damage_fee_model.dart';
import 'package:surfboard_rental_app/utils/constants/a_enums.dart';
import 'package:surfboard_rental_app/utils/common/custom_dropdown.dart';

class DamageFeeController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // State Variables
  final RxList<DamageFeeModel> damageRules = <DamageFeeModel>[].obs;
  final RxBool isLoading = false.obs;

  // Shop ID & Item ID
  late String shopId;
  late String itemId;

  // Controllers for Add/Edit Dialog
  final typeController = TextEditingController();
  final descController = TextEditingController();
  final feeController = TextEditingController();
  final RxString selectedDamageType = ''.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      // Get actual shop ID from storage or arguments
      shopId = 'M8hBGr4o3Vbgcm2xbTPK'; // Replace with actual shop ID

      // Get item ID from navigation arguments
      if (Get.arguments == null || Get.arguments is! String) {
        throw Exception('Item ID is required. Please pass a valid item ID.');
      }
      itemId = Get.arguments as String;

      log('Initialized with itemId: $itemId', name: 'DamageFeeController');
      fetchDamageRules();
    } catch (e) {
      log('Error in onInit: $e', name: 'DamageFeeController');
      Get.snackbar(
        'Error',
        'Failed to initialize: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
      Get.back();
    }
  }

  // ---------------------------------------------------------------------------
  // 1. FETCH DAMAGE RULES FROM FIRESTORE
  // ---------------------------------------------------------------------------
  Future<void> fetchDamageRules() async {
    try {
      isLoading.value = true;
      final snapshot = await _db
          .collection('shops')
          .doc(shopId)
          .collection('inventory')
          .doc(itemId)
          .collection('damage_fees')
          .orderBy('created_at', descending: true)
          .get();

      damageRules.value = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return DamageFeeModel.fromJson(data);
      }).toList();

      log(
        'Fetched ${damageRules.length} damage rules',
        name: 'DamageFeeController',
      );
    } catch (e) {
      log('Error fetching damage rules: $e', name: 'DamageFeeController');
      Get.snackbar(
        'Error',
        'Failed to load damage rules: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    } finally {
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
  Future<void> _addRule(DamageFeeModel damageRule) async {
    try {
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

      // Add the ID to the model and update local list
      final addedRule = damageRule.copyWith(id: docRef.id);
      damageRules.add(addedRule);

      log('Added damage rule: ${addedRule.id}', name: 'DamageFeeController');
      Get.snackbar(
        'Success',
        'Damage rule added successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      log('Error adding rule: $e', name: 'DamageFeeController');
      Get.snackbar(
        'Error',
        'Failed to add rule: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 4. UPDATE DAMAGE RULE IN FIRESTORE
  // ---------------------------------------------------------------------------
  Future<void> _updateRule(DamageFeeModel damageRule) async {
    try {
      if (damageRule.id == null) {
        throw Exception('Rule ID is null');
      }

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

      // Update local list
      final index = damageRules.indexWhere((rule) => rule.id == damageRule.id);
      if (index != -1) {
        damageRules[index] = damageRule;
        damageRules.refresh();
      }

      log('Updated damage rule: ${damageRule.id}', name: 'DamageFeeController');
      Get.snackbar(
        'Success',
        'Damage rule updated successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      log('Error updating rule: $e', name: 'DamageFeeController');
      Get.snackbar(
        'Error',
        'Failed to update rule: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // ---------------------------------------------------------------------------
  // 5. DELETE DAMAGE RULE FROM FIRESTORE
  // ---------------------------------------------------------------------------
  Future<void> deleteRule(String id) async {
    try {
      await _db
          .collection('shops')
          .doc(shopId)
          .collection('inventory')
          .doc(itemId)
          .collection('damage_fees')
          .doc(id)
          .delete();

      damageRules.removeWhere((item) => item.id == id);

      log('Deleted damage rule: $id', name: 'DamageFeeController');
      Get.snackbar(
        'Success',
        'Damage rule removed successfully',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    } catch (e) {
      log('Error deleting rule: $e', name: 'DamageFeeController');
      Get.snackbar(
        'Error',
        'Failed to delete rule: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
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
      title: isEdit ? "Edit Damage Rule" : "Add Damage Rule",
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
              hint: "Select Damage Type",
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
              "Description (editable)",
              maxLine: 2,
            ),
            SizedBox(height: 12.h),
            // Fee Amount TextField
            _buildDialogTextField(feeController, "Fee Amount", isNumber: true),
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
              Get.snackbar(
                "Error",
                "Please select damage type and fee amount",
                backgroundColor: Colors.red.withOpacity(0.1),
                colorText: Colors.red,
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

            if (isEdit) {
              await _updateRule(damageRule);
            } else {
              await _addRule(damageRule);
            }

            Get.back();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A90E2), // Primary Blue
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            isEdit ? "Update" : "Save",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      cancel: SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: () => Get.back(),
          child: const Text(
            "Cancel",
            style: TextStyle(color: Color(0xFF94a3b8)),
          ),
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
        hintStyle: TextStyle(color: Colors.grey.withOpacity(0.5)),
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
