// lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Colores compartidos
  static const primaryBlue = Color(0xFF3B82F6);
  static const statusActive = Color(0xFF22C55E);
  static const statusPaused = Color(0xFFEAB308);

  // Colores Tema Oscuro
  static const darkBackground = Color(0xFF0F172A);
  static const darkSurface = Color(0xFF1E293B);
  static const darkTextPrimary = Color(0xFFF1F5F9);
  static const darkTextSecondary = Color(0xFF94A3B8);
  static const darkBorder = Color(0xFF334155);

  // Colores Tema Claro
  static const lightBackground = Color(0xFFF1F5F9);
  static const lightSurface = Colors.white;
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF64748B);
  static const lightBorder = Color(0xFFE2E8F0);
}

class AppTheme {
  // --- TEMA OSCURO ---
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppColors.darkTextPrimary,
      displayColor: AppColors.darkTextPrimary,
    ),
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryBlue,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: AppColors.darkBorder, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
    ),
    elevatedButtonTheme: _elevatedButtonTheme,
    dataTableTheme: _darkDataTableTheme,
  );

  // --- TEMA CLARO ---
  static final ThemeData lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppColors.lightTextPrimary,
      displayColor: AppColors.lightTextPrimary,
    ),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryBlue,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: AppColors.lightBorder, width: 1),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.lightBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.lightTextSecondary),
    ),
    elevatedButtonTheme: _elevatedButtonTheme,
    dataTableTheme: _lightDataTableTheme,
  );

  // --- ESTILOS COMPARTIDOS ---
  static final _elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primaryBlue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      textStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  static final _darkDataTableTheme = DataTableThemeData(
    headingRowColor: WidgetStateProperty.all(AppColors.darkSurface),
    dataRowColor: WidgetStateProperty.all(AppColors.darkSurface),
    dividerThickness: 1,
    headingTextStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextSecondary,
    ),
    dataTextStyle: const TextStyle(
      color: AppColors.darkTextPrimary,
    ),
  );

  static final _lightDataTableTheme = DataTableThemeData(
    headingRowColor: WidgetStateProperty.all(AppColors.lightSurface),
    dataRowColor: WidgetStateProperty.all(AppColors.lightSurface),
    dividerThickness: 1,
    headingTextStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextSecondary,
    ),
    dataTextStyle: const TextStyle(
      color: AppColors.lightTextPrimary,
    ),
  );
}