import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';
import 'settings_expandable_tile.dart';
import 'settings_sub_tile.dart';

class SecuritySettingsSection extends GetView<SettingsController> {
  const SecuritySettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SettingsExpandableTile(
      icon: Icons.security_outlined,
      iconColor: AppColors.emeraldSoft,
      title: 'Security',
      canExpand: isMobile,
      initiallyExpanded: !isMobile,
      showHeader: isMobile,
      children: [
        SettingsSubTile(
          icon: Icons.lock_outline_rounded,
          iconColor: AppColors.amberSoft,
          title: 'Change Password',
          subtitle: 'Last changed 3 months ago',
          onTap: () {},
        ),
        Obx(
          () => SettingsSubTile(
            icon: Icons.verified_user_outlined,
            iconColor: AppColors.emeraldSoft,
            title: 'Two-Factor Auth (2FA)',
            subtitle: 'SMS or Authenticator App',
            trailing: Switch.adaptive(
              value: controller.twoFactorEnabled.value,
              onChanged: (v) => controller.twoFactorEnabled.value = v,
              activeThumbColor: AppColors.primary,
            ),
          ),
        ),
        Obx(
          () => SettingsSubTile(
            icon: Icons.fingerprint_rounded,
            iconColor: AppColors.purpleSoft,
            title: 'Biometric Login',
            subtitle: 'Face ID or Fingerprint',
            trailing: Switch.adaptive(
              value: controller.biometricEnabled.value,
              onChanged: (v) => controller.biometricEnabled.value = v,
              activeThumbColor: AppColors.primary,
            ),
          ),
        ),
        Obx(
          () => SettingsSubTile(
            icon: Icons.notifications_none_rounded,
            iconColor: AppColors.blueSoft,
            title: 'Login Alerts',
            subtitle: 'Notify on new sign-ins',
            trailing: Switch.adaptive(
              value: controller.loginAlertsEnabled.value,
              onChanged: (v) => controller.loginAlertsEnabled.value = v,
              activeThumbColor: AppColors.primary,
            ),
          ),
        ),
        SettingsSubTile(
          icon: Icons.devices_rounded,
          iconColor: AppColors.indigoSoft,
          title: 'Active Sessions',
          subtitle: '2 active sessions',
          showDivider: false,
          trailing: _buildBadge('2 Active', AppColors.indigoAccent, isDark),
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
