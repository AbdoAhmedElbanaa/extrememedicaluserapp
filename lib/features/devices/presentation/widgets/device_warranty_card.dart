import 'package:flutter/material.dart';

import '../../../../theme/app_colors.dart';
import '../../data/models/device_model.dart';

class DeviceWarrantyCard extends StatelessWidget {
  final DeviceModel device;

  const DeviceWarrantyCard({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Text(
            'Warranty Status',
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
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.indigoDeep.withValues(alpha: 0.3)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
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
          child: Column(
            children: [
              _buildInfoRow(
                context,
                icon: Icons.calendar_today_rounded,
                label: 'Installing Date',
                value: device.installingDate ?? 'N/A',
                isDark: isDark,
                iconColor: AppColors.primary,
              ),
              _buildDivider(isDark),
              _buildInfoRow(
                context,
                icon: Icons.verified_user_rounded,
                label: 'Warranty End Date',
                value: device.endWarranty ?? 'N/A',
                isDark: isDark,
                iconColor: AppColors.success,
              ),
              _buildDivider(isDark),
              _buildInfoRow(
                context,
                icon: Icons.timer_rounded,
                label: 'Remaining Time',
                value: _getRemainingWarranty(device.endWarranty),
                isDark: isDark,
                iconColor: AppColors.blueSoft,
              ),
              _buildDivider(isDark),
              _buildInfoRow(
                context,
                icon: Icons.security_rounded,
                label: 'Service Plan',
                value: 'Premium (Included)',
                isDark: isDark,
                iconColor: AppColors.warning,
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getRemainingWarranty(String? endWarrantyStr) {
    if (endWarrantyStr == null || endWarrantyStr.isEmpty) return 'N/A';
    final endDate = DateTime.tryParse(endWarrantyStr);
    if (endDate == null) return 'N/A';
    
    final now = DateTime.now();
    final difference = endDate.difference(now);
    
    if (difference.isNegative) {
      return 'Expired';
    }
    
    final days = difference.inDays;
    if (days > 30) {
      final months = (days / 30).floor();
      final remainingDays = days % 30;
      if (remainingDays > 0) {
        return '$months m, $remainingDays d';
      }
      return '$months months';
    } else {
      return '$days days';
    }
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required Color iconColor,
    bool showDivider = true,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 18, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.5)
                    : Colors.black54,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? AppColors.indigoSoft
                    : AppColors.primary, // لون أزرق فاتح/مضيء للقيم
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      indent: 65,
      endIndent: 20,
      color: isDark
          ? Colors.white.withValues(alpha: 0.04)
          : Colors.black.withValues(alpha: 0.03),
    );
  }
}
