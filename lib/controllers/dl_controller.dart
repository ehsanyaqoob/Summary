import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/io_client.dart';
import 'package:trafficlly/models/dl_model.dart';
import 'package:trafficlly/utills/export.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class DrivingLicenceController extends GetxController {
  Rx<DrivingLicenceModel> licenceData = DrivingLicenceModel(
    todayRecords: 0,
    totalPaidToday: 0.0,
    totalUnpaidToday: 0.0,
    totalAmountOfToday: 0,
    todayPaidTicket: 0,
    todayUnPaidTicket: 0,
    weeklyTotalRecord: 0,
    paidThisWeek: 0.0,
    unpaidThisWeek: 0.0,
    totalAmountOfToWeek: 0,
    weekPaidTicket: 0,
    weekUnPaidTicket: 0,
    monthlyTotalRecord: 0,
    paidThisMonth: 0.0,
    unpaidThisMonth: 0.0,
    totalAmountOfToMonth: 0,
    monthPaidTicket: 0,
    monthUnPaidTicket: 0,
    yearlyTotalRecord: 0,
    paidThisYear: 0.0,
    unpaidThisYear: 0.0,
    totalAmountOfToYear: 0,
    yearPaidTicket: 0,
    yearUnPaidTicket: 0,
    approveLearner: 0,
    inprocessLearner: 0,
    pendingLearner: 0,
    rejectedLearner: 0,
    maleLearner: 0,
    femaleLearner: 0,
  ).obs;

  RxBool isLoading = false.obs;
  RxString selectedFilter = 'daily'.obs;
  RxBool isInitialLoad = true.obs;
  final NumberFormat _amountFormat = NumberFormat('#,##0', 'en_US');

  @override
  void onInit() {
    super.onInit();
    selectedFilter.value = 'daily';
    fetchLicenceDataWithDelay();
  }

  Future<void> fetchLicenceDataWithDelay() async {
    isLoading.value = true;
    isInitialLoad.value = true;
    await _fetchApiData();
    isLoading.value = false;
    isInitialLoad.value = false;
  }

  Future<void> fetchLicenceDataOnFilter() async {
    isLoading.value = true;
    await _fetchApiData();
    isLoading.value = false;
  }

  Future<void> _fetchApiData() async {
    final url = Uri.parse(
      'https://dlims.islamabadpolice.gov.pk/api/dlims-statistic',
    );
    try {
      final HttpClient httpClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      final IOClient ioClient = IOClient(httpClient);
      final response = await ioClient
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('API timed out'),
          );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('📥 Driving Licence API Response: $jsonResponse'); // <--- added

        licenceData.value = DrivingLicenceModel.fromJson(
          jsonResponse,
          selectedFilter.value,
        );
      }
    } catch (_) {}
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter.toLowerCase();
    fetchLicenceDataOnFilter();
  }

  String formatAmount(double amount) => _amountFormat.format(amount);
}

class TotalDlAmountController extends GetxController {
  RxDouble totalAmount = 0.0.obs;
  RxBool isLoading = false.obs;
  RxString selectedFilter = 'daily'.obs;
  RxList<Map<String, dynamic>> transactions = <Map<String, dynamic>>[].obs;
  final NumberFormat _amountFormat = NumberFormat('#,##0', 'en_US');

  @override
  void onInit() {
    super.onInit();
    fetchLatestAmount();
  }

  Future<void> fetchLatestAmount() async {
    isLoading.value = true;
    try {
      await _fetchApiData();
    } catch (_) {}
    isLoading.value = false;
  }

  Future<void> _fetchApiData() async {
    final url = Uri.parse(
      'https://dlims.islamabadpolice.gov.pk/api/dlims-statistic',
    );
    try {
      final HttpClient httpClient = HttpClient()
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
      final IOClient ioClient = IOClient(httpClient);
      final response = await ioClient
          .get(url)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('API timed out'),
          );
      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('📥 Total Amount API Response: $jsonResponse'); // <--- added

        _processApiData(jsonResponse);
      }
    } catch (_) {}
  }

  void _processApiData(Map<String, dynamic> jsonData) {
    switch (selectedFilter.value.toLowerCase()) {
      case 'daily':
        totalAmount.value =
            double.tryParse(
              jsonData['totalAmountOfToday']?.toString() ?? '0.0',
            ) ??
            0.0;
        break;
      case 'weekly':
        totalAmount.value =
            double.tryParse(
              jsonData['totalAmountOfToWeek']?.toString() ?? '0.0',
            ) ??
            0.0;
        break;
      case 'monthly':
        totalAmount.value =
            double.tryParse(
              jsonData['totalAmountOfToMonth']?.toString() ?? '0.0',
            ) ??
            0.0;
        break;
      case 'yearly':
        totalAmount.value =
            double.tryParse(
              jsonData['totalAmountOfToYear']?.toString() ?? '0.0',
            ) ??
            0.0;
        break;
      default:
        totalAmount.value =
            double.tryParse(
              jsonData['totalAmountOfToday']?.toString() ?? '0.0',
            ) ??
            0.0;
    }
    _generateTransactions(jsonData);
  }

  void _generateTransactions(Map<String, dynamic> jsonData) {
    List<Map<String, dynamic>> newTransactions = [];
    int paidToday =
        int.tryParse(jsonData['todayPaidTicket']?.toString() ?? '0') ?? 0;
    double amountToday =
        double.tryParse(jsonData['totalPaidToday']?.toString() ?? '0.0') ?? 0.0;

    if (paidToday > 0 && amountToday > 0) {
      double avgAmount = amountToday / paidToday;
      for (int i = 0; i < 3; i++) {
        newTransactions.add({
          "date": _getRecentDate(i),
          "amount": _amountFormat.format(avgAmount * (0.8 + 0.4 * (i / 3))),
          "type": _getRandomTransactionType(i),
          "status": "Completed",
        });
      }
    } else {
      newTransactions = [
        {
          "date": "2024-06-02",
          "amount": "8,000",
          "type": "License Renewal",
          "status": "Completed",
        },
        {
          "date": "2024-06-08",
          "amount": "5,000",
          "type": "New License",
          "status": "Completed",
        },
        {
          "date": "2024-06-12",
          "amount": "6,000",
          "type": "Fine Payment",
          "status": "Completed",
        },
      ];
    }

    transactions.assignAll(newTransactions);
  }

  String _getRecentDate(int daysAgo) {
    final now = DateTime.now();
    final date = now.subtract(Duration(days: daysAgo * 2));
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  String _getRandomTransactionType(int index) {
    List<String> types = [
      "License Renewal",
      "New License",
      "Fine Payment",
      "Duplicate License",
      "License Upgrade",
    ];
    return types[index % types.length];
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter.toLowerCase();
    fetchLatestAmount();
  }

  double getProgressValue() {
    if (totalAmount.value == 0) return 0.0;
    double maxAmount = 100000.0;
    double progress = totalAmount.value / maxAmount;
    return progress > 1.0 ? 1.0 : progress;
  }

  String formatAmount(double amount) => _amountFormat.format(amount);
}
