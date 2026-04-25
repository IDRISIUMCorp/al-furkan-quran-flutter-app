import 'package:flutter/material.dart';

/// 🎨 نظام الألوان - Hybrid من Wahy + Ayah
/// 
/// الفلسفة:
/// - الألوان من وحي (أكثر هدوءاً وروحانية)
/// - Borders من آية (أوضح وأكثر تنظيماً)
/// - النتيجة: تصميم هادئ + واضح = مثالي للصلاة
class PrayerThemeColors {
  // ═══════════════════════════════════════════
  // PRIMARY COLORS (من وحي - Warm & Calm)
  // ═══════════════════════════════════════════
  
  /// Main background - warm beige (like old paper)
  static const Color bgPrimary = Color(0xFFF8F6ED);
  
  /// Card/Surface background - pure white
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Slightly darker surface
  static const Color surfaceVariant = Color(0xFFF5F3E8);
  
  /// Elevated surface (dialogs, bottom sheets)
  static const Color surfaceElevated = Color(0xFFFBFAF5);
  
  // ═══════════════════════════════════════════
  // ACCENT COLORS (من وحي - Islamic Green)
  // ═══════════════════════════════════════════
  
  /// Islamic green - primary accent (used sparingly)
  static const Color green = Color(0xFF4A7C59);
  
  /// Darker green for pressed states
  static const Color greenDark = Color(0xFF3A5F47);
  
  /// Lighter green for backgrounds
  static const Color greenLight = Color(0xFFE8F0EB);
  
  /// Very light green for hover states
  static const Color greenVeryLight = Color(0xFFF0F5F3);
  
  // ═══════════════════════════════════════════
  // GOLD COLORS (للأوقات المميزة)
  // ═══════════════════════════════════════════
  
  /// Gold accent for special times
  static const Color gold = Color(0xFFC9A84C);
  
  /// Darker gold
  static const Color goldDark = Color(0xFFA08838);
  
  /// Light gold background
  static const Color goldLight = Color(0xFFF5EFE7);
  
  // ═══════════════════════════════════════════
  // TEXT COLORS (من وحي - Warm Grays)
  // ═══════════════════════════════════════════
  
  /// Main text color - warm dark gray
  static const Color textPrimary = Color(0xFF2C2C2C);
  
  /// Secondary text - medium gray
  static const Color textSecondary = Color(0xFF6B6B6B);
  
  /// Muted text - light gray
  static const Color textMuted = Color(0xFF9B9B9B);
  
  /// Arabic text - slightly warmer
  static const Color textArabic = Color(0xFF1E1E1E);
  
  /// Disabled text
  static const Color textDisabled = Color(0xFFBBBBBB);
  
  // ═══════════════════════════════════════════
  // BORDERS & DIVIDERS (من آية - أوضح)
  // ═══════════════════════════════════════════
  
  /// Standard borders - clearer than Wahy
  static const Color border = Color(0xFFDDD9CC);
  
  /// Light borders
  static const Color borderLight = Color(0xFFEFEDE3);
  
  /// Accent borders (green tinted)
  static const Color borderAccent = Color(0xFFD0E0D5);
  
  /// Dividers
  static const Color divider = Color(0xFFE8E5D8);
  
  // ═══════════════════════════════════════════
  // SEMANTIC COLORS
  // ═══════════════════════════════════════════
  
  /// Success / Completed prayer
  static const Color success = Color(0xFF4A7C59);
  static const Color successLight = Color(0xFFE8F0EB);
  
  /// Warning / Upcoming prayer
  static const Color warning = Color(0xFFD4A574);
  static const Color warningLight = Color(0xFFF5EFE7);
  
  /// Error / Missed prayer
  static const Color error = Color(0xFFC85A5A);
  static const Color errorLight = Color(0xFFF5E8E8);
  
  /// Info
  static const Color info = Color(0xFF5A8FC8);
  static const Color infoLight = Color(0xFFE8F0F5);
  
  // ═══════════════════════════════════════════
  // PRAYER STATUS COLORS
  // ═══════════════════════════════════════════
  
