import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../controllers/settings_controller.dart';
import 'settings_expandable_tile.dart';
import 'settings_sub_tile.dart';

class NotificationsSettingsSection extends GetView<SettingsController> {
  const NotificationsSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsExpandableTile(
      icon: Icons.notifications_none_rounded,
      iconColor: AppColors.amberSoft,
      title: 'Notifications',
      children: [
        Obx(() => SettingsSubTile(
          icon: Icons.notifications_none_rounded,
          iconColor: AppColors.amberSoft,
          title: 'Push Notifications',
          subtitle: 'Alerts on your device',
          trailing: Switch.adaptive(
            value: controller.pushEnabled.value,
            onChanged: (v) => controller.pushEnabled.value = v,
            activeTrackColor: AppColors.amberSoft,
          ),
        )),
        Obx(() => SettingsSubTile(
          icon: Icons.mail_outline_rounded,
          iconColor: AppColors.blueSoft,
          title: 'Email Notifications',
          subtitle: 'Summary emails',
          trailing: Switch.adaptive(
            value: controller.emailEnabled.value,
            onChanged: (v) => controller.emailEnabled.value = v,
            activeTrackColor: AppColors.blueSoft,
          ),
        )),
        Obx(() => SettingsSubTile(
          icon: Icons.bolt_rounded,
          iconColor: AppColors.errorRed,
          title: 'Error Alerts',
          subtitle: 'Critical device errors',
          trailing: Switch.adaptive(
            value: controller.errorAlertsEnabled.value,
            onChanged: (v) => controller.errorAlertsEnabled.value = v,
            activeTrackColor: AppColors.errorRed,
          ),
        )),
        SettingsSubTile(
          icon: Icons.schedule_rounded,
          iconColor: AppColors.purpleSoft,
          title: 'Notification Schedule',
          subtitle: 'Quiet hours & timing',
          showDivider: false,
          onTap: () {},
        ),
      ],
    );
  }
}
