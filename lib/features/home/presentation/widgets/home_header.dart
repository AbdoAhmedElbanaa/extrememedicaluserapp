import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';

import 'package:extrememedicaluserapp/core/services/theme_service.dart';

class HomeHeader extends StatelessWidget {
  final bool isDark;
  const HomeHeader({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 10,
            bottom: 20,
            left: 20,
            right: 20,
          ),
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.backgroundDark.withOpacity(0.7) 
                : AppColors.backgroundLight.withOpacity(0.7),
            border: Border(
              bottom: BorderSide(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // User Info Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Good Morning',
                            style: TextStyle(
                              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Text('👋', style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ahmed Hassan',
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.foregroundLight,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),

                  // Action Buttons
                  Row(
                    children: [
                      _buildIconButton(
                        icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        isDark: isDark,
                        onTap: () {
                          ThemeService().switchTheme();
                        },
                      ),
                      const SizedBox(width: 12),
                      _buildIconButton(
                        icon: Icons.notifications_none_rounded,
                        isDark: isDark,
                        hasBadge: true,
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _buildUserAvatar(),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSearchBar(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1C44).withOpacity(0.5) : AppColors.mutedLight.withOpacity(0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? const Color(0xFF323066) : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              icon,
              color: isDark ? Colors.white70 : Colors.black87,
              size: 22,
            ),
            if (hasBadge)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E1C44) : Colors.white,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'AH',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cinematicSurface.withOpacity(0.5) : AppColors.inputBackgroundLight,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.primary.withOpacity(0.15) : AppColors.borderLight.withOpacity(0.5),
        ),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: TextField(
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          hintText: 'Search devices, manuals...',
          hintStyle: TextStyle(
            color: isDark ? AppColors.textMutedDark.withOpacity(0.5) : AppColors.textMutedLight.withOpacity(0.5),
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.primary.withOpacity(0.7),
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
