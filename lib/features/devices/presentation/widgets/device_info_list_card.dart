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
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

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
              color: isDark ? Colors.white : AppColors.indigoMuted,
              letterSpacing: -0.3,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.symmetric(vertical: 8),
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
                icon: Icons.code_rounded,
                label: 'SW Version',
                value: device.swVer ?? 'N/A',
                isDark: isDark,
                iconColor: AppColors.blueSoft,
              ),
              _buildDivider(isDark),
              _buildInfoRow(
                context,
                icon: Icons.widgets_rounded,
                label: 'UI Version',
                value: device.uiVer ?? 'N/A',
                isDark: isDark,
                iconColor: AppColors.emeraldSoft,
              ),
              _buildDivider(isDark),
              _buildInfoRow(
                context,
                icon: Icons.developer_board_rounded,
                label: 'PCB Version',
                value: device.pcbVer ?? 'N/A',
                isDark: isDark,
                iconColor: AppColors.purpleSoft,
              ),
              _buildDivider(isDark),
              _buildInfoRow(
                context,
                icon: Icons.settings_suggest_rounded,
                label: 'NTC Version',
                value: device.ntcVer ?? 'N/A',
                isDark: isDark,
                iconColor: AppColors.pinkSoft,
              ),
              _buildDivider(isDark),
              _buildInfoRow(
                context,
                icon: Icons.power_rounded,
                label: 'SSR',
                value: (device.ssr ?? 'N/A').toUpperCase(),
                isDark: isDark,
                iconColor: AppColors.amberSoft,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, {
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
              color: iconColor.withValues(alpha: 0.12),
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
              color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors
                  .black54,
            ),
          ),

          const Spacer(),

          // Value
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.9)
                  : AppColors.primary,
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
      color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black
          .withValues(alpha: 0.03),
    );
  }
}
