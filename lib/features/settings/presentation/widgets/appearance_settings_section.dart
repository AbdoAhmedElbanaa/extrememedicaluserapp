import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../controllers/settings_controller.dart';
import 'settings_expandable_tile.dart';
import 'settings_sub_tile.dart';

class AppearanceSettingsSection extends GetView<SettingsController> {
  const AppearanceSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SettingsExpandableTile(
      icon: Icons.palette_outlined,
      iconColor: AppColors.pinkSoft,
      title: 'Appearance',
      canExpand: isMobile,
      initiallyExpanded: !isMobile,
      showHeader: isMobile,
      children: [
        Obx(() => SettingsSubTile(
          icon: Icons.palette_outlined,
          iconColor: AppColors.pinkSoft,
          title: 'Dynamic Accent',
          subtitle: 'Adaptive accent color',
          trailing: Switch.adaptive(
            value: controller.dynamicAccentEnabled.value,
            onChanged: (v) => controller.dynamicAccentEnabled.value = v,
            activeTrackColor: AppColors.pinkSoft,
          ),
        )),
        Obx(() => SettingsSubTile(
          icon: Icons.auto_fix_high_rounded,
          iconColor: AppColors.indigoSoft,
          title: 'Smooth Animations',
          subtitle: 'Micro-interaction effects',
          showDivider: false,
          trailing: Switch.adaptive(
            value: controller.smoothAnimationsEnabled.value,
            onChanged: (v) => controller.smoothAnimationsEnabled.value = v,
            activeTrackColor: AppColors.indigoSoft,
          ),
        )),
      ],
    );
  }
}
