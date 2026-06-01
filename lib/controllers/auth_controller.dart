

import '../utills/export.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/login_view.dart';
import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/io_client.dart';

class SplashController extends GetxController {
  var showLogo = false.obs;
  var isLoading = false.obs;
  @override
  void onInit() {
    super.onInit();
    startAnimation();
  }

void startAnimation() async {
  // show logo quickly
  await Future.delayed(const Duration(milliseconds: 300));
  showLogo.value = true;

  // removed the 2 second delay for instant load
  navigateToNextScreen();
}


  void navigateToNextScreen() {
    _goNextBasedOnAuth();
  }

  // sanrizvi 
  // admin@123

  Future<void> _goNextBasedOnAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final loggedIn = prefs.getBool('isLoggedIn') ?? false;
      if (loggedIn) {
        // user previously logged in -> go to home
        Get.offAll(() => HomeView(),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 100));
      } else {
        // not logged in -> show login
        Get.offAll(() => LoginView(),
            transition: Transition.rightToLeft,
            duration: const Duration(milliseconds: 200));
      }
    } catch (e) {
      // fallback to home on error
      Get.offAll(() => HomeView(),
          transition: Transition.circularReveal,
          duration: const Duration(milliseconds: 200));
    }
  }
}

class LoginController extends GetxController {
 var isLoading = false.obs;
  var visiblePassword = true.obs;

  void showHidePassword() {
    visiblePassword.toggle();
  }


  Future<void> doLogin({
    required String usernameInput,
    required String passwordInput,
  }) async {
    final user = usernameInput.trim();
    final pass = passwordInput.trim();

    if (user.isEmpty || pass.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter username and password",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 1,
        backgroundColor: AppColors.primary.withOpacity(0.9),
        textColor: AppColors.white,
        fontSize: 14.0.sp,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Create HttpClient with certificate bypass
      final HttpClient httpClient = HttpClient()
        ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      final IOClient ioClient = IOClient(httpClient);

      final url = Uri.parse('https://traffic.islamabadpolice.gov.pk/v1/api/auth/login');
      final body = jsonEncode({'username': user, 'password': pass});

      print('REQUEST BODY: $body');

      // Make API login call
      final response = await ioClient
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw TimeoutException('Request timeout');
            },
          );

      print('RESPONSE BODY: ${response.body}');

      if (response.statusCode == 200) {
        // Parse response
        final data = jsonDecode(response.body);

        // Extract values from response
        final String message = data['message'] ?? 'Login successful';
        final String token = data['token'] ?? '';
        final String userId = data['userId']?.toString() ?? data['user_id']?.toString() ?? '';
        final String userEmail = data['email'] ?? '';

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('username', user);
        if (token.isNotEmpty) await prefs.setString('token', token);
        if (userId.isNotEmpty) await prefs.setString('userId', userId);
        if (userEmail.isNotEmpty) await prefs.setString('email', userEmail);

        isLoading.value = false;

        // Show success toast with server message
        Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green.withOpacity(0.9),
          textColor: AppColors.white,
          fontSize: 14.0.sp,
        );

        // Navigate to home
        Get.offAll(
          () => HomeView(),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      } else {
        // Handle error response
        try {
          final data = jsonDecode(response.body);
          final String errorMessage = data['message'] ?? 'Login failed';

          isLoading.value = false;

          Fluttertoast.showToast(
            msg: errorMessage,
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red.withOpacity(0.9),
            textColor: AppColors.white,
            fontSize: 14.0.sp,
          );
        } catch (e) {
          isLoading.value = false;

          Fluttertoast.showToast(
            msg: 'Login failed: ${response.statusCode}',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red.withOpacity(0.9),
            textColor: AppColors.white,
            fontSize: 14.0.sp,
          );
        }
      }
    } catch (e) {
      isLoading.value = false;

      Fluttertoast.showToast(
        msg: 'Error: ${e.toString()}',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Colors.red.withOpacity(0.9),
        textColor: AppColors.white,
        fontSize: 14.0.sp,
      );
    }
  }
}