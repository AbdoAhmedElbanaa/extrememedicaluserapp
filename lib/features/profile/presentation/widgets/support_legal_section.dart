import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../controllers/profile_controller.dart';

class SupportLegalSection extends GetView<ProfileController> {
  const SupportLegalSection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentYear = DateTime.now().year;

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
                  ? Colors.white.withValues(alpha: 0.05) 
                  : AppColors.borderLight.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _buildSupportTile(
                icon: Icons.help_outline_rounded,
                iconColor: const Color(0xFF818CF8),
                title: 'Help Center',
                isDark: isDark,
                showDivider: true,
                onTap: () {},
              ),
              _buildSupportTile(
                icon: Icons.description_outlined,
                iconColor: const Color(0xFF60A5FA),
                title: 'Privacy Policy',
                isDark: isDark,
                showDivider: true,
                onTap: () {},
              ),
              _buildSupportTile(
                icon: Icons.assignment_outlined,
                iconColor: const Color(0xFFA78BFA),
                title: 'Terms of Service',
                isDark: isDark,
                showDivider: true,
                onTap: () {},
              ),
              _buildSupportTile(
                icon: Icons.star_outline_rounded,
                iconColor: const Color(0xFFFBBF24),
                title: 'Rate the App',
                isDark: isDark,
                showDivider: false,
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildSignOutButton(isDark),
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
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
          ),
      ],
    );
  }

  Widget _buildSignOutButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFDC2626).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFFDC2626).withValues(alpha: 0.1),
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
                  color: const Color(0xFFDC2626).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFEF4444),
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Sign Out',
                style: TextStyle(
                  color: Color(0xFFEF4444),
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
