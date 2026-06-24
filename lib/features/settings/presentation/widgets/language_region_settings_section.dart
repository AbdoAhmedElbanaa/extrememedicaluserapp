import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../controllers/settings_controller.dart';
import 'settings_expandable_tile.dart';
import 'settings_sub_tile.dart';

class LanguageRegionSettingsSection extends GetView<SettingsController> {
  const LanguageRegionSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SettingsExpandableTile(
      icon: Icons.language_rounded,
      iconColor: AppColors.blueSoft,
      title: 'Language & Region',
      canExpand: isMobile,
      initiallyExpanded: !isMobile,
      showHeader: isMobile,
      children: [
        Obx(() => SettingsSubTile(
          icon: Icons.language_rounded,
          iconColor: AppColors.blueSoft,
          title: 'Language',
          subtitle: controller.activeLanguage.value,
          onTap: () => controller.showLanguageDialog(),
        )),
        SettingsSubTile(
          icon: Icons.calendar_today_rounded,
          iconColor: AppColors.indigoSoft,
          title: 'Date Format',
          subtitle: 'DD/MM/YYYY',
          onTap: () {},
        ),
        SettingsSubTile(
          icon: Icons.thermostat_rounded,
          iconColor: AppColors.amberSoft,
          title: 'Temperature Unit',
          subtitle: 'Celsius (°C)',
          showDivider: false,
          onTap: () {},
        ),
      ],
    );
  }
}
