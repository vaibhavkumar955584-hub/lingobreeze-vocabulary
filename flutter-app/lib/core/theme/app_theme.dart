import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const primaryColor = Color(0xFF6366F1); // Indigo
  static const secondaryColor = Color(0xFF10B981); // Emerald
  static const accentColor = Color(0xFFF59E0B); // Amber
  static const backgroundColor = Color(0xFFF8FAFC);
  static const textDark = Color(0xFF1E293B);
  static const textMuted = Color(0xFF64748B);
  static const errorColor = Color(0xFFEF4444);
  static const borderLight = Color(0xFFE2E8F0);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme().copyWith(
        displaySmall: GoogleFonts.inter(fontWeight: FontWeight.w800, color: textDark),
        headlineMedium: GoogleFonts.inter(fontWeight: FontWeight.w700, color: textDark),
        titleMedium: GoogleFonts.inter(fontWeight: FontWeight.w600, color: textDark),
        bodyLarge: GoogleFonts.inter(color: textDark, fontSize: 16),
        bodyMedium: GoogleFonts.inter(color: textMuted, fontSize: 14),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textDark),
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderLight, width: 1),
        ),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
