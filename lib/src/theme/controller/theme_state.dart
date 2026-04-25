import "package:al_furkan/src/theme/app_colors.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";

class ThemeState {
  final ThemeMode themeMode;

  const ThemeState({
    required this.themeMode,
  });

  bool get _isDark {
    if (themeMode == ThemeMode.dark) return true;
    if (themeMode == ThemeMode.light) return false;
    return SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
  }

  Color get primary => _isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
  Color get primaryShade100 => _isDark ? AppColors.darkPrimaryContainer : AppColors.lightPrimaryContainer;
  Color get primaryShade200 => _isDark ? AppColors.darkPrimaryLight : AppColors.lightPrimaryLight;
  Color get primaryShade300 => _isDark ? AppColors.darkSecondaryContainer : AppColors.lightSecondaryContainer;
  Color get secondary => _isDark ? AppColors.darkSecondary : AppColors.lightSecondary;
  Color get mutedGray => _isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted;

  ThemeState copyWith({
    ThemeMode? themeMode,
  }) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

