import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../data/models/device_model.dart';

class DeviceInfoListCard extends StatelessWidget {
  final DeviceModel device;

  const DeviceInfoListCard({
    super.key,
    required this.device,
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
            'Device Information',
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
          padding: const EdgeInsets.symmetric(vertical: 8),
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
          child: Column(
            children: [
              _buildInfoRow(
                context,
                icon: Icons.inventory_2_rounded,
                label: 'Model',
                value: device.model,
                isDark: isDark,
                iconColor: AppColors.primary,
              ),
              _buildDivider(isDark),
              _buildInfoRow(
                context,
                icon: Icons.wifi_tethering_rounded,
                label: 'Serial Number',
                value: device.serialNumber,
                isDark: isDark,
                iconColor: AppColors.indigoAccent,
              ),
              _buildDivider(isDark),
              _buildInfoRow(
                context,
                icon: Icons.bolt_rounded,
                label: 'Firmware',
                value: '${device.firmwareVersion} (latest)',
                isDark: isDark,
                iconColor: AppColors.success,
              ),
              _buildDivider(isDark),
              _buildInfoRow(
                context,
                icon: Icons.security_rounded,
                label: 'Protocol',
                value: 'MQTT / TLS 1.3',
                isDark: isDark,
                iconColor: AppColors.secondary,
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
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
          // Icon Container (Squircle Style)
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 16),
          
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white.withOpacity(0.5) : Colors.black54,
            ),
          ),
          
          const Spacer(),
          
          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.primary.withOpacity(0.9) : AppColors.primary,
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
      color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03),
    );
  }
}
