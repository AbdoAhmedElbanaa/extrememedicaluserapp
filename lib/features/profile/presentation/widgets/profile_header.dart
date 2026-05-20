import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:extrememedicaluserapp/core/utils/responsive_layout.dart';
import 'package:extrememedicaluserapp/core/routes/app_routes.dart';
import '../controllers/profile_controller.dart';

class ProfileHeader extends GetView<ProfileController> {
  const ProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWide = context.screenWidth >= 600;
    final topPadding = isWide ? 40.0 : MediaQuery.of(context).padding.top + 20;

    return Container(
      width: double.infinity,
      height: isWide ? double.infinity : null,
      padding: EdgeInsets.only(
        top: topPadding,
        bottom: isWide ? 40 : 30,
        left: isWide ? 20 : context.responsive(20, tablet: 50, desktop: 80),
        right: isWide ? 20 : context.responsive(20, tablet: 50, desktop: 80),
      ),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.backgroundDark.withValues(alpha: isWide ? 1.0 : 0.7) 
            : AppColors.backgroundLight.withValues(alpha: isWide ? 1.0 : 0.7),
        border: Border(
          bottom: BorderSide(
            color: (isWide && !isDark) ? Colors.transparent : (isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight),
            width: isWide ? 0 : 1,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: isWide ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          _buildAvatar(isDark, isWide),
          const SizedBox(height: 16),
          Obx(() => Text(
            controller.userName.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? Colors.white : AppColors.foregroundLight,
              fontSize: isWide ? 28 : 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          )),
          const SizedBox(height: 4),
          Obx(() => Text(
            controller.userEmail.value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          )),
          const SizedBox(height: 24),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildHeaderButton(
                icon: Icons.edit_outlined,
                label: 'Edit Profile',
                isDark: isDark,
                onTap: () {},
              ),
              _buildHeaderButton(
                icon: Icons.settings_outlined,
                label: 'Settings',
                isDark: isDark,
                onTap: () => Get.toNamed(AppRoutes.settings),
              ),
            ],
          ),
          if (isWide) ...[
            const Spacer(),
            _buildLogoutButton(isDark),
          ]
        ],
      ),
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return ListTile(
      onTap: () {},
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: const Icon(Icons.logout_rounded, color: AppColors.errorRed),
      title: const Text(
        'Logout',
        style: TextStyle(
          color: AppColors.errorRed,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeaderButton({
    required IconData icon,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.05) 
              : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.distinctBorderDark : AppColors.distinctBorderLight,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isDark ? Colors.white70 : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors.primary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(bool isDark, bool isWide) {
    final size = isWide ? 120.0 : 100.0;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark ? AppColors.distinctBorderDark : Colors.white,
          width: 3,
        ),
      ),
      child: Center(
        child: Text(
          'AH',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isWide ? 40 : 32,
          ),
        ),
      ),
    );
  }
}
