import 'package:flutter/material.dart';

/// 🎨 نظام ألوان السنن - Hybrid من Wahy + Ayah
/// 
/// الفلسفة:
/// - الألوان من وحي (أكثر هدوءاً وروحانية)
/// - المسافات من آية (أكثر سخاءً)
/// - Typography من آية (أسهل قراءة)
class SunnahTheme {
  // ═══════════════════════════════════════════
  // COLORS (من وحي - Warm & Spiritual)
  // ═══════════════════════════════════════════
  
  /// Main background - warm beige
  static const Color bgPrimary = Color(0xFFF8F6ED);
  static const Color bgDark = Color(0xFF1A1F26);
  
  /// Card/Surface background
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF242933);
  
  /// Surface variant
  static const Color surfaceVariant = Color(0xFFF5F3E8);
  static const Color surfaceVariantDark = Color(0xFF2D3340);
  
  /// Islamic green - primary accent
  static const Color green = Color(0xFF4A7C59);
  static const Color greenDark = Color(0xFF3A5F47);
  static const Color greenLight = Color(0xFFE8F0EB);
  
  /// Gold accent
  static const Color gold = Color(0xFFC9A84C);
  static const Color goldDark = Color(0xFFA08838);
  static const Color goldLight = Color(0xFFF5EFE7);
  
  /// Text colors
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textPrimaryDark = Color(0xFFF8F9FA);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textSecondaryDark = Color(0xFFB8BCC2);
  static const Color textMuted = Color(0xFF9B9B9B);
  static const Color textMutedDark = Color(0xFF6B7280);
  
  /// Borders
  static const Color border = Color(0xFFDDD9CC);
  static const Color borderDark = Color(0xFF3A3F4D);
  static const Color borderLight = Color(0xFFEFEDE3);
  
  /// Semantic colors
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  
  /// Badge colors
  static const Color badgeRukn = Color(0xFFDC2626);
  static const Color badgeRuknLight = Color(0xFFFEE2E2);
  static const Color badgeSunnah = Color(0xFFC9A84C);
  static const Color badgeSunnahLight = Color(0xFFF5EFE7);
  
  // ═══════════════════════════════════════════
  // DIMENSIONS (من آية - More Generous)
  // ═══════════════════════════════════════════
  
  /// Spacing
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;
  static const double space40 = 40.0;
  
  /// Border radius
  static const double radiusSmall = 10.0;
  static const double radiusMedium = 14.0;
  static const double radiusLarge = 18.0;
  static const double radiusXLarge = 24.0;
  
  /// Border width
  static const double borderThin = 0.5;
  static const double borderStandard = 1.5;
  static const double borderThick = 2.0;
  
  /// Touch targets
  static const double touchTarget = 44.0;
  
  /// Icon sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 20.0;
  static const double iconLarge = 24.0;
  static const double iconXLarge = 28.0;
  
  // ═══════════════════════════════════════════
  // ANIMATIONS
  // ═══════════════════════════════════════════
  
  static const int durationFast = 200;
  static const int durationNormal = 300;
  static const int durationSlow = 400;
  static const int durationStagger = 50;
  
  // ═══════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════
  
  static Color getBgColor(bool isDark) {
    return isDark ? bgDark : bgPrimary;
  }
  
  static Color getSurfaceColor(bool isDark) {
    return isDark ? surfaceDark : surface;
  }
  
  static Color getSurfaceVariantColor(bool isDark) {
    return isDark ? surfaceVariantDark : surfaceVariant;
  }
  
  static Color getTextPrimaryColor(bool isDark) {
    return isDark ? textPrimaryDark : textPrimary;
  }
  
  static Color getTextSecondaryColor(bool isDark) {
    return isDark ? textSecondaryDark : textSecondary;
  }
  
  static Color getTextMutedColor(bool isDark) {
    return isDark ? textMutedDark : textMuted;
  }
  
  static Color getBorderColor(bool isDark) {
    return isDark ? borderDark : border;
  }
}
