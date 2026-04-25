import 'package:flutter/material.dart';
import 'package:al_furkan/core/models/update_config.dart';

/// Builds the dialog decoration based on the selected [DialogStyle].
///
/// Each style returns a different visual treatment for the dialog shell.
/// The content (title, changelog, buttons) is handled separately in [UpdateDialog].
class DialogStyleBuilder {
  const DialogStyleBuilder._();

  /// Returns the full dialog container decoration for the given style.
  static BoxDecoration decoration(DialogStyle style, UpdateConfig config) {
    return switch (style) {
      DialogStyle.liquidGlass => _liquidGlass(config),
      DialogStyle.frostedGlass => _frostedGlass(config),
      DialogStyle.material3 => _material3(config),
      DialogStyle.amoled => _amoled(config),
      DialogStyle.minimal => _minimal(config),
      DialogStyle.islamicGold => _islamicGold(config),
    };
  }

  /// Returns the backdrop blur sigma for the given style.
  static double blurSigma(DialogStyle style, UpdateConfig config) {
    return switch (style) {
      DialogStyle.liquidGlass => config.backgroundBlur * 1.2,
      DialogStyle.frostedGlass => config.backgroundBlur,
      DialogStyle.material3 => 8,
      DialogStyle.amoled => 6,
      DialogStyle.minimal => 12,
      DialogStyle.islamicGold => config.backgroundBlur,
    };
  }

  /// Returns barrier color per style.
  static Color barrierColor(DialogStyle style, UpdateConfig config) {
    final opacity = config.backgroundOpacity;
    return switch (style) {
      DialogStyle.liquidGlass => Colors.black.withValues(alpha: opacity * 0.7),
      DialogStyle.frostedGlass => Colors.black.withValues(alpha: opacity * 0.8),
      DialogStyle.material3 => Colors.black.withValues(alpha: opacity * 0.5),
      DialogStyle.amoled => Colors.black.withValues(alpha: opacity * 0.95),
      DialogStyle.minimal => Colors.white.withValues(alpha: opacity * 0.3),
      DialogStyle.islamicGold => Colors.black.withValues(alpha: opacity * 0.85),
    };
  }

  /// Returns the title text style per style.
  static TextStyle titleStyle(DialogStyle style, UpdateConfig config) {
    return switch (style) {
      DialogStyle.liquidGlass => TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white.withValues(alpha: 0.95),
          fontFamily: 'Cairo-Bold',
        ),
      DialogStyle.frostedGlass => const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          fontFamily: 'Cairo-Bold',
        ),
      DialogStyle.material3 => TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: config.primaryColor,
        ),
      DialogStyle.amoled => const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      DialogStyle.minimal => const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E1E1E),
          fontFamily: 'Cairo-Bold',
        ),
      DialogStyle.islamicGold => const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Color(0xFFE8D48B),
          fontFamily: 'Cairo-Bold',
          letterSpacing: 1,
        ),
    };
  }

  /// Returns the body text style per style.
  static TextStyle bodyStyle(DialogStyle style) {
    return switch (style) {
      DialogStyle.liquidGlass => TextStyle(
          fontSize: 14, color: Colors.white.withValues(alpha: 0.75), height: 1.5),
      DialogStyle.frostedGlass => TextStyle(
          fontSize: 14, color: Colors.white.withValues(alpha: 0.8), height: 1.5),
      DialogStyle.material3 => TextStyle(
          fontSize: 14, color: Colors.grey.shade700, height: 1.5),
      DialogStyle.amoled => TextStyle(
          fontSize: 14, color: Colors.grey.shade400, height: 1.5),
      DialogStyle.minimal => TextStyle(
          fontSize: 14, color: Colors.grey.shade600, height: 1.5),
      DialogStyle.islamicGold => TextStyle(
          fontSize: 14, color: Colors.grey.shade300, height: 1.5),
    };
  }

  /// Returns the primary button style per dialog style.
  static ButtonStyle primaryButton(DialogStyle style, UpdateConfig config) {
    return switch (style) {
      DialogStyle.liquidGlass => ElevatedButton.styleFrom(
          backgroundColor: config.primaryColor.withValues(alpha: 0.8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      DialogStyle.frostedGlass => ElevatedButton.styleFrom(
          backgroundColor: config.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      DialogStyle.material3 => ElevatedButton.styleFrom(
          backgroundColor: config.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 14),
          elevation: 2,
        ),
      DialogStyle.amoled => ElevatedButton.styleFrom(
          backgroundColor: config.primaryColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      DialogStyle.minimal => ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      DialogStyle.islamicGold => ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: const Color(0xFFE8D48B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFC9A84C), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
    };
  }

  /// Returns the changelog item icon color per style.
  static Color changelogIconColor(DialogStyle style) {
    return switch (style) {
      DialogStyle.liquidGlass => Colors.white.withValues(alpha: 0.6),
      DialogStyle.frostedGlass => Colors.white.withValues(alpha: 0.7),
      DialogStyle.material3 => Colors.grey.shade600,
      DialogStyle.amoled => Colors.grey.shade500,
      DialogStyle.minimal => Colors.grey.shade500,
      DialogStyle.islamicGold => const Color(0xFFC9A84C),
    };
  }

  // ── PRIVATE DECORATIONS ─────────────────────────────────

  // 1. Liquid Glass — translucent, vibrant, Apple-style
  static BoxDecoration _liquidGlass(UpdateConfig config) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(config.cornerRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.12),
          Colors.white.withValues(alpha: 0.05),
          config.primaryColor.withValues(alpha: 0.08),
        ],
      ),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.18),
        width: 0.8,
      ),
      boxShadow: [
        BoxShadow(
          color: config.primaryColor.withValues(alpha: 0.15),
          blurRadius: 40,
          spreadRadius: -5,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 30,
          offset: const Offset(0, 10),
        ),
      ],
    );
  }

  // 2. Frosted Glass — classic glassmorphism
  static BoxDecoration _frostedGlass(UpdateConfig config) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(config.cornerRadius),
      color: const Color(0xFF1E1E1E).withValues(alpha: 0.75),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.1),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.4),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  // 3. Material 3 — clean, elevated, Google-style
  static BoxDecoration _material3(UpdateConfig config) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(config.cornerRadius),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.1),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: config.primaryColor.withValues(alpha: 0.08),
          blurRadius: 40,
          spreadRadius: -10,
        ),
      ],
    );
  }

  // 4. AMOLED — pure black with neon accent border
  static BoxDecoration _amoled(UpdateConfig config) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(config.cornerRadius),
      color: const Color(0xFF000000),
      border: Border.all(
        color: config.primaryColor.withValues(alpha: 0.5),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: config.primaryColor.withValues(alpha: 0.2),
          blurRadius: 30,
          spreadRadius: -5,
        ),
      ],
    );
  }

  // 5. Minimal — white, simple, Notion-style
  static BoxDecoration _minimal(UpdateConfig config) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(config.cornerRadius),
      color: const Color(0xFFFCFCFC),
      border: Border.all(
        color: const Color(0xFFE5E5E5),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // 6. Islamic Gold — dark with gold accents
  static BoxDecoration _islamicGold(UpdateConfig config) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(config.cornerRadius),
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF1A1A0F),
          Color(0xFF0D0D08),
        ],
      ),
      border: Border.all(
        width: 1.5,
        color: const Color(0xFFC9A84C).withValues(alpha: 0.4),
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFC9A84C).withValues(alpha: 0.12),
          blurRadius: 30,
          spreadRadius: -5,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }
}