  /// Prayer passed
  static const Color prayerPassed = Color(0xFF9B9B9B);
  static const Color prayerPassedBg = Color(0xFFE3D5CA);
  
  /// Current prayer
  static const Color prayerCurrent = Color(0xFF4A7C59);
  static const Color prayerCurrentBg = Color(0xFFE8F0EB);
  
  /// Next prayer (highlighted)
  static const Color prayerNext = Color(0xFF4A7C59);
  static const Color prayerNextBg = Color(0xFFE8F0EB);
  
  /// Upcoming prayer
  static const Color prayerUpcoming = Color(0xFF2C2C2C);
  static const Color prayerUpcomingBg = Color(0xFFFFFFFF);
  
  // ═══════════════════════════════════════════
  // OVERLAYS & SHADOWS
  // ═══════════════════════════════════════════
  
  /// Modal overlay
  static const Color overlay = Color(0x4D000000);
  
  /// Dark overlay
  static const Color overlayDark = Color(0x66000000);
  
  /// Light shadow color
  static const Color shadow = Color(0x0A000000);
  
  // ═══════════════════════════════════════════
  // DARK THEME (Optional)
  // ═══════════════════════════════════════════
  
  static const Color bgDark = Color(0xFF1A1A1A);
  static const Color surfaceDark = Color(0xFF242424);
  static const Color textDark = Color(0xFFE8E8E8);
  static const Color borderDark = Color(0xFF3A3A3A);
  
  // ═══════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════
  
  /// Get background color based on theme
  static Color getBgColor(bool isDark) {
    return isDark ? bgDark : bgPrimary;
  }
  
  /// Get surface color based on theme
  static Color getSurfaceColor(bool isDark) {
    return isDark ? surfaceDark : surface;
  }
  
  /// Get text color based on type and theme
  static Color getTextColor(String type, bool isDark) {
    if (isDark) {
      return textDark;
    }
    
    switch (type) {
      case 'primary':
        return textPrimary;
      case 'secondary':
        return textSecondary;
      case 'muted':
        return textMuted;
      case 'arabic':
        return textArabic;
      default:
        return textPrimary;
    }
  }
  
  /// Get border color based on theme
  static Color getBorderColor(bool isDark) {
    return isDark ? borderDark : border;
  }
  
  /// Get prayer status color
  static Color getPrayerStatusColor(String status) {
    switch (status) {
      case 'passed':
        return prayerPassed;
      case 'current':
        return prayerCurrent;
      case 'next':
        return prayerNext;
      case 'upcoming':
        return prayerUpcoming;
      default:
        return prayerUpcoming;
    }
  }
  
  /// Get prayer status background color
  static Color getPrayerStatusBgColor(String status) {
    switch (status) {
      case 'passed':
        return prayerPassedBg;
      case 'current':
        return prayerCurrentBg;
      case 'next':
        return prayerNextBg;
      case 'upcoming':
        return prayerUpcomingBg;
      default:
        return prayerUpcomingBg;
    }
  }
  
  // ═══════════════════════════════════════════
  // ADDITIONAL SEMANTIC COLORS
  // ═══════════════════════════════════════════
  
  /// Forbidden time indicator
  static const Color forbidden = Color(0xFFC85A5A);
  static const Color forbiddenBg = Color(0xFFF5E8E8);
  
  // ═══════════════════════════════════════════
  // GRADIENT COLORS
  // ═══════════════════════════════════════════
  
  /// Hero card gradient (dark mode)
  static const List<Color> heroGradientDark = [
    Color(0xFF1E2A1E),
    Color(0xFF242426),
  ];
  
  /// Hero card gradient (light mode)
  static const List<Color> heroGradientLight = [
    Color(0xFFE8F0EB),
    Color(0xFFFFFFFF),
  ];
  
  /// Gold shimmer gradient
  static const List<Color> goldGradient = [
    Color(0xFFC9A84C),
    Color(0xFFE8D48C),
    Color(0xFFC9A84C),
  ];
}
