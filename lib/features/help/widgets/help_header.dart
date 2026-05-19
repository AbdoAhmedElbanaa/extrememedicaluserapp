import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';

class HelpHeader extends StatelessWidget {
  const HelpHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Support Center Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primary.withOpacity(0.15)
                : AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.language_rounded,
                size: 14,
                color: isDark ? AppColors.indigoAccent : AppColors.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Support Center',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.indigoAccent : AppColors.primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Main Title
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.2,
              letterSpacing: -0.5,
            ),
            children: [
              TextSpan(
                text: 'How can we ',
                style: TextStyle(
                  color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
                ),
              ),
              TextSpan(
                text: 'help you?',
                style: const TextStyle(
                  color: AppColors.primary, // Using primary for the indigo/purple color
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Subtitle
        Text(
          'Browse resources or search below',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDark
                ? AppColors.mutedForegroundDark
                : AppColors.mutedForegroundLight,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
