import 'package:flutter/material.dart';

class ZenTheme {
  // Light Palette: Warm paper (#FBF8F3), soft card (#F2ECE1), charcoal (#1E201D), sage (#4A6B5D)
  static const Color lightBg = Color(0xFFFBF8F3);
  static const Color lightSurface = Color(0xFFF2ECE1);
  static const Color lightText = Color(0xFF1E201D);
  static const Color lightSage = Color(0xFF4A6B5D);
  static const Color lightBorder = Color(0xFFE8E2D7);

  // Dark / Night Hifz Palette: Deep slate (#121615), amber text (#E6D5B8), muted sage (#7FA695)
  static const Color darkBg = Color(0xFF121615);
  static const Color darkSurface = Color(0xFF19211D);
  static const Color darkAmberText = Color(0xFFE6D5B8);
  static const Color darkSage = Color(0xFF7FA695);
  static const Color darkBorder = Color(0xFF243029);

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: lightBg,
      colorScheme: const ColorScheme.light(
        primary: lightSage,
        surface: lightSurface,
        onSurface: lightText,
      ),
      fontFamily: 'Cairo',
      appBarTheme: const AppBarTheme(
        backgroundColor: lightBg,
        foregroundColor: lightText,
        elevation: 0,
      ),
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: darkSage,
        surface: darkSurface,
        onSurface: darkAmberText,
      ),
      fontFamily: 'Cairo',
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        foregroundColor: darkAmberText,
        elevation: 0,
      ),
    );
  }
}
