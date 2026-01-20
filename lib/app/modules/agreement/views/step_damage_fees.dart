import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/agreement_controller.dart';

class StepDamageFees extends GetView<AgreementController> {
  const StepDamageFees({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: ListView( // Use ListView as this might get long
        children: [
          Text("Damage Policy", style: TextStyle(color: Colors.white, fontSize: 24.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Text("Select items to include in the agreement and set their replacement costs.", style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
          
          SizedBox(height: 24.h),

          // Dynamic List of Damage Options
          Obx(() => Column(
            children: controller.damageFees.keys.map((key) {
              final item = controller.damageFees[key]!;
              final isEnabled = item['enabled'];

              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF182c30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isEnabled ? const Color(0xFF4A90E2) : const Color(0xFF334155),
                  ),
                ),
                child: Column(
                  children: [
                    // Header Row: Toggle
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(key, style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.w500)),
                        Switch(
                          value: isEnabled,
                          onChanged: (val) => controller.toggleDamageFee(key, val),
                          activeColor: const Color(0xFF4A90E2),
                        )
                      ],
                    ),
                    
                    // Input Row: Price (Only show if enabled)
                    if (isEnabled) ...[
                      Divider(color: const Color(0xFF334155)),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Text("Fee Amount:", style: TextStyle(color: Colors.grey)),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: SizedBox(
                              height: 40.h,
                              child: TextField(
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  prefixText: "\$ ",
                                  prefixStyle: const TextStyle(color: Colors.white),
                                  filled: true,
                                  fillColor: const Color(0xFF101f22),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                                ),
                                onChanged: (val) => controller.updateDamagePrice(key, val),
                              ),
                            ),
                          ),
                        ],
                      )
                    ]
                  ],
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }
}