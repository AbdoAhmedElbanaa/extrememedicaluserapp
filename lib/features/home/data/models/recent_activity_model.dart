import 'package:flutter/material.dart';
import 'package:extrememedicaluserapp/theme/app_colors.dart';

enum ActivityStatus { success, warning, info }

class RecentActivityModel {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final ActivityStatus status;
  final VoidCallback? onTap;

  RecentActivityModel({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.status,
    this.onTap,
  });

  Color getStatusColor() {
    switch (status) {
      case ActivityStatus.success:
        return AppColors.emeraldSoft; // Emerald/Green
      case ActivityStatus.warning:
        return AppColors.amberSoft; // Amber/Yellow
      case ActivityStatus.info:
        return AppColors.indigoSoft; // Indigo/Blue
    }
  }
}
