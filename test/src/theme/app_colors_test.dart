import 'package:al_furkan/src/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppColors', () {
    test('light and dark primary are different colors', () {
      expect(AppColors.lightPrimary, isNot(equals(AppColors.darkPrimary)));
    });

    test('light and dark backgrounds are different colors', () {
      expect(AppColors.lightBackground, isNot(equals(AppColors.darkBackground)));
    });

    test('error color is defined', () {
      expect(AppColors.error, isNotNull);
      expect(AppColors.error, isA<Color>());
    });

    test('all light colors are opaque (alpha = 255)', () {
      final lightColors = <Color>[
        AppColors.lightBackground,
        AppColors.lightSurface,
        AppColors.lightCard,
        AppColors.lightPrimary,
        AppColors.lightTextMain,
        AppColors.lightBorder,
      ];
      for (final color in lightColors) {
        expect(color.a, equals(1.0), reason: 'Color should be opaque');
      }
    });

    test('all dark colors are opaque (alpha = 255)', () {
      final darkColors = <Color>[
        AppColors.darkBackground,
        AppColors.darkSurface,
        AppColors.darkCard,
        AppColors.darkPrimary,
        AppColors.darkTextMain,
        AppColors.darkBorder,
      ];
      for (final color in darkColors) {
        expect(color.a, equals(1.0), reason: 'Color should be opaque');
      }
    });

    test('light text has high contrast on light background', () {
      // Light text main should be dark enough for readability
      final luminance = AppColors.lightTextMain.computeLuminance();
      expect(luminance, lessThan(0.5), reason: 'Light mode text should be dark');
    });

    test('dark text has high contrast on dark background', () {
      // Dark text main should be light enough for readability
      final luminance = AppColors.darkTextMain.computeLuminance();
      expect(luminance, greaterThan(0.5), reason: 'Dark mode text should be light');
    });
  });
}
