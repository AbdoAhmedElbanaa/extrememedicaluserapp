import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeService {
  final _box = GetStorage();
  final _key = 'themeMode';

  /// Get theme mode from storage
  ThemeMode get theme {
    String? themeStr = _box.read(_key);
    switch (themeStr) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Save theme mode to storage
  void _saveThemeToBox(String themeStr) => _box.write(_key, themeStr);

  /// Change theme mode
  void changeThemeMode(ThemeMode mode) {
    Get.changeThemeMode(mode);
    String themeStr = 'system';
    if (mode == ThemeMode.light) themeStr = 'light';
    if (mode == ThemeMode.dark) themeStr = 'dark';
    _saveThemeToBox(themeStr);
  }

  /// Legacy support for switchTheme (optional, but keep if used elsewhere)
  void switchTheme() {
    if (Get.isDarkMode) {
      changeThemeMode(ThemeMode.light);
    } else {
      changeThemeMode(ThemeMode.dark);
    }
  }
}
