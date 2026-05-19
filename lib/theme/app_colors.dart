import 'package:flutter/material.dart';

class AppColors {
  // Common Colors (Used in both themes for Splash/Branding)
  static const Color primary = Color(0xFF6366F1);
  static const Color secondary = Color(0xFFA855F7);
  static const Color destructive = Color(0xFFD4183D);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  
  // Light Theme Colors
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color foregroundLight = Color(0xFF030213);
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color mutedLight = Color(0xFFECECF0);
  static const Color mutedForegroundLight = Color(0xFF717182);
  static const Color accentLight = Color(0xFFE9EBEF);
  static const Color borderLight = Color(0x1A000000); 
  static const Color inputBackgroundLight = Color(0xFFF3F3F5);

  // Dark Theme Colors
  static const Color backgroundDark = Color(0xFF04030D);
  static const Color foregroundDark = Color(0xFFFAFAFA);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color primaryDark = Color(0xFFFAFAFA);
  static const Color mutedDark = Color(0xFF2B2B2B);
  static const Color mutedForegroundDark = Color(0xFFB4B4DC);
  static const Color accentDark = Color(0xFF2B2B2B);
  static const Color borderDark = Color(0xFF2B2B2B);

  // Cinematic / Permission Colors
  static const Color cinematicSurface = Color(0xFF161531);
  static const Color surfaceDark = Color(0xFF0D0C21);
  static const Color surfaceLight = Color(0xFFF1F5F9);
  static const Color indigoDeep = Color(0xFF1A1640);
  static const Color indigoAccent = Color(0xFF7C7EF1);
  static const Color textMutedDark = Color(0xFF8E8EA9);
  static const Color textMutedLight = Color(0xFF64748B);

  // Splash Specific (Gradients & Subtitles)
  static const List<Color> splashGradientDark = [
    Color(0xFF04030D),
    Color(0xFF0D0B26),
    Color(0xFF04030D),
  ];

  static const List<Color> splashGradientLight = [
    Color(0xFFF8F9FA),
    Color(0xFFE0E7FF),
    Color(0xFFF8F9FA),
  ];
  
  static const Color splashSubtitleDark = Color(0xFFB4B4DC);
  static const Color splashSubtitleLight = Color(0xFF4B5563);
}
