import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF2563EB);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF0F172A),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Color(0xFF0F172A)),
        headlineMedium: TextStyle(color: Color(0xFF0F172A)),
        headlineSmall: TextStyle(color: Color(0xFF0F172A)),
        titleLarge: TextStyle(
            color: Color(0xFF0F172A),
          fontSize: 17,
          fontFamily: "Inter",
        ),
        titleMedium: TextStyle(color: Color(0xFF0F172A)),
        titleSmall: TextStyle(color: Color(0xFF0F172A)),
        bodyLarge: TextStyle(color: Color(0xFF334155)),
        bodyMedium: TextStyle(color: Color(0xFF334155)),
        bodySmall: TextStyle(color: Color(0xFF64748B)),
        labelLarge: TextStyle(color: Color(0xFF0F172A)),
        labelMedium: TextStyle(color: Color(0xFF334155)),
        labelSmall: TextStyle(color: Color(0xFF64748B)),
      ),
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF020617),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF1E293B)),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: Color(0xFFF8FAFC)),
        headlineMedium: TextStyle(color: Color(0xFFF8FAFC)),
        headlineSmall: TextStyle(color: Color(0xFFF8FAFC)),
        titleLarge: TextStyle(
            color: Color(0xFFF8FAFC),
          fontSize: 17,
          fontFamily: "Inter",
        ),
        titleMedium: TextStyle(color: Color(0xFFF8FAFC)),
        titleSmall: TextStyle(color: Color(0xFFF8FAFC)),
        bodyLarge: TextStyle(color: Color(0xFFCBD5E1)),
        bodyMedium: TextStyle(color: Color(0xFFCBD5E1)),
        bodySmall: TextStyle(color: Color(0xFF94A3B8)),
        labelLarge: TextStyle(color: Color(0xFFF8FAFC)),
        labelMedium: TextStyle(color: Color(0xFFCBD5E1)),
        labelSmall: TextStyle(color: Color(0xFF94A3B8)),
      ),
    );


  }
}