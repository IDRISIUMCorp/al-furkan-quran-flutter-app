import 'package:al_furkan/src/theme/functions/theme_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await ThemeFunctions.initThemeFunction();
  });

  group('ThemeFunctions', () {
    test('initThemeFunction initializes preferences', () {
      expect(ThemeFunctions.preferences, isNotNull);
    });

    test('setThemeMode persists dark mode', () async {
      await ThemeFunctions.setThemeMode(ThemeMode.dark);
      final saved = ThemeFunctions.preferences!.getString('app_theme_mode');
      expect(saved, ThemeMode.dark.toString());
    });

    test('setThemeMode persists light mode', () async {
      await ThemeFunctions.setThemeMode(ThemeMode.light);
      final saved = ThemeFunctions.preferences!.getString('app_theme_mode');
      expect(saved, ThemeMode.light.toString());
    });

    test('setThemeMode persists system mode', () async {
      await ThemeFunctions.setThemeMode(ThemeMode.system);
      final saved = ThemeFunctions.preferences!.getString('app_theme_mode');
      expect(saved, ThemeMode.system.toString());
    });

    test('loadThemeMode returns saved dark mode', () async {
      await ThemeFunctions.preferences!.setString(
        'app_theme_mode',
        ThemeMode.dark.toString(),
      );
      final loaded = ThemeFunctions.loadThemeMode();
      expect(loaded, ThemeMode.dark);
    });

    test('loadThemeMode returns saved light mode', () async {
      await ThemeFunctions.preferences!.setString(
        'app_theme_mode',
        ThemeMode.light.toString(),
      );
      final loaded = ThemeFunctions.loadThemeMode();
      expect(loaded, ThemeMode.light);
    });
  });
}
