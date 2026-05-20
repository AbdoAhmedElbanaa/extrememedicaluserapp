import 'package:flutter/material.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';

class SecuritySection extends StatelessWidget {
  const SecuritySection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'SECURITY',
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
          child: _buildSecurityTile(
            icon: Icons.lock_outline_rounded,
            iconColor: const Color(0xFFFBBF24), // Orange/Gold color for security
            title: 'Change Password',
            isDark: isDark,
            onTap: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    );
  }
}
