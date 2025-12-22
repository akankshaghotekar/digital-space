import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static const _themeKey = 'is_dark_mode';

  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.light,
  );

  /// Load saved theme on app start
  static Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_themeKey) ?? false;

    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  /// Toggle + save theme
  static Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final isDark = themeMode.value == ThemeMode.dark;
    final newMode = isDark ? ThemeMode.light : ThemeMode.dark;

    themeMode.value = newMode;
    await prefs.setBool(_themeKey, newMode == ThemeMode.dark);
  }
}
