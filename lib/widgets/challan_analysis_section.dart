// widgets/dl_analysis_section.dart
import 'package:flutter/material.dart';
import 'package:trafficlly/utills/export.dart';

class ChallanAnalysisSection extends StatelessWidget {
  final String title;
  final Widget firstChart;
  final String firstChartTitle;
  final Widget secondChart;
  final String secondChartTitle;
  final IconData headerIcon;

  const ChallanAnalysisSection({
    Key? key,
    required this.title,
    required this.firstChart,
    required this.firstChartTitle,
    required this.secondChart,
    required this.secondChartTitle,
    this.headerIcon = Icons.analytics_outlined,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                text: title,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.appBlack1,
              ),
              Icon(headerIcon, color: AppColors.primary, size: 28),
            ],
          ),
        ),
        SizedBox(height: 10.h),

        // First Chart Card
        _buildChartCard(firstChartTitle, firstChart),
        SizedBox(height: 10.h),

        // Second Chart Card
        _buildChartCard(secondChartTitle, secondChart),
      ],
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.grey.withOpacity(0.1)),
      ),
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: title,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.appBlack1,
          ),
          SizedBox(height: 16.h),
          SizedBox(height: 200.h, width: double.infinity, child: chart),
        ],
      ),
    );
  }
}
