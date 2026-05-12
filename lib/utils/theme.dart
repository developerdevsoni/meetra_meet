import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary - Deep Teal
  static const Color primary = Color(0xFF1F8A70);
  static const Color primaryLight = Color(0xFF4FBFA5);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFE0F2EF); // Alias for secondaryContainer
  
  // Neutral - Off White
  static const Color background = Color(0xFFF6F7F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1C1E);
  static const Color onSurfaceVariant = Color(0xFF6C727A);
  static const Color outlineVariant = Color(0xFFE2E8E4); // Alias for surfaceContainerHigh
  
  // Containers
  static const Color surfaceContainerLow = Color(0xFFEEF2EF); // Soft Greenish-Grey
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFE2E8E4);
  
  // Accents
  static const Color secondary = Color(0xFF4FBFA5);
  static const Color secondaryContainer = Color(0xFFE0F2EF);
  static const Color tertiary = Color(0xFF2D3132);
  static const Color tertiaryContainer = Color(0xFFEEF2EF); // Alias for surfaceContainerLow
  
  static const Color error = Color(0xFFBA1A1A);
  static const Color success = Color(0xFF2E7D32);
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
