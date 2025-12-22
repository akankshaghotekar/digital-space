import 'package:digital_space/screens/dashboard/dashboard_screen.dart';
import 'package:digital_space/screens/login/login_screen.dart';
import 'package:digital_space/screens/splash/splash_screen.dart';
import 'package:digital_space/utils/app_colors.dart';
import 'package:digital_space/utils/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await ThemeController.loadTheme();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (_, __) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: ThemeController.themeMode,
          builder: (context, mode, _) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              themeMode: mode,
              theme: ThemeData(
                scaffoldBackgroundColor: AppColors.lightBg,
                brightness: Brightness.light,
              ),
              darkTheme: ThemeData(
                scaffoldBackgroundColor: AppColors.darkBg,
                brightness: Brightness.dark,
              ),
              home: SplashScreen(),
            );
          },
        );
      },
    );
  }
}
