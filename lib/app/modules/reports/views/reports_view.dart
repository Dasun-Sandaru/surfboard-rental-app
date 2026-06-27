import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../controllers/reports_controller.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Reports Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Obx(() {
            if (controller.reportResults.isNotEmpty) {
              return Container(
                margin: EdgeInsets.only(right: 16.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  icon: Icon(Iconsax.document_download, color: colorScheme.primary),
                  onPressed: controller.exportToPdf,
                  tooltip: 'Export PDF',
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Column(
        children: [
          _buildFilterPanel(context),
          _buildSummaryBar(context),
          Expanded(
            child: _buildResultsArea(context),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPanel(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.filter, size: 20.sp, color: colorScheme.primary),
              SizedBox(width: 8.w),
              Text(
                'Filters',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Report Type Selector
          Obx(() => DropdownButtonFormField<ReportType>(
            value: controller.selectedReportType.value,
            icon: const Icon(Iconsax.arrow_bottom),
            decoration: InputDecoration(
              labelText: 'Select Report Type',
              filled: true,
              fillColor: colorScheme.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
            items: ReportType.values.map((type) {
              return DropdownMenuItem(
                value: type,
                child: Text(
                  type.name.capitalizeFirst ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
            onChanged: (val) {
              if (val != null) controller.changeReportType(val);
            },
          )),
          
          SizedBox(height: 12.h),
          
          Row(
            children: [
              // Date Range Picker
              Expanded(
                flex: 2,
                child: Obx(() {
                  final start = controller.startDate.value;
                  final end = controller.endDate.value;
                  final hasDates = start != null && end != null;
                  final dateText = hasDates 
                    ? '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}' 
                    : 'Select Dates';
                    
                  return InkWell(
                    onTap: () => controller.pickDateRange(context),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Icon(Iconsax.calendar_1, size: 18.sp, color: colorScheme.primary),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              dateText,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: hasDates ? FontWeight.bold : FontWeight.normal,
                                color: hasDates ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              
              SizedBox(width: 12.w),
              
              // Status Dropdown
              Expanded(
                flex: 1,
                child: Obx(() {
                  final statuses = controller.availableStatuses;
                  if (statuses.length == 1) return const SizedBox.shrink();
                  
                  return DropdownButtonFormField<String>(
                    value: controller.selectedStatus.value,
                    isExpanded: true,
                    icon: const Icon(Iconsax.arrow_bottom, size: 16),
                    decoration: InputDecoration(
                      labelText: 'Status',
                      filled: true,
                      fillColor: colorScheme.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                    ),
                    items: statuses.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.capitalizeFirst ?? ''),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.selectedStatus.value = val;
                    },
                  );
                }),
              ),
            ],
          ),
          
          SizedBox(height: 20.h),
          
          // Generate Button
          SizedBox(
            width: double.infinity,
            height: 54.h,
            child: Obx(() => ElevatedButton.icon(
              onPressed: controller.isLoading.value ? null : controller.generateReport,
              icon: controller.isLoading.value 
                  ? const SizedBox.shrink() 
                  : const Icon(Iconsax.magic_star),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
              ),
              label: controller.isLoading.value
                  ? SizedBox(
                      width: 24.sp,
                      height: 24.sp,
                      child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Generate Report', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                    ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Obx(() {
      if (controller.reportResults.isEmpty || controller.isLoading.value) {
        return const SizedBox.shrink();
      }
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Report Results',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: colorScheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                '${controller.reportResults.length} Records',
                style: TextStyle(
                  color: colorScheme.onTertiaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildResultsArea(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (controller.reportResults.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.folder_open, size: 64.sp, color: colorScheme.primary.withValues(alpha: 0.5)),
              ),
              SizedBox(height: 24.h),
              Text(
                'Ready to Generate',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: colorScheme.onSurface),
              ),
              SizedBox(height: 8.h),
              Text(
                'Select your filters above\nand click Generate Report.',
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14.sp),
              ),
            ],
          ),
        );
      }

      final columns = controller.reportColumns;
      
      return Container(
        margin: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)),
                dividerThickness: 0.5,
                columnSpacing: 24.w,
                columns: columns.map((c) => DataColumn(
                  label: Text(
                    c, 
                    style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary),
                  )
                )).toList(),
                rows: controller.reportResults.map((row) {
                  return DataRow(
                    cells: columns.map((c) => DataCell(
                      Text(
                        row[c]?.toString() ?? '-',
                        style: TextStyle(color: colorScheme.onSurface),
                      )
                    )).toList(),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      );
    });
  }
}
