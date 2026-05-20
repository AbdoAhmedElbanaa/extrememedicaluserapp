# extrememedicaluserapp

Extreme Medical User Manaual app

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

import 'dart:convert';
import '../models/nav_item_model.dart';

class SidebarConfig {
static const String _jsonRaw = r'''
[
{
"title": "Dashboard",
"icon": "dashboard_rounded",
"route": "/dashboard"
},
{
"title": "User Management",
"icon": "people_alt_rounded",
"subItems": [
{ "title": "All Users", "route": "/users", "icon": "group_rounded" },
{ "title": "Administrators", "route": "/users/admins", "icon": "admin_panel_settings_rounded" },
{ "title": "Permissions", "route": "/users/permissions", "icon": "security_rounded" }
]
},
{
"title": "Medical Devices",
"icon": "biotech_rounded",
"subItems": [
{ "title": "Inventory", "route": "/devices", "icon": "inventory_2_rounded" },
{ "title": "Maintenance", "route": "/devices/maintenance", "icon": "build_rounded" }
]
},
{
"title": "System Settings",
"icon": "settings_suggest_rounded",
"subItems": [
{ "title": "General", "route": "/settings", "icon": "manage_accounts_rounded" },
{ "title": "Security", "route": "/settings/security", "icon": "security_rounded" },
{ "title": "Backup", "route": "/settings/backup", "icon": "backup_rounded" }
]
}
]
''';

static List<NavItemModel> getMenuItems() {
final List<dynamic> decoded = jsonDecode(_jsonRaw) as List<dynamic>;
return decoded.map((item) => NavItemModel.fromJson(item as Map<String, dynamic>)).toList();
}
}
