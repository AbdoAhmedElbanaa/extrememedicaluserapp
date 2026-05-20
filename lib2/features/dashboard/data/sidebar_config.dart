import 'dart:convert';

import '../models/nav_item_model.dart';

class SidebarConfig {
  static const String _jsonRaw = r'''
  [
    {
      "title": "Dashboard",
      "icon": "dashboard_rounded",
      "route": "/dashboard"
    }
  ]
  ''';

  static List<NavItemModel> getMenuItems() {
    final List<dynamic> decoded = jsonDecode(_jsonRaw) as List<dynamic>;
    return decoded
        .map((item) => NavItemModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
