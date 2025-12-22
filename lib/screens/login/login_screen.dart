import 'package:digital_space/api/api_service.dart';
import 'package:digital_space/screens/dashboard/dashboard_screen.dart';
import 'package:digital_space/sharedpref/shared_pref_helper.dart';
import 'package:digital_space/utils/app_colors.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool _obscurePassword = true;

  bool isLoading = false;
  String? error;

  Future<void> _login() async {
    FocusScope.of(context).unfocus();
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty || password.isEmpty) {
      setState(() => error = "Enter username & password");
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
    });

    final response = await ApiService.login(
      username: username,
      password: password,
    );

    setState(() => isLoading = false);

    if (response['status'] == 0) {
      final user = response['data'][0];

      await SharedPrefHelper.saveLoginData(
        name: user['name'],
        userSrNo: user['usersrno'],
        employeeSrNo: user['employeesrno'],
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => DashboardScreen()),
      );
    } else {
      setState(() => error = response['message'] ?? "Login failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: 24.w,
              right: 24.w,
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),

                Image.asset(
                  "assets/images/Digital-Space-Logo1.jpg",
                  fit: BoxFit.contain,
                ),

                SizedBox(height: 40.h),

                _field(usernameController, "Username"),
                SizedBox(height: 16.h),
                _field(passwordController, "Password", isPassword: true),

                if (error != null) ...[
                  SizedBox(height: 12.h),
                  Text(
                    error!,
                    style: TextStyle(color: Colors.red, fontSize: 13.sp),
                  ),
                ],

                SizedBox(height: 24.h),

                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: isLoading ? null : _login,
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            "LOGIN",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool isPassword = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      cursorColor: AppColors.primaryBlue,
      style: TextStyle(
        fontSize: 15.sp,
        color: Colors.black,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
        floatingLabelStyle: TextStyle(
          color: AppColors.primaryBlue,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: AppColors.lightBg,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),

        /// Eye icon
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              )
            : null,

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.primaryBlue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(
            color: AppColors.primaryBlue,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}
