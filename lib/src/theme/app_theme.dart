import 'package:al_furkan/src/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  // ── Light Theme — Warm Beige + Sage Green ──
  static ThemeData lightTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.lightPrimary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.lightPrimaryContainer,
        onPrimaryContainer: AppColors.lightPrimary,
        secondary: AppColors.lightSecondary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.lightSecondaryContainer,
        onSecondaryContainer: AppColors.lightSecondary,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextMain,
        surfaceContainerLowest: AppColors.lightBackground,
        surfaceContainerLow: AppColors.lightSurface,
        surfaceContainer: AppColors.lightCard,
        surfaceContainerHigh: AppColors.lightElevated,
        surfaceContainerHighest: AppColors.lightBorder,
        error: AppColors.error,
        onError: Colors.white,
        outline: AppColors.lightBorder,
        outlineVariant: AppColors.lightOutlineVariant,
      ),
      scaffoldBackgroundColor: AppColors.lightBackground,
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.lightBorder, width: 0.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.lightCard,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.lightCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(color: AppColors.lightTextMain),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        foregroundColor: AppColors.lightTextMain,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.lightPrimary, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightPrimaryLight,
        selectedColor: AppColors.lightPrimaryContainer,
        labelStyle: const TextStyle(color: AppColors.lightPrimary, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.lightPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
    return base;
  }

  // ── Dark Theme — Deep Slate + Lighter Sage ──
  static ThemeData darkTheme() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary,
        onPrimary: AppColors.darkBackground,
        primaryContainer: AppColors.darkPrimaryContainer,
        onPrimaryContainer: AppColors.darkPrimary,
        secondary: AppColors.darkSecondary,
        onSecondary: AppColors.darkBackground,
        secondaryContainer: AppColors.darkSecondaryContainer,
        onSecondaryContainer: AppColors.darkSecondary,
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextMain,
        surfaceContainerLowest: AppColors.darkBackground,
        surfaceContainerLow: AppColors.darkSurface,
        surfaceContainer: AppColors.darkCard,
        surfaceContainerHigh: AppColors.darkElevated,
        surfaceContainerHighest: AppColors.darkBorder,
        error: AppColors.errorDark,
        onError: AppColors.darkBackground,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkOutlineVariant,
      ),
      scaffoldBackgroundColor: AppColors.darkBackground,
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.darkBorder.withValues(alpha: 0.5), width: 0.5),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.darkCard,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkCard,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(color: AppColors.darkTextMain),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextMain,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkPrimaryLight,
        selectedColor: AppColors.darkPrimaryContainer,
        labelStyle: const TextStyle(color: AppColors.darkPrimary, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary,
        foregroundColor: AppColors.darkBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: AppColors.darkBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
    return base;
  }
}
