import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../controllers/billing_controller.dart';
import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/constants/a_sizes.dart';

class BillingView extends GetView<BillingController> {
  const BillingView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        title: Text(
          'billing_and_usage'.tr,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_3),
            onPressed: () {
              controller.openConfigureRatesDialog();
              _showRatesDialog(context);
            },
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchUsageData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(ASizes.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card - Toggles Mock Data
                _buildDemoModeHeader(context),
                SizedBox(height: 16.h),

                // Glassmorphism Bill Summary Card
                _buildBillSummaryCard(context),
                SizedBox(height: 24.h),

                // Operations break down
                Text(
                  'operations_breakdown'.tr,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildOperationsBreakdown(context),
                SizedBox(height: 24.h),

                // Historical Chart
                Text(
                  'daily_usage_history'.tr,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                _buildDailyUsageChart(context),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDemoModeHeader(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'billing_demo_mode'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    fontSize: 13.sp,
                  ),
                ),
                Text(
                  'billing_demo_desc'.tr,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: controller.isMockData.value,
            onChanged: controller.toggleMockData,
            activeThumbColor: colorScheme.primary,
          )
        ],
      ),
    );
  }

  Widget _buildBillSummaryCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currency = controller.shop.value?.currency ?? 'LKR';
    final formatter = NumberFormat.decimalPattern();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.85),
            colorScheme.secondary.withValues(alpha: 0.85),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'estimated_monthly_bill'.tr.toUpperCase(),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  DateFormat('MMMM yyyy').format(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            '$currency ${formatter.format(controller.finalCurrencyCost.toPrecision(2))}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'USD ${controller.finalUsdCost.toStringAsFixed(4)} (${'markup_applied'.tr})',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          Divider(color: Colors.white24, height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryStat(
                'reads'.tr,
                formatter.format(controller.totalReads.value),
              ),
              _buildSummaryStat(
                'writes'.tr,
                formatter.format(controller.totalWrites.value),
              ),
              _buildSummaryStat(
                'deletes'.tr,
                formatter.format(controller.totalDeletes.value),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: Colors.white60,
            fontSize: 9.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 15.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildOperationsBreakdown(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formatter = NumberFormat.decimalPattern();

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildBreakdownRow(
            context,
            icon: Iconsax.document_text5,
            iconColor: Colors.blue,
            title: 'reads'.tr,
            subtitle: '${formatter.format(controller.totalReads.value)} ops',
            usdCost: (controller.totalReads.value / 100000.0) * controller.rateReads.value,
          ),
          _buildDivider(context),
          _buildBreakdownRow(
            context,
            icon: Iconsax.document_upload5,
            iconColor: Colors.amber,
            title: 'writes'.tr,
            subtitle: '${formatter.format(controller.totalWrites.value)} ops',
            usdCost: (controller.totalWrites.value / 100000.0) * controller.rateWrites.value,
          ),
          _buildDivider(context),
          _buildBreakdownRow(
            context,
            icon: Iconsax.document_filter5,
            iconColor: Colors.red,
            title: 'deletes'.tr,
            subtitle: '${formatter.format(controller.totalDeletes.value)} ops',
            usdCost: (controller.totalDeletes.value / 100000.0) * controller.rateDeletes.value,
          ),
          _buildDivider(context),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _buildMathLine('billing_subtotal'.tr, 'USD ${controller.baseUsdCost.toStringAsFixed(4)}'),
                SizedBox(height: 8.h),
                _buildMathLine(
                  'billing_markup'.tr + ' (${controller.markupPercent.value}%)',
                  'USD ${controller.markupAmount.toStringAsFixed(4)}',
                ),
                SizedBox(height: 8.h),
                _buildMathLine(
                  'billing_exchange_rate'.tr,
                  '1 USD = ${controller.exchangeRate.value.toStringAsFixed(1)} ${controller.shop.value?.currency ?? 'LKR'}',
                  isMuted: true,
                ),
                Divider(height: 24.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'total_payable'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    Text(
                      '${controller.shop.value?.currency ?? 'LKR'} ${formatter.format(controller.finalCurrencyCost.toPrecision(2))}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                        fontSize: 16.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required double usdCost,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 22.w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'USD ${usdCost.toStringAsFixed(4)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMathLine(String label, String value, {bool isMuted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: isMuted ? Colors.grey : null,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: isMuted ? FontWeight.normal : FontWeight.w500,
            fontSize: 12.sp,
            color: isMuted ? Colors.grey : null,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyUsageChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sortedDays = controller.dailyUsage.keys.toList()..sort();
    
    if (sortedDays.isEmpty) {
      return Container(
        height: 180.h,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text('no_data_available'.tr),
        ),
      );
    }

    // Convert daily usage to BarChartGroups
    final List<BarChartGroupData> barGroups = [];
    int maxVal = 100;

    for (int idx = 0; idx < sortedDays.length; idx++) {
      final dayKey = sortedDays[idx];
      final dayData = controller.dailyUsage[dayKey] ?? {'reads': 0, 'writes': 0};
      
      final reads = dayData['reads'] ?? 0;
      final writes = dayData['writes'] ?? 0;

      if (reads > maxVal) maxVal = reads;
      if (writes > maxVal) maxVal = writes;

      barGroups.add(
        BarChartGroupData(
          x: idx,
          barRods: [
            BarChartRodData(
              toY: reads.toDouble(),
              color: Colors.blue.withValues(alpha: 0.8),
              width: 5.w,
            ),
            BarChartRodData(
              toY: writes.toDouble(),
              color: Colors.amber.withValues(alpha: 0.8),
              width: 5.w,
            ),
          ],
        ),
      );
    }

    return Container(
      height: 220.h,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(Colors.blue, 'reads'.tr),
              SizedBox(width: 24.w),
              _buildLegendItem(Colors.amber, 'writes'.tr),
            ],
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: BarChart(
              BarChartData(
                maxY: maxVal * 1.15,
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32.w,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return const SizedBox.shrink();
                        return Text(
                          value >= 1000 ? '${(value / 1000).toStringAsFixed(0)}k' : value.toStringAsFixed(0),
                          style: TextStyle(
                            fontSize: 8.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < sortedDays.length) {
                          // Show day label only for every 5th day to avoid crowding
                          final dayStr = sortedDays[idx].split('-').last;
                          if (int.parse(dayStr) % 5 == 0 || int.parse(dayStr) == 1) {
                            return Padding(
                              padding: EdgeInsets.only(top: 4.h),
                              child: Text(
                                dayStr,
                                style: TextStyle(
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            );
                          }
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showRatesDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    Get.dialog(
      AlertDialog(
        backgroundColor: colorScheme.surfaceContainer,
        title: Text(
          'configure_billing_rates'.tr,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogField(
                label: 'rate_reads_label'.tr,
                controller: controller.rateReadsController,
                suffix: 'USD / 100k',
              ),
              SizedBox(height: 12.h),
              _buildDialogField(
                label: 'rate_writes_label'.tr,
                controller: controller.rateWritesController,
                suffix: 'USD / 100k',
              ),
              SizedBox(height: 12.h),
              _buildDialogField(
                label: 'rate_deletes_label'.tr,
                controller: controller.rateDeletesController,
                suffix: 'USD / 100k',
              ),
              SizedBox(height: 12.h),
              _buildDialogField(
                label: 'markup_percent_label'.tr,
                controller: controller.markupController,
                suffix: '%',
              ),
              SizedBox(height: 12.h),
              _buildDialogField(
                label: 'exchange_rate_label'.tr,
                controller: controller.exchangeRateController,
                suffix: '${controller.shop.value?.currency ?? 'LKR'} per USD',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: controller.saveConfigurations,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: Text('save'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogField({
    required String label,
    required TextEditingController controller,
    required String suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            isDense: true,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            suffixText: suffix,
            suffixStyle: TextStyle(fontSize: 10.sp, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) =>
      Divider(color: Theme.of(context).colorScheme.outline, height: 1);
}
