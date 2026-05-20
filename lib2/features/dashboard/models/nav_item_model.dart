import 'package:flutter/material.dart';

class NavItemModel {
  final String title;
  final IconData icon;
  final String? route;
  final List<NavSubItemModel>? subItems;

  NavItemModel({
    required this.title,
    required this.icon,
    this.route,
    this.subItems,
  });

  factory NavItemModel.fromJson(Map<String, dynamic> json) {
    return NavItemModel(
      title: json['title'] as String,
      icon: getIconData(json['icon'] as String? ?? 'circle'),
      route: json['route'] as String?,
      subItems: json['subItems'] != null
          ? (json['subItems'] as List)
              .map((i) => NavSubItemModel.fromJson(i as Map<String, dynamic>))
              .toList()
          : null,
    );
  }

  static IconData getIconData(String iconName) {
    switch (iconName) {
      case 'dashboard_rounded':
        return Icons.dashboard_rounded;
      case 'people_alt_rounded':
        return Icons.people_alt_rounded;
      case 'biotech_rounded':
        return Icons.biotech_rounded;
      case 'bar_chart_rounded':
        return Icons.bar_chart_rounded;
      case 'settings_suggest_rounded':
        return Icons.settings_suggest_rounded;
      case 'group_rounded':
        return Icons.group_rounded;
      case 'admin_panel_settings_rounded':
        return Icons.admin_panel_settings_rounded;
      case 'security_rounded':
        return Icons.security_rounded;
      case 'inventory_2_rounded':
        return Icons.inventory_2_rounded;
      case 'build_rounded':
        return Icons.build_rounded;
      case 'manage_accounts_rounded':
        return Icons.manage_accounts_rounded;
      case 'backup_rounded':
        return Icons.backup_rounded;
      default:
        return Icons.circle;
    }
  }
}

class NavSubItemModel {
  final String title;
  final String route;
  final IconData icon;

  NavSubItemModel({
    required this.title,
    required this.route,
    required this.icon,
  });

  factory NavSubItemModel.fromJson(Map<String, dynamic> json) {
    return NavSubItemModel(
      title: json['title'] as String,
      route: json['route'] as String,
      icon: NavItemModel.getIconData(json['icon'] as String? ?? 'circle'),
    );
  }
}
