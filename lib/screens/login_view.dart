// lib/screens/login_view.dart
import 'package:trafficlly/controllers/auth_controller.dart';
import 'package:trafficlly/utills/export.dart';
import 'package:trafficlly/widgets/custom_button.dart';
import 'package:get/get.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final LoginController _loginController = Get.put(LoginController());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(Assets.logo, width: 120.w, height: 120.h),
              SizedBox(height: 20.h),
              CustomText(
                text: 'Welcome',
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 10.h),
              CustomText(
                text: 'Please login to continue',
                fontSize: 16.sp,
                color: AppColors.grey,
              ),
              SizedBox(height: 20.h),
              CustomTextFormField(
                hint: 'Username',
                controller: _usernameController,
                inputType: TextInputType.text,
              ),
              SizedBox(height: 12.h),
              Obx(
                () => CustomTextFormField(
                  hint: 'Password',
                  controller: _passwordController,
                  inputType: TextInputType.visiblePassword,
                  isObscure: _loginController.visiblePassword.value,
                  suffix: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: _loginController.showHidePassword,
                      child: Icon(
                        _loginController.visiblePassword.value
                            ? Icons.visibility_off_sharp
                            : Icons.visibility,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),
              Obx(
                () => CustomButton(
                  title: 'Login',
                  isLoading: _loginController.isLoading.value,
                  loaderColor: AppColors.white,
                  onTap: _loginController.isLoading.value
                      ? null
                      : () {
                          _loginController.doLogin(
                            usernameInput: _usernameController.text,
                            passwordInput: _passwordController.text,
                          );
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
