import 'package:flutter/material.dart';

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
        return const Color(0xFF34D399); // Emerald/Green
      case ActivityStatus.warning:
        return const Color(0xFFFBBF24); // Amber/Yellow
      case ActivityStatus.info:
        return const Color(0xFF818CF8); // Indigo/Blue
    }
  }
}
