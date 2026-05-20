import 'package:flutter/material.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'settings_expandable_tile.dart';
import 'settings_sub_tile.dart';

class AboutSettingsSection extends StatelessWidget {
  const AboutSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SettingsExpandableTile(
      icon: Icons.info_outline_rounded,
      iconColor: AppColors.blueSoft,
      title: 'About',
      canExpand: isMobile,
      initiallyExpanded: !isMobile,
      showHeader: isMobile,
      children: [
        SettingsSubTile(
          icon: Icons.info_outline_rounded,
          iconColor: AppColors.blueSoft,
          title: 'App Version',
          subtitle: 'UserManual v2.0.0',
          trailing: _buildBadge('Latest', Colors.greenAccent, isDark),
        ),
        SettingsSubTile(
          icon: Icons.privacy_tip_outlined,
          iconColor: AppColors.purpleSoft,
          title: 'Privacy Policy',
          onTap: () {},
        ),
        SettingsSubTile(
          icon: Icons.description_outlined,
          iconColor: AppColors.indigoSoft,
          title: 'Terms of Service',
          onTap: () {},
        ),
        SettingsSubTile(
          icon: Icons.code_rounded,
          iconColor: AppColors.blueSoft,
          title: 'Open Source Licenses',
          showDivider: false,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
