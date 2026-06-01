import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/io_client.dart';
import 'package:trafficlly/models/challans_model.dart';
import 'package:intl/intl.dart';

class ChallanController extends GetxController {
  Rx<ChallanModel> challanData = ChallanModel(
    eTicket: 0,
    fineAmount: 0.0,
    paidAmount: 0.0,
    unpaidAmount: 0.0,
    paidTickets: 0,
    unpaidTickets: 0,
  ).obs;

  RxBool isLoading = false.obs;
  RxString selectedFilter = 'daily'.obs;
  RxBool isInitialLoad = true.obs;

  final NumberFormat _amountFormat = NumberFormat('#,##0', 'en_US');

  @override
  void onInit() {
    super.onInit();
    selectedFilter.value = 'daily';
    fetchChallanDataWithDelay();
  }

  Future<void> fetchChallanDataWithDelay() async {
    isLoading.value = true;
    await _fetchApiData();
    isLoading.value = false;
    isInitialLoad.value = false;
  }

  Future<void> fetchChallanDataOnFilter() async {
    isLoading.value = true;
    await _fetchApiData();
    isLoading.value = false;
  }

  Future<void> _fetchApiData() async {
    final url = Uri.parse(
      'https://traffic.islamabadpolice.gov.pk/v1/api/challan-summary',
    );

    try {
      final HttpClient httpClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      final IOClient ioClient = IOClient(httpClient);

      final response = await ioClient
          .get(url)
          .timeout(
            const Duration(seconds: 8),
            onTimeout: () => throw TimeoutException('API timed out'),
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        challanData.value = ChallanModel.fromJson(
          jsonResponse,
          selectedFilter.value,
        );
      }
    } catch (_) {}
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    fetchChallanDataOnFilter();
  }

  String formatAmount(double amount) => _amountFormat.format(amount);

  double get paidPercentage => challanData.value.eTicket > 0
      ? (challanData.value.paidTickets / challanData.value.eTicket) * 100
      : 0;

  double get unpaidPercentage => challanData.value.eTicket > 0
      ? (challanData.value.unpaidTickets / challanData.value.eTicket) * 100
      : 0;
}
