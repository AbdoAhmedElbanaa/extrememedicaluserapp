import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import '../controllers/profile_controller.dart';

class SupportLegalSection extends GetView<ProfileController> {
  const SupportLegalSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentYear = DateTime.now().year;
    final isWide = context.screenWidth >= 600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'SUPPORT & LEGAL',
            style: TextStyle(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.cinematicSurface.withValues(alpha: 0.4) 
                : AppColors.surfaceLight.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: isDark 
                  ? AppColors.distinctBorderDark 
                  : AppColors.distinctBorderLight,
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildSupportTile(
                icon: Icons.help_outline_rounded,
                iconColor: AppColors.indigoSoft,
                title: 'Help Center',
                isDark: isDark,
                showDivider: true,
                onTap: () {},
              ),
              _buildSupportTile(
                icon: Icons.description_outlined,
                iconColor: AppColors.blueSoft,
                title: 'Privacy Policy',
                isDark: isDark,
                showDivider: true,
                onTap: () {},
              ),
              _buildSupportTile(
                icon: Icons.assignment_outlined,
                iconColor: AppColors.purpleSoft,
                title: 'Terms of Service',
                isDark: isDark,
                showDivider: true,
                onTap: () {},
              ),
              _buildSupportTile(
                icon: Icons.star_outline_rounded,
                iconColor: AppColors.amberSoft,
                title: 'Rate the App',
                isDark: isDark,
                showDivider: false,
                onTap: () {},
              ),
            ],
          ),
        ),
        if (!isWide) ...[
          const SizedBox(height: 24),
          _buildSignOutButton(isDark),
        ],
        const SizedBox(height: 24),
        Center(
          child: Obx(() => Text(
            'UserManual v${controller.appVersion.value} - © $currentYear',
            style: TextStyle(
              color: isDark ? AppColors.textMutedDark.withValues(alpha: 0.5) : AppColors.textMutedLight.withValues(alpha: 0.5),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildSupportTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(showDivider ? 0 : 28),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: iconColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.foregroundLight,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.black.withValues(alpha: 0.1),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            indent: 76,
            endIndent: 16,
            color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
          ),
      ],
    );
  }

  Widget _buildSignOutButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.errorRed.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? AppColors.distinctBorderDark : AppColors.errorRed.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.errorRedBright,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Sign Out',
                style: TextStyle(
                  color: AppColors.errorRedBright,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
