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

  // Distinct Borders for Widgets
  static const Color distinctBorderDark = Color(0x4DFFFFFF); // 30% White
  static const Color distinctBorderLight = Color(0x266366F1); // 15% Indigo Primary

  // Additional UI Colors from project
  static const Color deepNavy = Color(0xFF1E1C44);
  static const Color deepNavyBorder = Color(0xFF323066);
  static const Color deepNavyDarker = Color(0xFF1E1D3A);
  static const Color indigoSoft = Color(0xFF818CF8);
  static const Color emeraldSoft = Color(0xFF34D399);
  static const Color amberSoft = Color(0xFFFBBF24);
  static const Color blueSoft = Color(0xFF60A5FA);
  static const Color pinkSoft = Color(0xFFF472B6);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color errorRedDark = Color(0xFFDC2626);
  static const Color errorRedBright = Color(0xFFEF4444);
  static const Color bluePrimary = Color(0xFF3B82F6);
  static const Color purpleDeep = Color(0xFF8B5CF6);
  static const Color purpleSoft = Color(0xFFA78BFA);
  static const Color indigoPrimaryDark = Color(0xFF4F46E5);
  static const Color indigoMuted = Color(0xFF1E1B4B);
  static const Color amberMuted = Color(0xFF451A03);
  static const Color blueMuted = Color(0xFF172554);
  static const Color slateMuted = Color(0xFF0F172A);
  static const Color slateSoft = Color(0xFF94A3B8);
  static const Color skyBlue = Color(0xFF0EA5E9);
  static const Color tealAccent = Color(0xFF2DD4BF);
  static const Color brightPink = Color(0xFFEC4899);
  static const Color emeraldDark = Color(0xFF059669);

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
