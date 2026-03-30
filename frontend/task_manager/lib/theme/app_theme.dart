import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Colors
  static const Color _lightSeedColor = Color(0xFF6366F1); // Modern Indigo
  static const Color _lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color _lightSurface = Colors.white;
  static const Color _lightText = Color(0xFF0F172A); // Slate 900
  static const Color _lightTextSecondary = Color(0xFF64748B); // Slate 500

  // Dark Theme Colors
  static const Color _darkSeedColor = Color(0xFF818CF8); // Lighter Indigo
  static const Color _darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color _darkSurface = Color(0xFF1E293B); // Slate 800
  static const Color _darkText = Color(0xFFF8FAFC); // Slate 50
  static const Color _darkTextSecondary = Color(0xFF94A3B8); // Slate 400

  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme();
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _lightSeedColor,
        brightness: Brightness.light,
        surface: _lightBackground,
        onSurface: _lightText,
      ),
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: _lightText),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: _lightText),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: _lightTextSecondary),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: _lightBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: _lightText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: _lightText),
      ),
      cardTheme: CardThemeData(
        color: _lightSurface,
        elevation: 4,
        shadowColor: const Color(0xFF94A3B8).withValues(alpha: 0.2), // Slate 400
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)), // Slate 200
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _lightSeedColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightSeedColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.outfitTextTheme(ThemeData(brightness: Brightness.dark).textTheme);
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _darkSeedColor,
        brightness: Brightness.dark,
        surface: _darkBackground,
        onSurface: _darkText,
      ),
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge?.copyWith(color: _darkText),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(color: _darkText),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(color: _darkTextSecondary),
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: _darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.outfit(
          color: _darkText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: _darkText),
      ),
      cardTheme: CardThemeData(
        color: _darkSurface,
        elevation: 0, // Less elevation in dark mode to avoid glowing edges
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF334155), width: 1), // Slate 700
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF334155)), // Slate 700
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: _darkSeedColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: const TextStyle(color: _darkTextSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _darkSeedColor,
          foregroundColor: _darkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }
}
