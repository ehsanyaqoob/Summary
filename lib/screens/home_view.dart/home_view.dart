import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trafficlly/utills/export.dart';
import 'package:trafficlly/widgets/challan_analysis_section.dart';
import 'package:trafficlly/widgets/challan_bar_chart.dart';
import 'package:trafficlly/widgets/challan_pie_chart.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final ChallanController challanController = Get.put(ChallanController());
  final DrivingLicenceController dlController = Get.put(
    DrivingLicenceController(),
  );
  final TotalDlAmountController dlAmountController = Get.put(
    TotalDlAmountController(),
  );
  DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    challanController.selectedFilter.value = 'daily';
  }

  Future<void> _refreshData() async {
    await Future.wait([
      challanController.fetchChallanDataWithDelay(),
      dlController.fetchLicenceDataWithDelay(),
      dlAmountController.fetchLatestAmount(),
    ]);
  }

  Future<bool> _onWillPop() async {
    final currentTime = DateTime.now();
    if (_lastBackPressTime == null ||
        currentTime.difference(_lastBackPressTime!) >
            const Duration(seconds: 2)) {
      _lastBackPressTime = currentTime;
      Fluttertoast.showToast(
        msg: "Press back again to exit app",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.primary.withOpacity(0.9),
        textColor: AppColors.white,
        fontSize: 14.0.sp,
      );
      return false;
    }
    SystemNavigator.pop();
    return true;
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year.toString();
    const weekdays = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[now.weekday];
    return "$weekday, $day/$month/$year";
  }

  @override
  Widget build(BuildContext context) {
    const double paddingHorizontal = 16.0;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: AppColors.scaffoldBackgroundColor,
          surfaceTintColor: AppColors.scaffoldBackgroundColor,
          toolbarHeight: 70.h,
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: paddingHorizontal * 0.2),
            child: _buildHeader(),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          color: AppColors.primary,
          backgroundColor: AppColors.scaffoldBackgroundColor,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: paddingHorizontal,
            ).copyWith(top: 0, bottom: 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  text: _getFormattedDate(),
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.appBlack1,
                ),
                SizedBox(height: 10.h),
                const SummaryCards(),
                SizedBox(height: 20.h),
                Obx(() {
                  if (challanController.isLoading.value) {
                    return _buildChartShimmer();
                  }
                  return _analysisSection(challanController.challanData.value);
                }),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(Assets.logo, width: 42.w, height: 42.h),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomText(
                text: "Stay aware, stay safe.",
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.appBlack1,
              ),
              CustomText(
                text: "ذمہ دار ڈرائیونگ سے ہی محفوظ شہر ممکن ہے",
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: AppColors.appBlack1,
              ),
            ],
          ),
        ),
        Icon(Icons.notifications_none, size: 28.sp, color: AppColors.primary),
      ],
    );
  }

  Widget _analysisSection(dynamic data) {
    return ChallanAnalysisSection(
      title: "Amount Analysis",
      firstChartTitle: "Amount Comparison",
      firstChart: ChallanBarChart(data: data, showAmount: true),
      secondChartTitle: "Amount Distribution",
      secondChart: ChallanPieChart(data: data, showAmount: true),
    );
  }

  Widget _buildChartShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title shimmer
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Container(
            height: 20.h,
            width: 160.w,
            margin: EdgeInsets.symmetric(horizontal: 8.w),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ),
        SizedBox(height: 16.h),
        // First chart card shimmer
        _buildChartCardShimmer(),
        SizedBox(height: 20.h),
        // Second chart card shimmer
        _buildChartCardShimmer(),
      ],
    );
  }

  Widget _buildChartCardShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 16.h,
              width: 140.w,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              height: 280.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
