import 'package:flutter/material.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'settings_expandable_tile.dart';
import 'settings_sub_tile.dart';

class LanguageRegionSettingsSection extends StatelessWidget {
  const LanguageRegionSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsExpandableTile(
      icon: Icons.language_rounded,
      iconColor: AppColors.blueSoft,
      title: 'Language & Region',
      children: [
        SettingsSubTile(
          icon: Icons.language_rounded,
          iconColor: AppColors.blueSoft,
          title: 'Language',
          subtitle: 'English (US)',
          onTap: () {},
        ),
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
