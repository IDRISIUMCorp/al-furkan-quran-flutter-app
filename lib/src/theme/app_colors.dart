import 'package:flutter/material.dart';

/// Al-Furkan Color System — Inspired by Ayah App
/// Philosophy: Organic Minimalism & Quiet Luxury
/// Warm earth tones (Light), Deep slate (Dark), Sage green accent
class AppColors {
  // ==========================================
  // LIGHT MODE — Warm Beige/Cream Palette
  // ==========================================

  /// Main background — screens, lists
  static const Color lightBackground = Color(0xFFF5EBE0);

  /// Surface — header bars, bottom bars, search fields
  static const Color lightSurface = Color(0xFFEDE4D4);

  /// Card / Sheet background — bottom sheets, popup cards, index items
  static const Color lightCard = Color(0xFFF5EBE0);

  /// Elevated surface — dialogs, dropdowns
  static const Color lightElevated = Color(0xFFE3D5CA);

  /// Primary Interactive Color — Sage Green (The Signature)
  static const Color lightPrimary = Color(0xFF5D7263);

  /// Primary light — subtle backgrounds, chips, badges
  static const Color lightPrimaryLight = Color(0xFFD4E2D9);

  /// Primary container — selected states, active tabs
  static const Color lightPrimaryContainer = Color(0xFFB8CFC0);

  /// Secondary — warm brown accent
  static const Color lightSecondary = Color(0xFF8B7355);

  /// Secondary container — subtle brown backgrounds
  static const Color lightSecondaryContainer = Color(0xFFF0E6D6);

  /// Highlight color for currently reading ayah
  static const Color lightAyahHighlight = Color(0xFFEADBC3);

  /// Audio player background
  static const Color lightAudioPlayerBg = Color(0xFFEDE4D4);

  // --- Light Text Colors ---
  static const Color lightTextMain = Color(0xFF212529);
  static const Color lightTextSecondary = Color(0xFF6C757D);
  static const Color lightTextMuted = Color(0xFF8F8F8F);

  /// Border and Divider colors
  static const Color lightBorder = Color(0xFFD6CCC2);
  static const Color lightOutlineVariant = Color(0xFFE3D5CA);

  // ==========================================
  // DARK MODE — Deep Slate/Charcoal Palette
  // ==========================================

  /// Main background — screens, lists
  static const Color darkBackground = Color(0xFF212529);

  /// Surface — header bars, bottom bars
  static const Color darkSurface = Color(0xFF343A40);

  /// Card / Sheet background
  static const Color darkCard = Color(0xFF495057);

  /// Elevated surface — dialogs, dropdowns
  static const Color darkElevated = Color(0xFF545C64);

  /// Primary Interactive Color — Lighter Sage for dark mode
  static const Color darkPrimary = Color(0xFF839788);

  /// Primary light — subtle backgrounds in dark mode
  static const Color darkPrimaryLight = Color(0xFF3D4A42);

  /// Primary container — selected states in dark mode
  static const Color darkPrimaryContainer = Color(0xFF4A5B52);

  /// Secondary — warm muted brown
  static const Color darkSecondary = Color(0xFFB8A080);

  /// Secondary container
  static const Color darkSecondaryContainer = Color(0xFF3D3529);

  /// Highlight color for currently reading ayah
  static const Color darkAyahHighlight = Color(0xFF4A5B52);

  /// Audio player background
  static const Color darkAudioPlayerBg = Color(0xFF343A40);

  // --- Dark Text Colors ---
  static const Color darkTextMain = Color(0xFFF8F9FA);
  static const Color darkTextSecondary = Color(0xFFCED4DA);
  static const Color darkTextMuted = Color(0xFFADB5BD);

  /// Border and Divider colors
  static const Color darkBorder = Color(0xFF495057);
  static const Color darkOutlineVariant = Color(0xFF545C64);

  // ==========================================
  // SHARED — Error & Semantic Colors
  // ==========================================
  static const Color error = Color(0xFFB3261E);
  static const Color errorDark = Color(0xFFF2B8B5);

  // ==========================================
  // LEGACY COMPATIBILITY
  // ==========================================
  static const Color ayaBackground = lightBackground;
  static const Color ayaSurface = lightSurface;
  static const Color ayaCard = lightCard;
  static const Color ayaPrimary = lightPrimary;
  static const Color ayaPrimaryLight = lightPrimaryLight;
  static const Color ayaAyahHighlight = lightAyahHighlight;
  static const Color ayaAudioPlayerBg = lightAudioPlayerBg;
  static const Color ayaTextMain = lightTextMain;
  static const Color ayaTextSecondary = lightTextSecondary;
  static const Color ayaTextMuted = lightTextMuted;
  static const Color ayaBorder = lightBorder;

  static const Color primary = lightPrimary;
  static const Color background = lightBackground;
  static const Color surface = lightSurface;
  static const Color textPrimaryLight = lightTextMain;
  static const Color textSecondaryLight = lightTextSecondary;
}
