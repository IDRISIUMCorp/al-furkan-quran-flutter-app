import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 📐 نظام المسافات والأبعاد - من آية (Ayah)
/// 
/// الفلسفة:
/// - مسافات أكثر سخاءً من وحي
/// - touch targets أكبر (44dp بدل 40dp)
/// - border radius أكبر (14dp بدل 12dp)
/// - النتيجة: تصميم أكثر راحة وأفضل accessibility
class PrayerDimensions {
  // ═══════════════════════════════════════════
  // SPACING SCALE (Base: 4dp)
  // ═══════════════════════════════════════════
  
  static double get space4 => 4.w;
  static double get space8 => 8.w;
  static double get space12 => 12.w;
  static double get space16 => 16.w;
  static double get space20 => 20.w;
  static double get space24 => 24.w;
  static double get space32 => 32.w;
  static double get space40 => 40.w;
  static double get space48 => 48.w;
  static double get space64 => 64.w;
  static double get space80 => 80.w;
  static double get space96 => 96.w;
  
  // ═══════════════════════════════════════════
  // LAYOUT DIMENSIONS (من آية - أكثر سخاءً)
  // ═══════════════════════════════════════════
  
  /// Page horizontal padding (آية: 24dp, وحي: 20dp)
  static double get pagePadding => 24.w;
  
  /// Card internal padding (آية: 20dp, وحي: 16dp)
  static double get cardPadding => 20.w;
  
  /// Section vertical spacing (آية: 40dp, وحي: 32dp)
  static double get sectionSpacing => 40.h;
  
  /// List item spacing (آية: 16dp, وحي: 12dp)
  static double get listItemSpacing => 16.h;
  
  /// Small spacing
  static double get smallSpacing => 12.h;
  
  // ═══════════════════════════════════════════
  // COMPONENT HEIGHTS
  // ═══════════════════════════════════════════
  
  /// Standard list item height (آية: 72dp, وحي: 64dp)
  static double get listItemHeight => 72.h;
  
  /// List item with subtitle
  static double get listItemHeightLarge => 80.h;
  
  /// Bottom navigation height (without safe area)
  static double get bottomNavHeight => 64.h;
  
  /// App bar height (without status bar)
  static double get appBarHeight => 56.h;
  
  /// FAB size
  static double get fabSize => 56.w;
  
  /// Mini FAB size
  static double get fabSizeMini => 40.w;
  
  /// Hero card height (آية: 160dp, وحي: 180dp)
  static double get heroCardHeight => 160.h;
  
  /// Prayer time card height
  static double get prayerCardHeight => 72.h;
  
  /// Quick action button size
  static double get quickActionSize => 80.w;
  
  /// Hijri date card height
  static double get hijriCardHeight => 120.h;
  
  /// Button height (آية: 52dp, وحي: 48dp)
  static double get buttonHeight => 52.h;
  
  // ═══════════════════════════════════════════
  // ICON SIZES
  // ═══════════════════════════════════════════
  
  /// Navigation icons (آية: 24sp, وحي: 24sp)
  static double get iconNav => 24.sp;
  
  /// Inline icons (آية: 22sp, وحي: 20sp)
  static double get iconInline => 22.sp;
  
  /// Small icons
  static double get iconSmall => 16.sp;
  
  /// Large icons (hero card)
  static double get iconLarge => 32.sp;
  
  /// Extra large icons (quick actions)
  static double get iconXLarge => 28.sp;
  
  // ═══════════════════════════════════════════
  // BORDER RADIUS (من آية - أكبر وأنعم)
  // ═══════════════════════════════════════════
  
  /// Small radius (آية: 10dp, وحي: 8dp)
  static double get radiusSmall => 10.r;
  
  /// Medium radius (آية: 14dp, وحي: 12dp)
  static double get radiusMedium => 14.r;
  
  /// Large radius (آية: 18dp, وحي: 16dp)
  static double get radiusLarge => 18.r;
  
  /// Extra large radius (آية: 24dp, وحي: 20dp)
  static double get radiusXLarge => 24.r;
  
  /// Pill radius
  static double get radiusPill => 999.r;
  
  /// Circle radius
  static double get radiusCircle => 999.r;
  
