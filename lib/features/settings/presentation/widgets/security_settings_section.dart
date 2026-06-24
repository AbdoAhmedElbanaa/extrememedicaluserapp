import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';

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
          onTap: () => Get.toNamed(AppRoutes.changePassword),
        ),
        Obx(
          () => SettingsSubTile(
            icon: Icons.verified_user_outlined,
            iconColor: AppColors.emeraldSoft,
            title: 'Two-Factor Auth (2FA)',
            subtitle: 'SMS or Authenticator App',
            showDivider: false,
            trailing: Switch.adaptive(
              value: controller.twoFactorEnabled.value,
              onChanged: (v) => controller.toggleTwoFactor(v),
              activeThumbColor: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
