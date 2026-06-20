import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/services/theme_service.dart';
import 'package:extrememedicaluserapp/features/contact/services/onesignal_service.dart';

class SettingsController extends GetxController {
  final currentThemeMode = ThemeMode.system.obs;
  final GetStorage _storage = GetStorage();

  // Selected category for tablet/desktop view
  final RxInt selectedCategoryIndex = 0.obs;

  // Security
  final twoFactorEnabled = false.obs;
  final biometricEnabled = false.obs;
  final loginAlertsEnabled = true.obs;

  // Notifications
  final pushEnabled = true.obs;
  final emailEnabled = true.obs;
  final chatAlertsEnabled = true.obs;
  final ticketAlertsEnabled = true.obs;
  final errorAlertsEnabled = true.obs;

  // OneSignal Status
  final onesignalPlayerId = ''.obs;
  final onesignalSubscribed = false.obs;

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

    // Load from local storage
    pushEnabled.value = _storage.read('push_enabled') ?? true;
    emailEnabled.value = _storage.read('email_enabled') ?? true;
    chatAlertsEnabled.value = _storage.read('chat_alerts_enabled') ?? true;
    ticketAlertsEnabled.value = _storage.read('ticket_alerts_enabled') ?? true;
    errorAlertsEnabled.value = _storage.read('error_alerts_enabled') ?? true;

    // Register observer for real-time OneSignal updates
    OneSignalService.addSubscriptionObserver((id, optedIn) {
      onesignalPlayerId.value = id ?? '';
      onesignalSubscribed.value = optedIn;
      if (optedIn) {
        pushEnabled.value = true;
        _storage.write('push_enabled', true);
      }
    });

    // Sync settings with OneSignal
    syncOneSignalSettings();
  }

  Future<void> syncOneSignalSettings() async {
    // Check if permission is granted first
    final hasPermission = await Permission.notification.isGranted;
    if (!hasPermission) {
      pushEnabled.value = false;
      _storage.write('push_enabled', false);
      await OneSignalService.setPushEnabled(false);
    } else {
      await OneSignalService.setPushEnabled(pushEnabled.value);
    }

    await OneSignalService.setNotificationTag('notify_chat', chatAlertsEnabled.value);
    await OneSignalService.setNotificationTag('notify_tickets', ticketAlertsEnabled.value);
    await OneSignalService.setNotificationTag('notify_errors', errorAlertsEnabled.value);

    // Load details
    onesignalPlayerId.value = await OneSignalService.getPlayerId() ?? '';
    onesignalSubscribed.value = await OneSignalService.isSubscribed();
  }

  void togglePushNotifications(bool val) async {
    if (val) {
      // Check if notification permission is granted
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        // Request notification permission and subscribe
        await OneSignalService.requestNotificationPermission();
        final newStatus = await Permission.notification.status;
        if (!newStatus.isGranted) {
          // If the user denied, revert toggle and show message
          pushEnabled.value = false;
          _storage.write('push_enabled', false);
          onesignalSubscribed.value = false;
          Get.snackbar(
            'Permission Denied',
            'Notifications permission is required to enable Push Notifications.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.errorRed.withValues(alpha: 0.1),
            colorText: AppColors.errorRed,
          );
          return;
        }
      }

      pushEnabled.value = true;
      _storage.write('push_enabled', true);
      await OneSignalService.setPushEnabled(true);

      // Verify subscription status after opting in
      await Future.delayed(const Duration(milliseconds: 500));
      onesignalPlayerId.value = await OneSignalService.getPlayerId() ?? '';
      onesignalSubscribed.value = await OneSignalService.isSubscribed();
    } else {
      pushEnabled.value = false;
      _storage.write('push_enabled', false);
      await OneSignalService.setPushEnabled(false);
      onesignalSubscribed.value = false;
    }
  }

  void toggleEmailNotifications(bool val) {
    emailEnabled.value = val;
    _storage.write('email_enabled', val);
  }

  void toggleChatAlerts(bool val) {
    chatAlertsEnabled.value = val;
    _storage.write('chat_alerts_enabled', val);
    OneSignalService.setNotificationTag('notify_chat', val);
  }

  void toggleTicketAlerts(bool val) {
    ticketAlertsEnabled.value = val;
    _storage.write('ticket_alerts_enabled', val);
    OneSignalService.setNotificationTag('notify_tickets', val);
  }

  void toggleErrorAlerts(bool val) {
    errorAlertsEnabled.value = val;
    _storage.write('error_alerts_enabled', val);
    OneSignalService.setNotificationTag('notify_errors', val);
  }

  void updateThemeMode(ThemeMode mode) {
    currentThemeMode.value = mode;
    ThemeService().changeThemeMode(mode);
  }

  void resetAllSettings() {
    twoFactorEnabled.value = false;
    biometricEnabled.value = false;
    loginAlertsEnabled.value = true;
    
    togglePushNotifications(true);
    toggleEmailNotifications(true);
    toggleChatAlerts(true);
    toggleTicketAlerts(true);
    toggleErrorAlerts(true);
    
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
