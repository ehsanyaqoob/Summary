import 'package:fl_chart/fl_chart.dart';
import 'package:trafficlly/utills/export.dart';

class ChallanPieChart extends StatelessWidget {
  final ChallanModel data;
  final bool showAmount;

  const ChallanPieChart({
    required this.data,
    this.showAmount = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalValue = showAmount 
        ? data.fineAmount 
        : (data.paidTickets + data.unpaidTickets).toDouble();
    final paidValue = showAmount ? data.paidAmount : data.paidTickets.toDouble();
    final unpaidValue = showAmount ? data.unpaidAmount : data.unpaidTickets.toDouble();
    
    final bool hasData = totalValue > 0;
    final paidPercent = hasData ? (paidValue / totalValue) * 100 : 0.0;
    final unpaidPercent = hasData ? (unpaidValue / totalValue) * 100 : 0.0;

    // When both values are 0, fl_chart can't compute arc angles and the chart
    // disappears. Show a neutral placeholder ring instead.
    final List<PieChartSectionData> sections = hasData
        ? [
            PieChartSectionData(
              value: paidValue > 0 ? paidValue : 0.001, // avoid pure-zero section
              color: paidValue > 0 ? AppColors.lime : AppColors.lime.withOpacity(0.2),
              title: paidValue > 0 ? '${paidPercent.toStringAsFixed(1)}%' : '',
              radius: 60,
              titleStyle: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              badgeWidget: paidValue > 0 ? _badgeWidget(Icons.check, AppColors.lime) : null,
              badgePositionPercentageOffset: 0.98,
            ),
            PieChartSectionData(
              value: unpaidValue > 0 ? unpaidValue : 0.001,
              color: unpaidValue > 0 ? AppColors.appRed : AppColors.appRed.withOpacity(0.2),
              title: unpaidValue > 0 ? '${unpaidPercent.toStringAsFixed(1)}%' : '',
              radius: 60,
              titleStyle: TextStyle(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              badgeWidget: unpaidValue > 0 ? _badgeWidget(Icons.close, AppColors.appRed) : null,
              badgePositionPercentageOffset: 0.98,
            ),
          ]
        : [
            // Empty-state: single grey ring so the chart never vanishes
            PieChartSectionData(
              value: 1,
              color: AppColors.grey.withOpacity(0.2),
              title: '',
              radius: 60,
              showTitle: false,
            ),
          ];

    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            centerSpaceRadius: 60,
            sectionsSpace: hasData ? 2 : 0,
            startDegreeOffset: -90,
            sections: sections,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              showAmount ? 'Amount' : 'Tickets',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            CustomText(
              text: showAmount 
                  ? 'PKR ${totalValue.toStringAsFixed(0)}'
                  : totalValue.toInt().toString(),
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.appBlack1,
            ),
          ],
        ),
      ],
    );
  }

  Widget _badgeWidget(IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Icon(icon, size: 16, color: AppColors.white),
    );
  }
}