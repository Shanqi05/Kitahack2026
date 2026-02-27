import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Color Palette
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color successGreen = Color(0xFF34A853);
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textdDark = Color(0xFF202124);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: googleBlue,
        primary: googleBlue,
        secondary: successGreen,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,

      // Text Theme using Google Fonts Inter
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textdDark,
        displayColor: textdDark,
      ),

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textdDark),
        titleTextStyle: TextStyle(
          color: textdDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: googleBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
    );
  }
}
