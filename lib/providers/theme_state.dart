import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeState with ChangeNotifier {
  static const String _themeKey = 'theme_mode';

  ThemeMode mode = ThemeMode.system;

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_themeKey);

    if (stored == ThemeMode.light.name) {
      mode = ThemeMode.light;
    } else if (stored == ThemeMode.dark.name) {
      mode = ThemeMode.dark;
    } else {
      mode = ThemeMode.system;
    }

    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    mode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }

  Future<void> setSystemTheme() async {
    mode = ThemeMode.system;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, mode.name);
  }
}
