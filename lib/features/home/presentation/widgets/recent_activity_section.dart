import 'package:extrememedicaluserapp/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/models/recent_activity_model.dart';
import '../controllers/home_controller.dart';
import 'package:extrememedicaluserapp/features/devices/presentation/widgets/add_device_sheet.dart';

class RecentActivitySection extends GetView<HomeController> {
  const RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return Column(
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'View all',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Activity List Container
        Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.cinematicSurface.withValues(alpha: 0.6)
                : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppColors.distinctBorderDark
                  : AppColors.distinctBorderLight,
              width: 1.2,
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.recentActivities.length,
            separatorBuilder: (context, index) =>
                Divider(
                  height: 1,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                  indent: 70,
                ),
            itemBuilder: (context, index) {
              final activity = controller.recentActivities[index];
              return _buildActivityItem(
                activity,
                isDark,
              );
            },
          ),
        ),
        const SizedBox(height: 25),
        // Add New Device Button
        _buildAddDeviceButton(isDark),
        const SizedBox(height: 100), // Extra space for bottom nav
      ],
    );
  }

  Widget _buildActivityItem(RecentActivityModel activity, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: activity.getStatusColor().withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(activity.icon, color: activity.getStatusColor(), size: 20),
        ),
        title: Text(
          activity.title,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              activity.subtitle,
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withValues(
                    alpha: 0.4),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '• ${activity.time}',
              style: TextStyle(
                color: (isDark ? Colors.white : Colors.black).withValues(
                    alpha: 0.3),
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1),
          size: 14,
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildAddDeviceButton(bool isDark) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1.5,
          style: BorderStyle.solid,
        ),
        color: AppColors.primary.withValues(alpha: 0.05),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Get.bottomSheet(
              const AddDeviceSheet(),
              isScrollControlled: true,
              barrierColor: Colors.black.withValues(alpha: 0.5),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_rounded, color: AppColors.primary, size: 24),
              SizedBox(width: 8),
              Text(
                'Add New Device',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
