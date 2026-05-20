import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../data/models/device_model.dart';

class DeviceCard extends StatelessWidget {
  final DeviceModel device;
  final VoidCallback onTap;

  const DeviceCard({super.key, required this.device, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // الألوان الديناميكية بناءً على الثيم
    final cardBg = theme.colorScheme.surface;
    final subTextColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final borderColor = theme.colorScheme.outline.withValues(alpha: 0.1);
    final statsBg = isDark
        ? Colors.white.withValues(alpha: 0.03)
        : Colors.black.withValues(alpha: 0.02);

    // ألوان الحالة
    final statusColor = device.status == DeviceStatus.online
        ? AppColors.success
        : AppColors.warning;

    final iconBgColor = device.status == DeviceStatus.online
        ? AppColors.primary
        : AppColors.warning;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // الشريط الجانبي (Side Indicator) بلمسة أنعم
              Positioned(
                left: 0,
                top: 16,
                bottom: 16,
                child: Container(
                  width: 3.5,
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(10),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ليأخذ الكارد طول محتواه فقط
                  children: [
                    // الصف العلوي: الأيقونة والمعلومات الأساسية
                    Row(
                      children: [
                        _buildDeviceIcon(iconBgColor, device.icon),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                device.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                device.model,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: subTextColor,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _buildStatusBadge(context, device.status, statusColor),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // صف الإحصائيات (بشكل أكثر دقة)
                    Row(
                      children: [
                        _buildStatItem(
                          context,
                          'Signal',
                          '${device.signalStrength}%',
                          AppColors.primary,
                          statsBg,
                        ),
                        const SizedBox(width: 8),
                        _buildStatItem(
                          context,
                          'Battery',
                          '${device.batteryLevel}%',
                          statusColor,
                          statsBg,
                        ),
                        const SizedBox(width: 8),
                        _buildStatItem(
                          context,
                          'Version',
                          device.firmwareVersion,
                          subTextColor,
                          statsBg,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // الصف السفلي: المزامنة والحالة التفصيلية
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.history_rounded,
                              size: 14,
                              color: subTextColor.withValues(alpha: 0.4),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              device.lastSync,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: subTextColor.withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        // إشارة مرئية لوجود تفاصيل (اختياري لكنه احترافي)
                        Row(
                          children: [
                            Text(
                              'Details',
                              style: TextStyle(
                                color: AppColors.primary.withValues(alpha: 0.7),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 10,
                              color: AppColors.primary.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceIcon(Color bgColor, IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: bgColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    DeviceStatus status,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            status == DeviceStatus.online ? 'Online' : 'Warning',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
    Color bg,
  ) {
    final subTextColor = Theme.of(
      context,
    ).colorScheme.onSurface.withValues(alpha: 0.5);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.05),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: subTextColor,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
