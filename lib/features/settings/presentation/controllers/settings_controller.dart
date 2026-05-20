import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/services/theme_service.dart';

class SettingsController extends GetxController {
  final currentThemeMode = ThemeMode.system.obs;

  // Security
  final twoFactorEnabled = false.obs;
  final biometricEnabled = false.obs;
  final loginAlertsEnabled = true.obs;

  // Notifications
  final pushEnabled = true.obs;
  final emailEnabled = true.obs;
  final errorAlertsEnabled = true.obs;

  // Devices & Sync
  final autoSyncEnabled = true.obs;
  final cloudBackupEnabled = true.obs;

  // Appearance
  final dynamicAccentEnabled = false.obs;
  final smoothAnimationsEnabled = true.obs;

  @override
  void onInit() {
    super.onInit();
    currentThemeMode.value = ThemeService().theme;
  }

  void updateThemeMode(ThemeMode mode) {
    currentThemeMode.value = mode;
    ThemeService().changeThemeMode(mode);
  }

  void resetAllSettings() {
    // Logic to reset all observables to default
    twoFactorEnabled.value = false;
    biometricEnabled.value = false;
    loginAlertsEnabled.value = true;
    pushEnabled.value = true;
    emailEnabled.value = true;
    errorAlertsEnabled.value = true;
    autoSyncEnabled.value = true;
    cloudBackupEnabled.value = true;
    dynamicAccentEnabled.value = false;
    smoothAnimationsEnabled.value = true;
    updateThemeMode(ThemeMode.system);

    Get.snackbar(
      'Settings Reset',
      'All preferences have been restored to default.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      colorText: AppColors.primary,
    );
  }
}
