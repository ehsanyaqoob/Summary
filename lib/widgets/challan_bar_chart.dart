import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart'; // Added missing import
import 'package:trafficlly/utills/export.dart';

class ChallanBarChart extends StatelessWidget {
  final ChallanModel data;
  final bool showAmount;

  const ChallanBarChart({
    required this.data,
    this.showAmount = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final double paidVal = showAmount
        ? data.paidAmount
        : data.paidTickets.toDouble();
    final double unpaidVal = showAmount
        ? data.unpaidAmount
        : data.unpaidTickets.toDouble();

    final double rawMax = showAmount
        ? (data.fineAmount * 1.2)
        : (data.eTicket * 1.2);
    final double maxValue = showAmount
        ? rawMax.clamp(1000.0, double.infinity)
        : rawMax.clamp(10.0, double.infinity);

    // Ensure interval is never zero or negative
    final double gridInterval = maxValue > 0 ? maxValue / 5 : 1;

    // Color definitions based on your AppColors for Paid (Green/Lime) and Unpaid (Red/AppRed)
    final List<Color> paidGradientColors = [
      AppColors.violatorHistory, // Using a specific green from Status Colors
      AppColors.lime,
    ];

    final List<Color> unpaidGradientColors = [
      const Color(0xFFFF5252), // Original red accent
      AppColors.appRed,
    ];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue,
        minY: 0, // Ensure the chart starts from zero
        barTouchData: BarTouchData(
          enabled: false, // Disabling touch data for cleaner presentation
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine:
              false, // Vertical lines are often redundant in bar charts
          drawHorizontalLine: true,
          horizontalInterval: gridInterval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.grey.withOpacity(0.15), // Lighter grid line
            strokeWidth: 1,
            dashArray: [5, 5], // Add a subtle dash for modernity
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30.h,
              getTitlesWidget: (value, meta) {
                String label;
                switch (value.toInt()) {
                  case 0:
                    label = 'Paid';
                    break;
                  case 1:
                    label = 'Unpaid';
                    break;
                  default:
                    return const SizedBox.shrink();
                }
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 8.0,
                  child: CustomText(
                    text: label,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.appBlack1,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: gridInterval,
              reservedSize: 50.w,
              getTitlesWidget: (value, meta) {
                final String text = showAmount
                    ? 'PKR ${(value / 1000).toStringAsFixed(0)}k'
                    : value.toInt().toString();

                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  space: 4.0,
                  child: CustomText(
                    text: text,
                    fontSize: 10.sp,
                    color: AppColors
                        .text, // Use a softer text color for axis labels
                  ),
                );
              },
            ),
          ),
          rightTitles: const AxisTitles(),
          topTitles: const AxisTitles(),
        ),
        barGroups: [
          // Paid Challans Group (x: 0)
          BarChartGroupData(
            x: 0,
            barRods: [
              BarChartRodData(
                toY: paidVal,
                gradient: LinearGradient(
                  colors: paidGradientColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(
                  6.w,
                ), // Rounded corners based on screen width
                width: 28.w, // Wider bars for better visual weight
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxValue,
                  color: AppColors
                      .fieldColor, // Use a lighter background color for the back rod
                ),
              ),
            ],
          ),
          // Unpaid Challans Group (x: 1)
          BarChartGroupData(
            x: 1,
            barRods: [
              BarChartRodData(
                toY: unpaidVal,
                gradient: LinearGradient(
                  colors: unpaidGradientColors,
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(6.w),
                width: 28.w,
                backDrawRodData: BackgroundBarChartRodData(
                  show: true,
                  toY: maxValue,
                  color: AppColors.fieldColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
