import 'package:flutter/material.dart';

class AppTheme {
  // Spatial / glassmorphism dark palette
  static const Color bg         = Color(0xFF080C14);
  static const Color bg2        = Color(0xFF0E1420);
  static const Color surface    = Color(0xFF131B2E);
  static const Color surface2   = Color(0xFF1A2440);
  static const Color glass      = Color(0x1AFFFFFF);
  static const Color glassBorder= Color(0x26FFFFFF);
  static const Color accent     = Color(0xFF6C63FF);   // purple
  static const Color accent2    = Color(0xFF00D4FF);   // cyan
  static const Color accentPink = Color(0xFFFF6B9D);   // pink
  static const Color gold       = Color(0xFFFFD700);
  static const Color textPrimary   = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF7A8BA8);
  static const Color border     = Color(0x1AFFFFFF);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accent, accent2],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [accentPink, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0xDD080C14)],
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accent2,
        surface: surface,
        onPrimary: Colors.white,
        onSurface: textPrimary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: textPrimary, letterSpacing: -1),
        displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: textPrimary, letterSpacing: -0.5),
        displaySmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: textPrimary),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: textPrimary),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: textPrimary),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: textSecondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textSecondary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: glassBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: glassBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      iconTheme: const IconThemeData(color: textPrimary),
      dividerColor: border,
    );
  }

  static ThemeData get lightTheme {
    const Color lBg       = Color(0xFFF4F6FC);
    const Color lSurface  = Color(0xFFFFFFFF);
    const Color lText     = Color(0xFF1A1E2E);
    const Color lTextSec  = Color(0xFF6B7A99);
    const Color lBorder   = Color(0xFFDDE3F0);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lBg,
      colorScheme: const ColorScheme.light(
        primary: accent,
        secondary: accent2,
        surface: lSurface,
        onPrimary: Colors.white,
        onSurface: lText,
      ),
      textTheme: const TextTheme(
        displayLarge:  TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: lText, letterSpacing: -1),
        displayMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: lText, letterSpacing: -0.5),
        displaySmall:  TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: lText),
        headlineLarge: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: lText),
        headlineMedium:TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: lText),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: lText),
        bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: lText),
        bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: lText),
        bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: lTextSec),
        labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: lText),
        labelSmall:    TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: lTextSec),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: lText),
        titleTextStyle: TextStyle(color: lText, fontSize: 20, fontWeight: FontWeight.w700),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: lBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: accent, width: 1.5),
        ),
        hintStyle: const TextStyle(color: lTextSec, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          elevation: 0,
        ),
      ),
      iconTheme: const IconThemeData(color: lText),
      dividerColor: lBorder,
      cardColor: lSurface,
    );
  }
}
