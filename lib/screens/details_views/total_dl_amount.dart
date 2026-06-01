import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:trafficlly/controllers/dl_controller.dart';
import 'package:trafficlly/models/dl_model.dart';
import 'package:trafficlly/utills/export.dart';
import 'package:trafficlly/widgets/App_Bar_Widget.dart';
import 'package:trafficlly/widgets/custom_button.dart';
import 'package:trafficlly/widgets/shimmer.dart';
import 'package:intl/intl.dart';

class TotalDlAmount extends StatefulWidget {
  const TotalDlAmount({Key? key}) : super(key: key);

  @override
  _TotalDlAmountState createState() => _TotalDlAmountState();
}

class _TotalDlAmountState extends State<TotalDlAmount> {
  final DrivingLicenceController controller = Get.find<DrivingLicenceController>();
  RxBool showShimmerOnRefresh = false.obs;
  final NumberFormat _amountFormat = NumberFormat('#,##0', 'en_PK');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchData());
  }

  void _fetchData() async {
    showShimmerOnRefresh.value = true;
    await controller.fetchLicenceDataOnFilter();
    
    // Show shimmer for minimum 2 seconds for better UX
    await Future.delayed(Duration(seconds: 2));
    showShimmerOnRefresh.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: "Driving License Amount",
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
        // Show shimmer for initial load or when refreshing
        if (controller.isLoading.value && controller.isInitialLoad.value || showShimmerOnRefresh.value) {
          return ShimmerClass();
        }

        final data = controller.licenceData.value;

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
              _buildLearnerStatistics(data),
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

  Widget _buildAmountCard(DrivingLicenceModel data) {
    final totalAmount = data.getTotalAmount(controller.selectedFilter.value);
    final paidAmount = data.getPaidAmount(controller.selectedFilter.value);
    final paidFraction = totalAmount == 0 ? 0.0 : paidAmount / totalAmount;

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
              text: 'Total DL Amount',
              fontSize: 18.sp,
              color: AppColors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
            SizedBox(height: 12.h),
           // Total DL Amount
CustomText(
  text: 'PKR ${_amountFormat.format(totalAmount)}',
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
                // Paid / Unpaid amounts
_buildAmountStatItem(
  'Paid', 
  'PKR ${_amountFormat.format(paidAmount)}', 
  AppColors.lime
),
_buildAmountStatItem(
  'Unpaid', 
  'PKR ${_amountFormat.format(data.getUnpaidAmount(controller.selectedFilter.value))}', 
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

  Widget _buildAmountBreakdown(DrivingLicenceModel data) {
    final totalAmount = data.getTotalAmount(controller.selectedFilter.value);
    final paidAmount = data.getPaidAmount(controller.selectedFilter.value);
    final unpaidAmount = data.getUnpaidAmount(controller.selectedFilter.value);
    
    final paidPercent = totalAmount == 0 ? 0.0 : (paidAmount / totalAmount) * 100;
    final unpaidPercent = totalAmount == 0 ? 0.0 : (unpaidAmount / totalAmount) * 100;

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
  'PKR ${_amountFormat.format(paidAmount)}', 
  '${paidPercent.toStringAsFixed(1)}%', 
  AppColors.lime
),
_buildAmountBreakdownItem(
  Icons.cancel_outlined, 
  'Unpaid Amount', 
  'PKR ${_amountFormat.format(unpaidAmount)}', 
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

  Widget _buildLearnerStatistics(DrivingLicenceModel data) {
    final totalLearners = data.approveLearner + data.inprocessLearner + data.pendingLearner + data.rejectedLearner;
    final approvedPercent = totalLearners == 0 ? 0.0 : (data.approveLearner / totalLearners) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w),
          child: CustomText(
            text: 'Learner Statistics',
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.appBlack1,
          ),
        ),
        SizedBox(height: 12.h),
        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              children: [
                _buildLearnerStatItem(
                  Icons.verified,
                  'Approved Learners',
                  data.approveLearner.toString(),
                  '${approvedPercent.toStringAsFixed(1)}%',
                  AppColors.lime,
                ),
                SizedBox(height: 12.h),
                _buildLearnerStatItem(
                  Icons.hourglass_empty,
                  'In Process',
                  data.inprocessLearner.toString(),
                  '${totalLearners == 0 ? 0.0 : (data.inprocessLearner / totalLearners) * 100}%',
                  AppColors.appSecondary,
                ),
                SizedBox(height: 12.h),
                _buildLearnerStatItem(
                  Icons.pending,
                  'Pending',
                  data.pendingLearner.toString(),
                  '${totalLearners == 0 ? 0.0 : (data.pendingLearner / totalLearners) * 100}%',
                  AppColors.amber,
                ),
                SizedBox(height: 12.h),
                _buildLearnerStatItem(
                  Icons.cancel,
                  'Rejected',
                  data.rejectedLearner.toString(),
                  '${totalLearners == 0 ? 0.0 : (data.rejectedLearner / totalLearners) * 100}%',
                  AppColors.appRed,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLearnerStatItem(IconData icon, String label, String value, String percent, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: label,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.appBlack1,
                ),
                SizedBox(height: 2.h),
                CustomText(
                  text: percent,
                  fontSize: 12.sp,
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
            ...['Daily', 'Weekly', 'Monthly', 'Yearly'].map((filter) {
              IconData filterIcon;
              switch (filter) {
                case 'Daily': filterIcon = Icons.today; break;
                case 'Weekly': filterIcon = Icons.date_range; break;
                case 'Monthly': filterIcon = Icons.calendar_month; break;
                case 'Yearly': filterIcon = Icons.calendar_view_month; break;
                default: filterIcon = Icons.calendar_today_outlined;
              }
              return ListTile(
                  leading: Icon(filterIcon, color: AppColors.primary),
                  title: CustomText(
                    text: filter,
                    fontSize: 16.sp,
                    color: AppColors.appBlack1,
                  ),
                  trailing: Obx(() => controller.selectedFilter.value == filter
                      ? Icon(Icons.check, color: AppColors.primary)
                      : SizedBox.shrink()),
                  onTap: () {
                    controller.changeFilter(filter);
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