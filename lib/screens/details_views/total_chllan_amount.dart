
import 'package:trafficlly/utills/export.dart';
import 'package:trafficlly/widgets/app_bar_widget.dart';
import 'package:trafficlly/widgets/challan_analysis_section.dart';
import 'package:trafficlly/widgets/challan_bar_chart.dart';
import 'package:trafficlly/widgets/challan_pie_chart.dart';
import 'package:trafficlly/widgets/custom_button.dart';
import 'package:trafficlly/widgets/shimmer.dart';
import 'package:intl/intl.dart';

class TotalChallanAmount extends StatefulWidget {
  const TotalChallanAmount({Key? key}) : super(key: key);

  @override
  _TotalChallanAmountState createState() => _TotalChallanAmountState();
}

class _TotalChallanAmountState extends State<TotalChallanAmount> {
  final ChallanController controller = Get.find<ChallanController>();
final NumberFormat _amountFormat = NumberFormat('#,##0', 'en_PK');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  void _fetchData() {
    controller.fetchChallanDataOnFilter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: "Challan Amount",
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: AppColors.white, size: 28.sp),
            onPressed: _showFilterBottomSheet,
          ),
          IconButton(
            icon: Icon(Icons.sync, color: AppColors.white, size: 28.sp),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return ShimmerClass();
        }

        final data = controller.challanData.value;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            children: [
              _buildFilterBadge(),
              SizedBox(height: 20.h),
              _buildAmountCard(data),
              SizedBox(height: 20.h),
              _buildAmountBreakdown(data),
              SizedBox(height: 20.h),
              ChallanAnalysisSection(
                title: "Amount Analysis",
                firstChartTitle: "Amount Comparison",
                firstChart: ChallanBarChart(data: data, showAmount: true),
                secondChartTitle: "Amount Distribution",
                secondChart: ChallanPieChart(data: data, showAmount: true),
              ),
              SizedBox(height: 30.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 40.w),
                child: CustomButton(
                  onTap: _fetchData,
                  title: "Refresh Data",
                  fillColor: true,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildFilterBadge() {
    return Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.2),
                AppColors.primary.withOpacity(0.1)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.calendar_today, size: 16.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              CustomText(
                text: controller.selectedFilter.value.capitalizeFirst ?? "Daily",
                fontSize: 14.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ));
  }

  Widget _buildAmountCard(ChallanModel data) {
    final paidFraction = data.fineAmount == 0 ? 0.0 : data.paidAmount / data.fineAmount;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primary, AppColors.appSecondary],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            CustomText(
              text: 'Total Challan Amount',
              fontSize: 18.sp,
              color: AppColors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 12.h),
            CustomText(
  text: 'PKR ${_amountFormat.format(data.fineAmount)}',
  fontSize: 36.sp,
  fontWeight: FontWeight.bold,
  color: AppColors.white,
),
            SizedBox(height: 16.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(3.r),
              child: LinearProgressIndicator(
                value: paidFraction,
                backgroundColor: AppColors.white.withOpacity(0.3),
                color: AppColors.lime,
                minHeight: 6.h,
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              // Paid / Unpaid
_buildAmountStatItem(
  'Paid', 
  'PKR ${_amountFormat.format(data.paidAmount)}', 
  AppColors.lime
),
_buildAmountStatItem(
  'Unpaid', 
  'PKR ${_amountFormat.format(data.unpaidAmount)}', 
  AppColors.orange
),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountStatItem(String label, String value, Color color) {
    return Column(
      children: [
        CustomText(
          text: label,
          fontSize: 14.sp,
          color: AppColors.white.withOpacity(0.8),
        ),
        SizedBox(height: 4.h),
        CustomText(
          text: value,
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ],
    );
  }

  Widget _buildAmountBreakdown(ChallanModel data) {
    final totalAmount = data.fineAmount;
    final paidPercent = totalAmount == 0 ? 0.0 : (data.paidAmount / totalAmount) * 100;
    final unpaidPercent = totalAmount == 0 ? 0.0 : (data.unpaidAmount / totalAmount) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: CustomText(
            text: 'Amount Breakdown',
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.appBlack1,
          ),
        ),
        SizedBox(height: 12.h),
        // Amount Breakdown
_buildAmountBreakdownItem(
  Icons.check_circle_outlined, 
  'Paid Amount', 
  'PKR ${_amountFormat.format(data.paidAmount)}', 
  '${paidPercent.toStringAsFixed(1)}%', 
  AppColors.lime
),
_buildAmountBreakdownItem(
  Icons.cancel_outlined, 
  'Unpaid Amount', 
  'PKR ${_amountFormat.format(data.unpaidAmount)}', 
  '${unpaidPercent.toStringAsFixed(1)}%', 
  AppColors.appRed
),
      ],
    );
  }

  Widget _buildAmountBreakdownItem(IconData icon, String label, String value, String percent, Color color) {
    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.symmetric(vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.appBlack1.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: label,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.appBlack1,
                ),
                SizedBox(height: 4.h),
                CustomText(
                  text: percent,
                  fontSize: 14.sp,
                  color: AppColors.grey,
                ),
              ],
            ),
          ),
          CustomText(
            text: value,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomText(
              text: 'Select Time Period',
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.appBlack1,
            ),
            SizedBox(height: 16.h),
            ...['Daily', 'Weekly', 'Monthly', 'Yearly', 'Overall'].map((filter) {
              IconData filterIcon;
              switch (filter) {
                case 'Daily': filterIcon = Icons.today; break;
                case 'Weekly': filterIcon = Icons.date_range; break;
                case 'Monthly': filterIcon = Icons.calendar_month; break;
                case 'Yearly': filterIcon = Icons.calendar_view_month; break;
                case 'Overall': filterIcon = Icons.all_inclusive; break;
                default: filterIcon = Icons.calendar_today_outlined;
              }
              return ListTile(
                  leading: Icon(filterIcon, color: AppColors.primary),
                  title: CustomText(
                    text: filter,
                    fontSize: 16.sp,
                    color: AppColors.appBlack1,
                  ),
                  trailing: Obx(() => controller.selectedFilter.value == filter.toLowerCase()
                      ? Icon(Icons.check, color: AppColors.primary)
                      : SizedBox.shrink()),
                  onTap: () {
                    controller.changeFilter(filter.toLowerCase());
                    Get.back();
                    _fetchData();
                  },
                );
            }),
          ],
        ),
      ),
    );
  }
}