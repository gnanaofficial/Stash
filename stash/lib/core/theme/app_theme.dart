import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Deep iOS Space Gray / OLED background
  static const bg = Color(0xFF000000);
  static const bgSecondary = Color(0xFF0D0D12);

  // Translucent iOS System Materials
  static const glassSurface = Color(0x2E1C1C26);
  static const glassBorder = Color(0x38FFFFFF);
  static const glassHighBorder = Color(0x55FFFFFF);

  // Apple Vibrant Colors
  static const appleBlue = Color(0xFF0A84FF);
  static const applePurple = Color(0xFFBF5AF2);
  static const appleIndigo = Color(0xFF5E5CE6);
  static const applePink = Color(0xFFFF375F);
  static const appleTeal = Color(0xFF64D2FF);
  static const appleGreen = Color(0xFF30D158);
  static const appleLime = Color(0xFFA3E635);
  static const appleEmerald = Color(0xFF10B981);
  static const appleOrange = Color(0xFFFF9F0A);
  static const appleYellow = Color(0xFFFFD60A);

  // Apple Typography Grays
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFEBEBF5);
  static const textTertiary = Color(0xFF8E8E93);
  static const textQuaternary = Color(0xFF48484A);

  // Apple Gradient Palettes
  static const List<List<Color>> collectionGradients = [
    [Color(0xFF5E5CE6), Color(0xFFBF5AF2)], // Indigo Purple
    [Color(0xFFFF375F), Color(0xFFFF9F0A)], // Pink Orange
    [Color(0xFF64D2FF), Color(0xFF0A84FF)], // Cyan Blue
    [Color(0xFF30D158), Color(0xFF059669)], // Green
    [Color(0xFFBF5AF2), Color(0xFFFF375F)], // Purple Pink
    [Color(0xFFFF9F0A), Color(0xFFFF453A)], // Sunset Red
  ];
}

class AppTheme {
  static ThemeData appleDark() {
    final textTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.appleBlue,
        secondary: AppColors.applePurple,
        surface: AppColors.bgSecondary,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: textTheme.displayLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.6,
          color: AppColors.textPrimary,
        ),
        titleLarge: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: -0.4,
          color: AppColors.textPrimary,
        ),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.appleBlue,
        barBackgroundColor: Color(0x6618181F),
        scaffoldBackgroundColor: AppColors.bg,
      ),
    );
  }
}
