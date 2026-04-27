import 'package:flutter/material.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';

class ActiveDeviceCard extends StatelessWidget {
  const ActiveDeviceCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), // Compact padding
      decoration: BoxDecoration(
        color: isDark 
            ? const Color(0xFF0D0C21) 
            : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark 
              ? Colors.white.withOpacity(0.08) 
              : Colors.black.withOpacity(0.05),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, 
        children: [
          // Header: Icon + Info + Online Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Device Icon
              Container(
                width: 48, 
                height: 48, 
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2A2859) : AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isDark ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ] : [],
                ),
                child: Icon(
                  Icons.memory_rounded,
                  color: isDark ? Colors.white : AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              // Name and Model
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SmartThermo Pro',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? Colors.white : AppColors.foregroundLight,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Model: ST-2024-X',
                      style: TextStyle(
                        color: (isDark ? Colors.white : Colors.black).withOpacity(0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Online Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Online',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12), 
          // Stats Row
          Row(
            children: [
              _buildStatBox(
                context: context,
                icon: Icons.wifi_rounded,
                value: '92%',
                label: 'Signal',
                iconColor: Colors.blueAccent,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildStatBox(
                context: context,
                icon: Icons.battery_charging_full_rounded,
                value: '78%',
                label: 'Battery',
                iconColor: Colors.greenAccent,
                isDark: isDark,
              ),
              const SizedBox(width: 8),
              _buildStatBox(
                context: context,
                icon: Icons.auto_graph_rounded,
                value: '99.8%',
                label: 'Uptime',
                iconColor: Colors.blue,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 12), 
          // Serial Number Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Serial Number',
                  style: TextStyle(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'SN-2024-001234',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.black87,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required bool isDark,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: (isDark ? Colors.white : Colors.black).withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.05),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor.withOpacity(0.7), size: 14),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.foregroundLight,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withOpacity(0.3),
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
