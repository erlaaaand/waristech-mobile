import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.primary,
      // Prototipe: body{background:var(--white)} — putih polos, bukan gray-50.
      scaffoldBackgroundColor: AppColors.surface,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.amber,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSurface: AppColors.textLight,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: AppColors.textLight,
        displayColor: AppColors.textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.navy),
        titleTextStyle: TextStyle(
          color: AppColors.navy,
          fontSize: 17,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: Colors.white,
        secondary: AppColors.amber,
        surface: AppColors.darkSurface,
        onPrimary: Colors.black,
        onSurface: AppColors.textDark,
      ),
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 17,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
