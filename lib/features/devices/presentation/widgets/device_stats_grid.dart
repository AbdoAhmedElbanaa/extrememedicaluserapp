import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../data/models/device_model.dart';

class DeviceStatsGrid extends StatelessWidget {
  final DeviceModel device;

  const DeviceStatsGrid({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1.6,
        children: [
          _buildStatCard(
            context,
            label: 'Battery',
            value: '${device.batteryLevel}%',
            icon: Icons.battery_charging_full_rounded,
            color: _getBatteryColor(device.batteryLevel),
            isDark: isDark,
          ),
          _buildStatCard(
            context,
            label: 'Signal',
            value: '${device.signalStrength}%',
            icon: Icons.sensors_rounded,
            color: AppColors.primary,
            isDark: isDark,
          ),
          _buildStatCard(
            context,
            label: 'Firmware',
            value: 'v${device.firmwareVersion}',
            icon: Icons.router_rounded,
            color: AppColors.secondary,
            isDark: isDark,
          ),
          _buildStatCard(
            context,
            label: 'Last Sync',
            value: device.lastSync,
            icon: Icons.sync_rounded,
            color: AppColors.success,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.indigoDeep.withValues(alpha: 0.3)
            : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? color.withValues(alpha: 0.1)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.5)
                      : Colors.grey[600],
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : AppColors.indigoMuted,
            ),
          ),
        ],
      ),
    );
  }

  Color _getBatteryColor(int level) {
    if (level > 60) return AppColors.success;
    if (level > 20) return AppColors.warning;
    return AppColors.destructive;
  }
}
