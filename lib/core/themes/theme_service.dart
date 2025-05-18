import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const _themeKey = 'theme_mode';
  final SharedPreferences _prefs;

  ThemeService(this._prefs);

  ThemeMode get themeMode {
    final isDark = _prefs.getBool(_themeKey) ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggleTheme() async {
    final isDark = themeMode == ThemeMode.dark;
    await _prefs.setBool(_themeKey, !isDark);
    notifyListeners();
  }
}
