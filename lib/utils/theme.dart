import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary
  static const Color primary = Color(0xFF4F378A);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF6750A4);
  static const Color onPrimaryContainer = Color(0xFFE0D2FF);
  
  // Secondary
  static const Color secondary = Color(0xFF63597C);
  static const Color secondaryContainer = Color(0xFFE1D4FD);
  static const Color onSecondaryContainer = Color(0xFF645A7D);
  
  // Tertiary
  static const Color tertiary = Color(0xFF765B00);
  static const Color tertiaryContainer = Color(0xFFC9A74D);
  
  // Surface & Background
  static const Color background = Color(0xFFFDF7FF);
  static const Color surface = Color(0xFFFDF7FF);
  static const Color onSurface = Color(0xFF1D1B20);
  static const Color onSurfaceVariant = Color(0xFF494551);
  
  // Containers
  static const Color surfaceContainerLow = Color(0xFFF8F2FA);
  static const Color surfaceContainerHigh = Color(0xFFECE6EE);
  static const Color surfaceContainerHighest = Color(0xFFE6E0E9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  
  // Others
  static const Color error = Color(0xFFBA1A1A);
  static const Color outline = Color(0xFF7A7582);
  static const Color outlineVariant = Color(0xFFCBC4D2);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        background: AppColors.background,
        error: AppColors.error,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.onSurface,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: AppColors.onSurface,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.onSurfaceVariant,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
    );
  }

  static ThemeData get darkTheme => lightTheme; // For now
}
