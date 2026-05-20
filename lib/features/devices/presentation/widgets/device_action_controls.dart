import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';

class DeviceActionControls extends StatelessWidget {
  final VoidCallback? onRestart;
  final VoidCallback? onUpdate;
  final VoidCallback? onSettings;

  const DeviceActionControls({
    super.key,
    this.onRestart,
    this.onUpdate,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : AppColors.indigoMuted,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.indigoDeep.withValues(alpha: 0.3) : Colors
                .white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors
                  .black.withValues(alpha: 0.05),
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context,
                  label: 'Restart',
                  icon: Icons.restart_alt_rounded,
                  color: AppColors.primary,
                  onTap: onRestart,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  label: 'Update',
                  icon: Icons.system_update_alt_rounded,
                  color: AppColors.success,
                  onTap: onUpdate,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  context,
                  label: 'Settings',
                  icon: Icons.settings_suggest_rounded,
                  color: AppColors.secondary,
                  onTap: onSettings,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: color.withValues(alpha: 0.15),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white.withValues(alpha: 0.9) : AppColors
                    .indigoMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
