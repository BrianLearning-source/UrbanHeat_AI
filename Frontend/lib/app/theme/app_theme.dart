import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get lightTheme {
    // Gaya teks yang dipetakan ke peran Material agar konsisten di semua halaman.
    final baseTextTheme = TextTheme(
      displayLarge: AppTextStyles.display,
      titleLarge: AppTextStyles.pageTitle,
      titleMedium: AppTextStyles.sectionTitle,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.body,
      bodySmall: AppTextStyles.caption,
      labelSmall: AppTextStyles.caption,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.surface,
        secondary: AppColors.accent,
        onSecondary: AppColors.surface,
        error: AppColors.heatHigh,
        onError: AppColors.surface,
        surface: AppColors.surface,
        onSurface: AppColors.primary,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme(baseTextTheme),
      dividerColor: AppColors.border,
      cardColor: AppColors.surface,
    );
  }
}
