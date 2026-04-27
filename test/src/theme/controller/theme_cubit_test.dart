import 'package:al_furkan/src/theme/app_colors.dart';
import 'package:al_furkan/src/theme/controller/theme_cubit.dart';
import 'package:al_furkan/src/theme/controller/theme_state.dart';
import 'package:al_furkan/src/theme/functions/theme_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ThemeCubit themeCubit;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ThemeFunctions.initThemeFunction();
    themeCubit = ThemeCubit();
  });

  tearDown(() {
    themeCubit.close();
  });

  group('ThemeCubit', () {
    test('initial state defaults to system theme mode', () {
      expect(themeCubit.state.themeMode, ThemeMode.system);
    });

    test('setTheme emits new ThemeState with correct mode', () async {
      themeCubit.setTheme(ThemeMode.dark);
      await Future.microtask(() {});

      expect(themeCubit.state.themeMode, ThemeMode.dark);
    });

    test('setTheme persists theme mode to preferences', () async {
      themeCubit.setTheme(ThemeMode.light);
      await Future.microtask(() {});

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('app_theme_mode'), ThemeMode.light.toString());
    });

    test('setTheme to dark then light transitions correctly', () async {
      themeCubit.setTheme(ThemeMode.dark);
      await Future.microtask(() {});
      expect(themeCubit.state.themeMode, ThemeMode.dark);

      themeCubit.setTheme(ThemeMode.light);
      await Future.microtask(() {});
      expect(themeCubit.state.themeMode, ThemeMode.light);
    });

    test('refresh emits same state', () async {
      themeCubit.setTheme(ThemeMode.dark);
      await Future.microtask(() {});

      themeCubit.refresh();
      await Future.microtask(() {});

      expect(themeCubit.state.themeMode, ThemeMode.dark);
    });
  });

  group('ThemeState', () {
    test('copyWith preserves themeMode when not provided', () {
      const state = ThemeState(themeMode: ThemeMode.dark);
      final copied = state.copyWith();

      expect(copied.themeMode, ThemeMode.dark);
    });

    test('copyWith updates themeMode when provided', () {
      const state = ThemeState(themeMode: ThemeMode.dark);
      final copied = state.copyWith(themeMode: ThemeMode.light);

      expect(copied.themeMode, ThemeMode.light);
    });

    test('primary returns darkPrimary when themeMode is dark', () {
      const state = ThemeState(themeMode: ThemeMode.dark);
      expect(state.primary, AppColors.darkPrimary);
    });

    test('primary returns lightPrimary when themeMode is light', () {
      const state = ThemeState(themeMode: ThemeMode.light);
      expect(state.primary, AppColors.lightPrimary);
    });

    test('secondary returns darkSecondary when themeMode is dark', () {
      const state = ThemeState(themeMode: ThemeMode.dark);
      expect(state.secondary, AppColors.darkSecondary);
    });

    test('secondary returns lightSecondary when themeMode is light', () {
      const state = ThemeState(themeMode: ThemeMode.light);
      expect(state.secondary, AppColors.lightSecondary);
    });

    test('mutedGray returns darkTextMuted when themeMode is dark', () {
      const state = ThemeState(themeMode: ThemeMode.dark);
      expect(state.mutedGray, AppColors.darkTextMuted);
    });

    test('mutedGray returns lightTextMuted when themeMode is light', () {
      const state = ThemeState(themeMode: ThemeMode.light);
      expect(state.mutedGray, AppColors.lightTextMuted);
    });
  });
}
