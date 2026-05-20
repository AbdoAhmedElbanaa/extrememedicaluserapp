import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';

class HelpSearchBar extends StatelessWidget {
  final Function(String)? onChanged;

  const HelpSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.cardDark.withValues(alpha: 0.5)
            : AppColors.inputBackgroundLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.borderDark.withValues(alpha: 0.3)
              : AppColors.borderLight.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: TextField(
        onChanged: onChanged,
        style: TextStyle(
          color: isDark ? AppColors.foregroundDark : AppColors.foregroundLight,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: 'Search help articles, error codes...',
          hintStyle: TextStyle(
            color: isDark
                ? AppColors.mutedForegroundDark.withValues(alpha: 0.6)
                : AppColors.mutedForegroundLight,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: isDark
                ? AppColors.mutedForegroundDark.withValues(alpha: 0.7)
                : AppColors.mutedForegroundLight,
            size: 22,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
              vertical: 16, horizontal: 20),
        ),
      ),
    );
  }
}
