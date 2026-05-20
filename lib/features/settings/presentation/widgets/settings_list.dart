import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import 'account_settings_section.dart';
import 'security_settings_section.dart';
import 'notifications_settings_section.dart';
import 'devices_sync_settings_section.dart';
import 'appearance_settings_section.dart';
import 'language_region_settings_section.dart';
import 'subscription_billing_settings_section.dart';
import 'about_settings_section.dart';
import 'reset_settings_section.dart';

class SettingsList extends GetView<SettingsController> {
  const SettingsList({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        AccountSettingsSection(),
        SecuritySettingsSection(),
        NotificationsSettingsSection(),
        DevicesSyncSettingsSection(),
        AppearanceSettingsSection(),
        LanguageRegionSettingsSection(),
        SubscriptionBillingSettingsSection(),
        AboutSettingsSection(),
        SizedBox(height: 12),
        ResetSettingsSection(),
      ],
    );
  }
}
