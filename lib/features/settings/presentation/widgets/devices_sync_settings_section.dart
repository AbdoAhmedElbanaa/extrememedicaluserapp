import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../controllers/settings_controller.dart';
import 'settings_expandable_tile.dart';
import 'settings_sub_tile.dart';

class DevicesSyncSettingsSection extends GetView<SettingsController> {
  const DevicesSyncSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsExpandableTile(
      icon: Icons.sync_rounded,
      iconColor: AppColors.purpleSoft,
      title: 'Devices & Sync',
      children: [
        Obx(() => SettingsSubTile(
          icon: Icons.sync_rounded,
          iconColor: AppColors.indigoSoft,
          title: 'Auto Sync',
          subtitle: 'Sync every 5 minutes',
          trailing: Switch.adaptive(
            value: controller.autoSyncEnabled.value,
            onChanged: (v) => controller.autoSyncEnabled.value = v,
            activeTrackColor: AppColors.indigoSoft,
          ),
        )),
        Obx(() => SettingsSubTile(
          icon: Icons.cloud_done_outlined,
          iconColor: AppColors.emeraldSoft,
          title: 'Cloud Backup',
          subtitle: 'Daily at 2:00 AM',
          trailing: Switch.adaptive(
            value: controller.cloudBackupEnabled.value,
            onChanged: (v) => controller.cloudBackupEnabled.value = v,
            activeTrackColor: AppColors.emeraldSoft,
          ),
        )),
        SettingsSubTile(
          icon: Icons.analytics_outlined,
          iconColor: AppColors.blueSoft,
          title: 'Device Activity Log',
          subtitle: 'View all device events',
          onTap: () {},
        ),
        SettingsSubTile(
          icon: Icons.backup_outlined,
          iconColor: AppColors.amberSoft,
          title: 'Backup & Restore',
          subtitle: 'Manual backup options',
          showDivider: false,
          onTap: () {},
        ),
      ],
    );
  }
}
