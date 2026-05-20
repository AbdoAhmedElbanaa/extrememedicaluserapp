import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/core/services/theme_service.dart';

class SettingsController extends GetxController {
  final currentThemeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    super.onInit();
    currentThemeMode.value = ThemeService().theme;
  }

  void updateThemeMode(ThemeMode mode) {
    currentThemeMode.value = mode;
    ThemeService().changeThemeMode(mode);
  }
}
