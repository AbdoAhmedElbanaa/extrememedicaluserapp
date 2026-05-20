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
    final topPadding = MediaQuery.of(context).padding.top;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: topPadding + 20,
            bottom: 30,
            left: context.responsive(20, tablet: 50, desktop: 80),
            right: context.responsive(20, tablet: 50, desktop: 80),
          ),
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.backgroundDark.withValues(alpha: 0.7) 
                : AppColors.backgroundLight.withValues(alpha: 0.7),
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                width: 1,
              ),
            ),
          ),
          child: Column(
            children: [
              _buildAvatar(isDark),
              const SizedBox(height: 16),
              Obx(() => Text(
                controller.userName.value,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.foregroundLight,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              )),
              const SizedBox(height: 4),
              Obx(() => Text(
                controller.userEmail.value,
                style: TextStyle(
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              )),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildHeaderButton(
                    icon: Icons.edit_outlined,
                    label: 'Edit Profile',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  const SizedBox(width: 12),
                  _buildHeaderButton(
                    icon: Icons.settings_outlined,
                    label: 'Settings',
                    isDark: isDark,
                    onTap: () => Get.toNamed(AppRoutes.settings),
                  ),
                ],
              ),
            ],
          ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withValues(alpha: 0.05) 
              : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
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

  Widget _buildAvatar(bool isDark) {
    return Container(
      width: 100,
      height: 100,
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
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white,
          width: 3,
        ),
      ),
      child: const Center(
        child: Text(
          'AH',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32,
          ),
        ),
      ),
    );
  }
}
