import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart'; // Needed for sizing in dialog

class DamageFeeController extends GetxController {
  // Dummy Data
  final RxList<Map<String, dynamic>> damageRules = <Map<String, dynamic>>[
    {
      "id": "1",
      "item_id": "ALL", // Applies to all items or specific SKU
      "damage_type": "Major Ding",
      "description": "Deep cracks affecting the core foam.",
      "fee_amount": 100.00,
      "active_status": true,
    },
    {
      "id": "2",
      "item_id": "ALL",
      "damage_type": "Broken Fin",
      "description": "Fin box damage or snapped fin.",
      "fee_amount": 50.00,
      "active_status": true,
    },
    {
      "id": "3",
      "item_id": "ALL",
      "damage_type": "Snapped Leash",
      "description": "Leash cord broken.",
      "fee_amount": 25.00,
      "active_status": true,
    },
    {
      "id": "4",
      "item_id": "ALL",
      "damage_type": "Pressure Dent",
      "description": "Visible dent on surface.",
      "fee_amount": 20.00,
      "active_status": false, // Inactive example
    },
  ].obs;

  // Controllers for Add/Edit Dialog
  final typeController = TextEditingController();
  final descController = TextEditingController();
  final feeController = TextEditingController();

  void deleteRule(String id) {
    damageRules.removeWhere((item) => item['id'] == id);
    Get.snackbar(
      "Deleted",
      "Damage rule removed successfully",
      backgroundColor: Colors.red.withOpacity(0.1),
      colorText: Colors.red,
    );
  }

  void openAddEditDialog({Map<String, dynamic>? rule}) {
    final isEdit = rule != null;

    // Reset or Populate
    if (isEdit) {
      typeController.text = rule['damage_type'];
      descController.text = rule['description'];
      feeController.text = rule['fee_amount'].toString();
    } else {
      typeController.clear();
      descController.clear();
      feeController.clear();
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
      content: Column(
        children: [
          _buildDialogTextField(
            typeController,
            "Damage Type (e.g. Broken Fin)",
          ),
          SizedBox(height: 12.h),
          _buildDialogTextField(descController, "Description", maxLine: 3),
          SizedBox(height: 12.h),
          _buildDialogTextField(feeController, "Fee Amount", isNumber: true),
        ],
      ),
      confirm: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            // Save Logic Here
            if (typeController.text.isNotEmpty &&
                feeController.text.isNotEmpty) {
              if (isEdit) {
                // Update logic (mock)
                rule['damage_type'] = typeController.text;
                rule['description'] = descController.text;
                rule['fee_amount'] = double.tryParse(feeController.text) ?? 0.0;
                damageRules.refresh();
              } else {
                // Add logic (mock)
                damageRules.add({
                  "id": DateTime.now().toString(),
                  "damage_type": typeController.text,
                  "description": descController.text,
                  "fee_amount": double.tryParse(feeController.text) ?? 0.0,
                  "active_status": true,
                  "item_id": "ALL",
                });
              }
              Get.back();
            }
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
