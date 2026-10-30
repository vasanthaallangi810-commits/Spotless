import 'package:flutter/material.dart';

class AppTheme {
  static const darkGreen = Color(0xFF0A3323);
  static const mossGreen = Color(0xFF839958);
  static const beige = Color(0xFFF7F4D5);
  static const rosyBrown = Color(0xFFD3968C);
  static const midnightGreen = Color(0xFF105666);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: beige,

      colorScheme: ColorScheme.fromSeed(
        seedColor: mossGreen,
        brightness: Brightness.light,
      ).copyWith(
        primary: darkGreen,
        secondary: mossGreen,
        surface: beige,
      ),

      fontFamily: 'Arial',

      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: darkGreen,
        centerTitle: false,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.72),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: mossGreen,
            width: 2,
          ),
        ),
      ),
    );
  }
}