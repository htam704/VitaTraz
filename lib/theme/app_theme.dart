import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_vitatraz_app/theme/theme.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.primary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.secondaryBackground,
      background: AppColors.primaryBackground,
      error: AppColors.error,
      onPrimary: AppColors.secondaryBackground,
      onSecondary: AppColors.secondaryBackground,
      onSurface: AppColors.primaryText,
      onBackground: AppColors.primaryText,
      onError: AppColors.secondaryBackground,
    ),
    textTheme: TextTheme(
      headlineMedium: GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.secondaryBackground,
      ),
      titleLarge: GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryText,
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 16,
        color: AppColors.primaryText,
      ),
      titleSmall: GoogleFonts.manrope(
        fontSize: 14,
        color: AppColors.secondaryText,
      ),
    ),
    iconTheme: const IconThemeData(
      size: 24,
      color: AppColors.primary,
    ),
    buttonTheme: const ButtonThemeData(
      buttonColor: AppColors.primary,
      textTheme: ButtonTextTheme.primary,
    ),
  );
}
