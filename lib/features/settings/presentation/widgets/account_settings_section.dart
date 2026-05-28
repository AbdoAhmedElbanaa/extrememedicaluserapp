import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/features/auth/services/auth_service.dart';
import 'settings_expandable_tile.dart';
import 'settings_sub_tile.dart';

class AccountSettingsSection extends StatelessWidget {
  const AccountSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MediaQuery.of(context).size.width < 600;
    final authService = Get.find<AuthService>();

    return Obx(() {
      final user = authService.currentUserModel.value;
      final fullName = user != null ? '${user.firstName} ${user.lastName}' : 'User';
      final email = user?.email ?? authService.currentUser?.email ?? 'N/A';
      final phone = user?.phoneNumber ?? authService.currentUser?.phoneNumber ?? 'N/A';

      return SettingsExpandableTile(
        icon: Icons.person_outline_rounded,
        iconColor: AppColors.indigoSoft,
        title: 'Account',
        canExpand: isMobile,
        initiallyExpanded: !isMobile,
        showHeader: isMobile,
        children: [
          SettingsSubTile(
            icon: Icons.person_outline_rounded,
            iconColor: AppColors.indigoSoft,
            title: 'Edit Profile',
            subtitle: fullName,
            onTap: () {},
          ),
          SettingsSubTile(
            icon: Icons.email_outlined,
            iconColor: AppColors.blueSoft,
            title: 'Change Email',
            subtitle: email,
            onTap: () {},
          ),
          SettingsSubTile(
            icon: Icons.phone_outlined,
            iconColor: AppColors.emeraldSoft,
            title: 'Change Phone',
            subtitle: phone,
            onTap: () {},
          ),
          SettingsSubTile(
            icon: Icons.delete_outline_rounded,
            iconColor: AppColors.errorRed,
            title: 'Delete Account',
            subtitle: 'Permanently remove your data',
            showDivider: false,
            trailing: _buildBadge('Danger', AppColors.errorRed, isDark),
            onTap: () {},
          ),
        ],
      );
    });
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
