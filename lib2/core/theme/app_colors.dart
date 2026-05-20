import 'package:flutter/material.dart';

class AppColors {
  // Synchronized from main app (lib/theme/app_colors.dart)
  static const Color primary = Color(0xFF6366F1); // Indigo
  static const Color secondary = Color(0xFFA855F7); // Purple
  static const Color destructive = Color(0xFFD4183D);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  
  // Dark Theme for Admin Dashboard
  static const Color background = Color(0xFF04030D);
  static const Color surface = Color(0xFF0D0C21); // surfaceDark from lib
  static const Color card = Color(0xFF1A1A1A); // cardDark from lib
  
  static const Color textPrimary = Color(0xFFFAFAFA);
  static const Color textSecondary = Color(0xFFB4B4DC); // mutedForegroundDark from lib
  
  static const Color sidebarBackground = Color(0xFF0D0C21);
  static const Color sidebarSelected = Color(0xFF1A1640); // indigoDeep from lib
  
  // Gradients inspired by the brand
  static const List<Color> primaryGradient = [
    Color(0xFF6366F1),
    Color(0xFFA855F7),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFF04030D),
    Color(0xFF1A1640),
  ];

  static const Color glassBackground = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
}
