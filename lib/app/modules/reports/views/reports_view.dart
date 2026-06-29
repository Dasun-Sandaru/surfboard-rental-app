import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../controllers/reports_controller.dart';
import '../../../../utils/common/a_app_bar.dart';

class ReportsView extends GetView<ReportsController> {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        centerTitle: true,
        title: Text(
          'reports_dashboard'.tr,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          Obx(() {
            if (controller.reportResults.isNotEmpty) {
              return Container(
                margin: EdgeInsets.only(right: 8.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: IconButton(
                  icon: Icon(Iconsax.document_download, color: colorScheme.primary),
                  onPressed: controller.exportToPdf,
                  tooltip: 'export_pdf'.tr,
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
                'filters'.tr,
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
          // Report Type Selector
          Obx(() => CustomDropdown<ReportType>(
            hintText: 'select_report_type'.tr,
            items: ReportType.values,
            initialItem: controller.selectedReportType.value,
            onChanged: (val) {
              if (val != null) controller.changeReportType(val);
            },
            decoration: CustomDropdownDecoration(
              closedFillColor: colorScheme.surface,
              expandedFillColor: colorScheme.surface,
              closedBorder: Border.all(color: colorScheme.outlineVariant, width: 0.5),
              closedBorderRadius: BorderRadius.circular(12.r),
            ),
            headerBuilder: (context, type, _) {
              return Text(
                type.name.tr,
                style: const TextStyle(fontWeight: FontWeight.w600),
              );
            },
            listItemBuilder: (context, type, isSelected, _) {
              return Text(
                type.name.tr,
                style: const TextStyle(fontWeight: FontWeight.w600),
              );
            },
          )),
          
          SizedBox(height: 12.h),
          
          // Date Range Picker
          Obx(() {
            final start = controller.startDate.value;
            final end = controller.endDate.value;
            final hasDates = start != null && end != null;
            final dateText = hasDates 
              ? '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d').format(end)}' 
              : 'select_dates'.tr;
              
            return InkWell(
              onTap: () => controller.pickDateRange(context),
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: colorScheme.outlineVariant, width: 0.5),
                ),
                child: Row(
                  children: [
                    Icon(Iconsax.calendar_1, size: 18.sp, color: colorScheme.primary),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        dateText,
                        style: TextStyle(
                          fontSize: 14.sp,
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
          
          // Status Dropdown
          Obx(() {
            final statuses = controller.availableStatuses;
            if (statuses.length <= 1) return const SizedBox.shrink();
            
            return Padding(
              padding: EdgeInsets.only(top: 12.h),
              child: CustomDropdown<String>(
                hintText: 'status'.tr,
                items: statuses,
                initialItem: controller.selectedStatus.value,
                onChanged: (val) {
                  if (val != null) controller.selectedStatus.value = val;
                },
                decoration: CustomDropdownDecoration(
                  closedFillColor: colorScheme.surface,
                  expandedFillColor: colorScheme.surface,
                  closedBorder: Border.all(color: colorScheme.outlineVariant, width: 0.5),
                  closedBorderRadius: BorderRadius.circular(12.r),
                  closedShadow: [],
                  expandedShadow: [],
                ),
                headerBuilder: (context, status, _) {
                  return Text(status.toLowerCase().tr);
                },
                listItemBuilder: (context, status, isSelected, _) {
                  final description = controller.getStatusDescription(status);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status.toLowerCase().tr,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (description.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: colorScheme.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            );
          }),
          
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
                      'generate_report'.tr, 
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
              'report_results'.tr,
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
                '${controller.reportResults.length} ${'records'.tr}',
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
                'ready_to_generate'.tr,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: colorScheme.onSurface),
              ),
              SizedBox(height: 8.h),
              Text(
                'select_filters_msg'.tr,
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
