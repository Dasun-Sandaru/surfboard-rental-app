import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../../../utils/common/a_app_bar.dart';
import '../../../../utils/constants/a_sizes.dart';
import '../../../../utils/helper/a_formatter.dart';
import '../controllers/analytics_controller.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AAppBar(
        showbackArrow: true,
        centerTitle: true,
        title: Text(
          'analytics_dashboard'.tr,
          style: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAnalytics,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(ASizes.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Date Selector Row
                _buildDateSelector(context),
                SizedBox(height: 24.h),

                /// Stat Metrics Cards
                _buildStatMetrics(context),
                SizedBox(height: 24.h),

                /// Revenue Line Chart
                _buildSectionTitle(context, 'revenue_trend'.tr),
                SizedBox(height: 12.h),
                _buildRevenueChart(context),
                SizedBox(height: 24.h),

                /// Inventory Distribution & Board Type Utilization
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(context, 'board_status'.tr),
                          SizedBox(height: 12.h),
                          _buildStatusPieChart(context),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle(context, 'board_types'.tr),
                          SizedBox(height: 12.h),
                          _buildTypesBarChart(context),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                /// Popular Surfboards List
                _buildSectionTitle(context, 'popular_boards'.tr),
                SizedBox(height: 12.h),
                _buildPopularBoardsList(context),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.2,
      ),
    );
  }

  // ===========================================================================
  // DATE RANGE SELECTOR
  // ===========================================================================
  Widget _buildDateSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final start = controller.startDate.value;
    final end = controller.endDate.value;
    final hasDates = start != null && end != null;
    final dateText = hasDates
        ? '${DateFormat('MMM d, yyyy').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}'
        : 'select_dates'.tr;

    return InkWell(
      onTap: () => controller.pickDateRange(context),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: colorScheme.outline, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Iconsax.calendar_1, size: 20.sp, color: colorScheme.primary),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                dateText,
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                ),
              ),
            ),
            Icon(Iconsax.arrow_down_14, size: 16.sp, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // STAT CARDS GRID
  // ===========================================================================
  Widget _buildStatMetrics(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.45,
      ),
      children: [
        _buildMetricCard(
          context,
          'total_revenue'.tr,
          AFormatter.formatCurrency(controller.totalRevenue.value),
          Iconsax.money_3,
          colorScheme.primary,
        ),
        _buildMetricCard(
          context,
          'total_rentals'.tr,
          controller.totalRentals.value.toString(),
          Iconsax.receipt,
          Colors.orange,
        ),
        _buildMetricCard(
          context,
          'average_order'.tr,
          AFormatter.formatCurrency(controller.averageOrderValue.value),
          Iconsax.graph,
          Colors.teal,
        ),
        _buildMetricCard(
          context,
          'active_rentals'.tr,
          controller.activeRentals.value.toString(),
          Iconsax.timer_1,
          Colors.blue,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color accentColor,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: accentColor, size: 16.sp),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            value,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // REVENUE TIME SERIES LINE CHART
  // ===========================================================================
  Widget _buildRevenueChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final entries = controller.revenueTimeSeries.entries.toList();

    if (entries.isEmpty) {
      return Container(
        height: 180.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          'no_revenue_data'.tr,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (int i = 0; i < entries.length; i++) {
      spots.add(FlSpot(i.toDouble(), entries[i].value));
    }

    return Container(
      height: 220.h,
      padding: EdgeInsets.only(top: 24.h, bottom: 8.h, right: 16.w, left: 8.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline, width: 0.5),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40.w,
                getTitlesWidget: (val, meta) {
                  return Text(
                    val >= 1000 ? '${(val / 1000).toStringAsFixed(1)}k' : val.toInt().toString(),
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10.sp),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24.h,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx >= 0 && idx < entries.length) {
                    // Show label every few steps to avoid clutter
                    final step = (entries.length / 5).ceil();
                    if (idx % step == 0 || idx == entries.length - 1) {
                      return Text(
                        DateFormat('MM/dd').format(entries[idx].key),
                        style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 9.sp),
                      );
                    }
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: colorScheme.primary,
              barWidth: 3.w,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // SURFBOARD UTILIZATION PIE CHART
  // ===========================================================================
  Widget _buildStatusPieChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final dist = controller.inventoryStatusDistribution;

    if (dist.isEmpty) {
      return Container(
        height: 150.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text('no_data'.tr),
      );
    }

    final sections = <PieChartSectionData>[];
    final colorMap = {
      'available': Colors.green,
      'rented': colorScheme.primary,
      'repair': Colors.orange,
      'damaged': Colors.red,
      'retired': Colors.grey,
    };

    dist.forEach((status, count) {
      final color = colorMap[status] ?? colorScheme.secondary;
      sections.add(
        PieChartSectionData(
          color: color,
          value: count.toDouble(),
          title: count.toString(),
          radius: 40.r,
          titleStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });

    return Container(
      height: 150.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline, width: 0.5),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 30.r,
              sections: sections,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SURFBOARD TYPE BAR CHART
  // ===========================================================================
  Widget _buildTypesBarChart(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final types = controller.surfboardTypeUtilization.entries.toList();

    if (types.isEmpty) {
      return Container(
        height: 150.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text('no_data'.tr),
      );
    }

    final groups = <BarChartGroupData>[];
    for (int i = 0; i < types.length; i++) {
      groups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: types[i].value.toDouble(),
              color: colorScheme.primary,
              width: 14.w,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ],
        ),
      );
    }

    return Container(
      height: 150.h,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline, width: 0.5),
      ),
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24.w,
                getTitlesWidget: (val, meta) {
                  return Text(
                    val.toInt().toString(),
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10.sp),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20.h,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx >= 0 && idx < types.length) {
                    final label = types[idx].key;
                    // truncate if too long
                    final display = label.length > 5 ? label.substring(0, 5) : label;
                    return Text(
                      display,
                      style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 9.sp),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          barGroups: groups,
        ),
      ),
    );
  }

  // ===========================================================================
  // POPULAR BOARDS LIST
  // ===========================================================================
  Widget _buildPopularBoardsList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final popular = controller.boardPopularity.entries.toList();

    if (popular.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          'no_rentals_found'.tr,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: colorScheme.outline, width: 0.5),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: popular.length,
        separatorBuilder: (context, index) => Divider(color: colorScheme.outline, height: 1),
        itemBuilder: (context, index) {
          final entry = popular[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
              child: Text(
                '${index + 1}',
                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(
              entry.key,
              style: TextStyle(color: colorScheme.onSurface, fontWeight: FontWeight.w600),
            ),
            trailing: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: colorScheme.outline),
              ),
              child: Text(
                '${entry.value} ${'rentals_count'.tr}',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
