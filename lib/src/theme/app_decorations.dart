import 'package:flutter/material.dart';

import 'app_colors.dart';
import '../constants/app_sizes.dart';

/// Al-Furkan Decoration Presets — Reusable BoxDecoration & InputDecoration
/// ZERO hardcoded decorations outside this file.
class AppDecorations {
  AppDecorations._();

  // ── Card Decorations ──

  static BoxDecoration cardLight({Color? color}) => BoxDecoration(
        color: color ?? AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: AppColors.lightBorder,
          width: 0.5,
        ),
      );

  static BoxDecoration cardDark({Color? color}) => BoxDecoration(
        color: color ?? AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusM),
        border: Border.all(
          color: AppColors.darkBorder.withValues(alpha: 0.5),
          width: 0.5,
        ),
      );

  // ── Bottom Sheet Decorations ──

  static const BoxDecoration bottomSheetLight = BoxDecoration(
    color: AppColors.lightCard,
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(AppSizes.radiusXL),
    ),
  );

  static const BoxDecoration bottomSheetDark = BoxDecoration(
    color: AppColors.darkCard,
    borderRadius: BorderRadius.vertical(
      top: Radius.circular(AppSizes.radiusXL),
    ),
  );

  // ── Dialog Decorations ──

  static BoxDecoration dialogLight({Color? color}) => BoxDecoration(
        color: color ?? AppColors.lightCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      );

  static BoxDecoration dialogDark({Color? color}) => BoxDecoration(
        color: color ?? AppColors.darkCard,
        borderRadius: BorderRadius.circular(AppSizes.radiusL),
      );

  // ── Chip Decorations ──

  static BoxDecoration chipLight({bool selected = false}) => BoxDecoration(
        color: selected
            ? AppColors.lightPrimaryContainer
            : AppColors.lightPrimaryLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      );

  static BoxDecoration chipDark({bool selected = false}) => BoxDecoration(
        color: selected
            ? AppColors.darkPrimaryContainer
            : AppColors.darkPrimaryLight,
        borderRadius: BorderRadius.circular(AppSizes.radiusS),
      );

  // ── Input Decorations ──

  static InputDecoration inputLight({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        filled: true,
        fillColor: AppColors.lightSurface,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(
            color: AppColors.lightPrimary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
      );

  static InputDecoration inputDark({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) =>
      InputDecoration(
        filled: true,
        fillColor: AppColors.darkSurface,
        hintText: hintText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(
            color: AppColors.darkPrimary,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          borderSide: const BorderSide(color: AppColors.errorDark),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM,
          vertical: AppSizes.paddingS,
        ),
      );

  // ── Ayah Highlight ──

  static const BoxDecoration ayahHighlightLight = BoxDecoration(
    color: AppColors.lightAyahHighlight,
    borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusXS)),
  );

  static const BoxDecoration ayahHighlightDark = BoxDecoration(
    color: AppColors.darkAyahHighlight,
    borderRadius: BorderRadius.all(Radius.circular(AppSizes.radiusXS)),
  );
}
