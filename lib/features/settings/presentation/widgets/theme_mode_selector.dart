import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';
import '../controllers/settings_controller.dart';

class ThemeModeSelector extends GetView<SettingsController> {
  const ThemeModeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'THEME MODE',
            style: TextStyle(
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isDark 
                ? AppColors.cinematicSurface.withValues(alpha: 0.4) 
                : AppColors.surfaceLight.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark 
                  ? Colors.white.withValues(alpha: 0.05) 
                  : AppColors.borderLight.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              _buildThemeOption(
                context: context,
                mode: ThemeMode.light,
                icon: Icons.light_mode_outlined,
                label: 'Light',
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildThemeOption(
                context: context,
                mode: ThemeMode.dark,
                icon: Icons.dark_mode_outlined,
                label: 'Dark',
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildThemeOption(
                context: context,
                mode: ThemeMode.system,
                icon: Icons.important_devices_rounded,
                label: 'System',
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeMode mode,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.currentThemeMode.value == mode;
        return GestureDetector(
          onTap: () => controller.updateThemeMode(mode),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected 
                  ? AppColors.primary 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ] : null,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color: isSelected 
                      ? Colors.white 
                      : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected 
                        ? Colors.white 
                        : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
