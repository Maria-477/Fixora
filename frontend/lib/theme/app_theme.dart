import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F6E56),
      brightness: Brightness.light,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18),
      bodyMedium: TextStyle(fontSize: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF0F6E56),
      brightness: Brightness.dark,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(fontSize: 18),
      bodyMedium: TextStyle(fontSize: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 56),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}