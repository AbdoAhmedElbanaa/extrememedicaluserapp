import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import 'action_button_card.dart';

class DeviceQuickActionsCard extends StatelessWidget {
  final VoidCallback? onRestart;
  final VoidCallback? onUpdate;
  final VoidCallback? onSettings;

  const DeviceQuickActionsCard({
    super.key,
    this.onRestart,
    this.onUpdate,
    this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
              color: isDark ? Colors.white : const Color(0xFF1E1B4B),
              letterSpacing: -0.3,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.indigoDeep.withOpacity(0.3) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
            ),
            boxShadow: [
              if (!isDark)
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: ActionButtonCard(
                  label: 'Restart',
                  icon: Icons.restart_alt_rounded,
                  color: AppColors.primary,
                  onTap: onRestart,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionButtonCard(
                  label: 'Update',
                  icon: Icons.system_update_alt_rounded,
                  color: AppColors.success,
                  onTap: onUpdate,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ActionButtonCard(
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
}