  // ═══════════════════════════════════════════
  // BORDER WIDTH (من آية - أوضح)
  // ═══════════════════════════════════════════
  
  /// Subtle border
  static double get borderThin => 0.5;
  
  /// Standard border (آية: 1.5, وحي: 1.0)
  static double get borderStandard => 1.5;
  
  /// Thick border (focus state)
  static double get borderThick => 2.0;
  
  /// Extra thick border
  static double get borderXThick => 2.5;
  
  // ═══════════════════════════════════════════
  // TOUCH TARGETS (من آية - أكبر للـ accessibility)
  // ═══════════════════════════════════════════
  
  /// Minimum touch target (آية: 44dp, وحي: 40dp)
  static double get touchTargetMin => 44.w;
  
  /// Standard touch target
  static double get touchTarget => 48.w;
  
  /// Large touch target
  static double get touchTargetLarge => 56.w;
  
  // ═══════════════════════════════════════════
  // ELEVATION & SHADOWS (minimal - Wahy style)
  // ═══════════════════════════════════════════
  
  /// No elevation
  static double get elevationNone => 0;
  
  /// Subtle elevation
  static double get elevationSubtle => 1;
  
  /// Standard elevation
  static double get elevationStandard => 2;
  
  /// High elevation
  static double get elevationHigh => 4;
  
  /// Very high elevation
  static double get elevationVeryHigh => 8;
  
  // ═══════════════════════════════════════════
  // BLUR EFFECTS (minimal - Wahy style)
  // ═══════════════════════════════════════════
  
  /// Subtle blur (app bar)
  static double get blurSubtle => 10;
  
  /// Standard blur (bottom sheet)
  static double get blurStandard => 15;
  
  /// Strong blur (modal overlay)
  static double get blurStrong => 20;
  
  // ═══════════════════════════════════════════
  // OPACITY VALUES
  // ═══════════════════════════════════════════
  
  /// Disabled state
  static double get opacityDisabled => 0.38;
  
  /// Subtle background
  static double get opacitySubtle => 0.05;
  
  /// Light background
  static double get opacityLight => 0.10;
  
  /// Medium background
  static double get opacityMedium => 0.15;
  
  /// Strong background
  static double get opacityStrong => 0.20;
  
  /// App bar background
  static double get opacityAppBar => 0.90;
  
  /// Overlay
  static double get opacityOverlay => 0.60;
  
  // ═══════════════════════════════════════════
  // DECORATIVE ELEMENTS
  // ═══════════════════════════════════════════
  
  /// Bismillah header height
  static double get bismillahHeight => 48.h;
  
  /// Prayer number decoration size (آية: 44dp, وحي: 40dp)
  static double get prayerNumberSize => 44.w;
  
  /// Divider thickness
  static double get dividerThickness => 0.5;
  
  /// Drag handle width (آية: 48dp, وحي: 40dp)
  static double get dragHandleWidth => 48.w;
  
  /// Drag handle height (آية: 5dp, وحي: 4dp)
  static double get dragHandleHeight => 5.h;
  
  /// Drag handle top spacing
  static double get dragHandleTop => 12.h;
  
  // ═══════════════════════════════════════════
  // RESPONSIVE BREAKPOINTS
  // ═══════════════════════════════════════════
  
  /// Compact: phones portrait
  static const double breakpointCompact = 600;
  
  /// Medium: phones landscape, small tablets
  static const double breakpointMedium = 840;
  
  /// Expanded: tablets, large screens
  static const double breakpointExpanded = 1200;
  
  // ═══════════════════════════════════════════
  // ANIMATION DURATIONS (milliseconds)
  // ═══════════════════════════════════════════
  
  /// Instant feedback
  static const int durationInstant = 100;
  
  /// Fast animation
  static const int durationFast = 200;
  
  /// Normal animation (آية: 300ms, وحي: 300ms)
  static const int durationNormal = 300;
  
  /// Slow animation
  static const int durationSlow = 400;
  
  /// Deliberate animation (آية: 500ms, وحي: 600ms)
  static const int durationDeliberate = 500;
  
  /// Stagger delay between list items
  static const int durationStagger = 30;
  
  /// Max items to animate in list
  static const int maxAnimatedItems = 10;
}
