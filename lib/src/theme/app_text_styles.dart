import 'package:flutter/material.dart';

/// Al-Furkan Typography System — Single Source of Truth
/// All TextStyle definitions centralized here.
/// ZERO hardcoded font sizes outside this file.
class AppTextStyles {
  AppTextStyles._();

  // ── Display ──
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static const TextStyle displayMedium = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.3,
  );

  // ── Headline ──
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ── Body ──
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ── Label ──
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.1,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    letterSpacing: 0.5,
  );

  // ── Caption ──
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.2,
  );

  // ── Quran-Specific ──
  static const TextStyle quranUthmani = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 2.0,
    letterSpacing: 0,
  );

  static const TextStyle quranTranslation = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.8,
  );

  static const TextStyle quranTafsir = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.7,
  );

  static const TextStyle quranAyahNumber = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );
}
