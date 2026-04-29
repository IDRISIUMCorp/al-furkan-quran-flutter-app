import 'package:flutter/material.dart';

/// Comprehensive theme configuration for QCF Quran widgets.
///
/// This class allows developers to customize every visual aspect of the Quran
/// rendering, including colors, spacing, backgrounds, and component visibility.
///
/// Example:
/// ```dart
/// final darkTheme = QcfThemeData(
///   verseTextColor: Colors.white,
///   verseNumberColor: Colors.amber,
///   pageBackgroundColor: Colors.black87,
///   basmalaColor: Colors.white70,
/// );
///
/// PageviewQuran(
///   theme: darkTheme,
///   initialPageNumber: 1,
/// )
/// ```
class QcfThemeData {
  // ============ Text Colors ============

  /// Color for verse text (Arabic Quran text).
  /// Default: `Color(0xFF000000)` (black)
  final Color verseTextColor;

  /// Color for verse number symbols.
  /// Default: `Color(0xFF8B4513)` (brown)
  final Color verseNumberColor;

  /// Color for Basmala text.
  /// Default: `Colors.black`
  final Color basmalaColor;

  /// Color for surah header text.
  /// Default: `Colors.black`
  final Color headerTextColor;

  // ============ Background Colors ============

  /// Background color for the entire page.
  /// Default: `Color(0xFFFFFFFF)` (white)
  final Color pageBackgroundColor;

  /// Optional callback to provide background color for individual verses.
  /// Useful for highlighting selected verses or search results.
  ///
  /// Returns a Color for the verse, or null for no background.
  ///
  /// Example:
  /// ```dart
  /// verseBackgroundColor: (surah, verse) {
  ///   if (surah == 2 && verse == 255) return Colors.yellow.shade100;
  ///   return null;
  /// }
  /// ```
  final Color? Function(int surahNumber, int verseNumber)? verseBackgroundColor;

  /// Background color for verse number symbols.
  /// Default: `null` (transparent)
  final Color? verseNumberBackgroundColor;

  /// Background color for surah headers.
  /// Default: `null` (transparent)
  final Color? headerBackgroundColor;

  // ============ Spacing & Layout ============

  /// Horizontal padding for page content.
  /// Default: `12.0`
  final double horizontalPadding;

  /// Vertical padding for page content.
  /// Default: `12.0`
  final double verticalPadding;

  /// Height multiplier for verse text lines.
  /// Lower values = tighter line spacing, higher values = looser spacing.
  /// Default: `2.2`
  final double verseHeight;

  /// Height multiplier for verse number symbols.
  /// Default: `1.35`
  final double verseNumberHeight;

  /// Uniform scaling applied to the rendered mushaf block.
  /// Values greater than `1.0` make the page feel larger in both width and
  /// height after fitting, while lower values make it denser.
  final double contentScale;

  /// Letter spacing for verse text.
  /// Default: `0.0`
  final double letterSpacing;

  /// Word spacing for verse text.
  /// Default: `0.0`
  final double wordSpacing;

  // ============ Typography ============

  /// Override font size for verse text.
  /// If null, uses automatic per-page sizing.
  /// Default: `null`
  final double? fontSize;

  /// Font size for Basmala on large screens.
  /// Default: `13.2`
  final double basmalaFontSizeLarge;

  /// Font size for Basmala on small screens.
  /// Default: `24.0`
  final double basmalaFontSizeSmall;

  /// Font size for special Basmala (Surahs 95, 97) on large screens.
  /// Default: `13.2`
  final double basmalaSpecialFontSizeLarge;

  /// Font size for special Basmala (Surahs 95, 97) on small screens.
  /// Default: `18.0`
  final double basmalaSpecialFontSizeSmall;

  /// Font size for header text on large screens.
  /// Default: `16.0`
  final double headerFontSizeLarge;

  /// Font size for header text on small screens.
  /// Default: `29.0`
  final double headerFontSizeSmall;

  // ============ Component Visibility ============

  /// Whether to show the Basmala at the beginning of surahs.
  /// Default: `true`
  final bool showBasmala;

  /// Whether to show surah headers.
  /// Default: `true`
  final bool showHeader;

  /// Whether to show the ۩ sajda indicator after sajda verse numbers.
  /// Default: `true`
  final bool showSajdaIndicator;

  /// Color for the ۩ sajda indicator symbol.
  /// Default: `Color(0xFFAB47BC)` (purple)
  final Color sajdaIndicatorColor;

  // ============ Classic Border Design (Traditional Mushaf) ============

  /// Whether to use classic Islamic border design with decorative frame.
  /// Default: `false`
  final bool useClassicBorder;

  /// Color of the outer border frame.
  /// Default: `Color(0xFF5D4037)` (dark brown)
  final Color borderColor;

  /// Width of the outer border.
  /// Default: `2.0`
  final double borderWidth;

  /// Color of decorative Islamic ornaments in corners.
  /// Default: `Color(0xFF8D6E63)` (golden brown)
  final Color ornamentColor;

  /// Background color for the mushaf page (classic cream/beige).
  /// Default: `Color(0xFFF5F0E8)` (warm cream)
  final Color classicPageBackground;

  /// Background color for header/footer areas.
  /// Default: `Color(0xFFEDE4D4)` (light beige)
  final Color headerFooterBackground;

  // ============ Header Customization ============

  /// Width of header image on large screens.
  /// Default: `250.0`
  final double headerWidthLarge;

  /// Width of header image on small screens.
  /// Default: `372.0`
  final double headerWidthSmall;

  /// Custom widget builder for surah headers.
  /// If provided, this completely replaces the default header.
  ///
  /// Example:
  /// ```dart
  /// customHeaderBuilder: (surahNumber) {
  ///   return Container(
  ///     padding: EdgeInsets.all(16),
  ///     child: Text('Surah $surahNumber'),
  ///   );
  /// }
  /// ```
  final Widget Function(int surahNumber)? customHeaderBuilder;

  /// Border radius for header container.
  /// Default: `8.0`
  final double headerBorderRadius;

  final double headerScale;

  /// Scale factor for surah name text size in the header.
  /// Default: `1.0`
  final double surahNameScale;

  final Widget Function(int pageNumber, int surahNumber, int startVerse)?
  pageTopOverlayBuilder;

  final Widget Function(int pageNumber, int surahNumber, int startVerse)?
  pageBottomOverlayBuilder;

  final double firstPagesTopSpacerFactor;

  const QcfThemeData({
    // Text Colors
    this.verseTextColor = const Color(0xFF000000),
    this.verseNumberColor = const Color(0xFF8B4513), // brown
    this.basmalaColor = Colors.black,
    this.headerTextColor = Colors.black,

    // Background Colors
    this.pageBackgroundColor = const Color(0xFFFFFFFF),
    this.verseBackgroundColor,
    this.verseNumberBackgroundColor,
    this.headerBackgroundColor,

    // Spacing & Layout
    this.horizontalPadding = 12.0,
    this.verticalPadding = 12.0,
    this.verseHeight = 2.2,
    this.verseNumberHeight = 1.35,
    this.contentScale = 1.0,
    this.letterSpacing = 0.0,
    this.wordSpacing = 0.0,

    // Typography
    this.fontSize,
    this.basmalaFontSizeLarge = 13.2,
    this.basmalaFontSizeSmall = 24.0,
    this.basmalaSpecialFontSizeLarge = 13.2,
    this.basmalaSpecialFontSizeSmall = 18.0,
    this.headerFontSizeLarge = 16.0,
    this.headerFontSizeSmall = 29.0,

    // Component Visibility
    this.showBasmala = true,
    this.showHeader = true,
    this.showSajdaIndicator = true,
    this.sajdaIndicatorColor = const Color(0xFFAB47BC),

    // Classic Border Design
    this.useClassicBorder = false,
    this.borderColor = const Color(0xFF5D4037),
    this.borderWidth = 2.0,
    this.ornamentColor = const Color(0xFF8D6E63),
    this.classicPageBackground = const Color(0xFFF5F0E8),
    this.headerFooterBackground = const Color(0xFFEDE4D4),

    // Header Customization
    this.headerWidthLarge = 250.0,
    this.headerWidthSmall = 372.0,
    this.customHeaderBuilder,
    this.headerBorderRadius = 8.0,
    this.headerScale = 1.0,
    this.surahNameScale = 0.9,
    this.pageTopOverlayBuilder,
    this.pageBottomOverlayBuilder,
    this.firstPagesTopSpacerFactor = 0.0,
    this.basmalaBuilder,
    this.verseNumberBuilder,
  });

  /// Creates a copy of this theme with the given fields replaced.
  QcfThemeData copyWith({
    Color? verseTextColor,
    Color? verseNumberColor,
    Color? basmalaColor,
    Color? headerTextColor,
    Color? pageBackgroundColor,
    Color? Function(int surahNumber, int verseNumber)? verseBackgroundColor,
    Color? verseNumberBackgroundColor,
    Color? headerBackgroundColor,
    double? horizontalPadding,
    double? verticalPadding,
    double? verseHeight,
    double? verseNumberHeight,
    double? contentScale,
    double? letterSpacing,
    double? wordSpacing,
    double? fontSize,
    double? basmalaFontSizeLarge,
    double? basmalaFontSizeSmall,
    double? basmalaSpecialFontSizeLarge,
    double? basmalaSpecialFontSizeSmall,
    double? headerFontSizeLarge,
    double? headerFontSizeSmall,
    bool? showBasmala,
    bool? showHeader,
    bool? showSajdaIndicator,
    Color? sajdaIndicatorColor,
    bool? useClassicBorder,
    Color? borderColor,
    double? borderWidth,
    Color? ornamentColor,
    Color? classicPageBackground,
    Color? headerFooterBackground,
    double? headerWidthLarge,
    double? headerWidthSmall,
    Widget Function(int surahNumber)? customHeaderBuilder,
    double? headerBorderRadius,
    double? headerScale,
    double? surahNameScale,
    Widget Function(int pageNumber, int surahNumber, int startVerse)?
    pageTopOverlayBuilder,
    Widget Function(int pageNumber, int surahNumber, int startVerse)?
    pageBottomOverlayBuilder,
    double? firstPagesTopSpacerFactor,
    Widget Function(int surahNumber)? basmalaBuilder,
    InlineSpan Function(int surah, int verse, String verseNumber)?
    verseNumberBuilder,
  }) {
    return QcfThemeData(
      verseTextColor: verseTextColor ?? this.verseTextColor,
      verseNumberColor: verseNumberColor ?? this.verseNumberColor,
      basmalaColor: basmalaColor ?? this.basmalaColor,
      headerTextColor: headerTextColor ?? this.headerTextColor,
      pageBackgroundColor: pageBackgroundColor ?? this.pageBackgroundColor,
      verseBackgroundColor: verseBackgroundColor ?? this.verseBackgroundColor,
      verseNumberBackgroundColor:
          verseNumberBackgroundColor ?? this.verseNumberBackgroundColor,
      headerBackgroundColor:
          headerBackgroundColor ?? this.headerBackgroundColor,
      horizontalPadding: horizontalPadding ?? this.horizontalPadding,
      verticalPadding: verticalPadding ?? this.verticalPadding,
      verseHeight: verseHeight ?? this.verseHeight,
      verseNumberHeight: verseNumberHeight ?? this.verseNumberHeight,
      contentScale: contentScale ?? this.contentScale,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      wordSpacing: wordSpacing ?? this.wordSpacing,
      fontSize: fontSize ?? this.fontSize,
      basmalaFontSizeLarge: basmalaFontSizeLarge ?? this.basmalaFontSizeLarge,
      basmalaFontSizeSmall: basmalaFontSizeSmall ?? this.basmalaFontSizeSmall,
      basmalaSpecialFontSizeLarge:
          basmalaSpecialFontSizeLarge ?? this.basmalaSpecialFontSizeLarge,
      basmalaSpecialFontSizeSmall:
          basmalaSpecialFontSizeSmall ?? this.basmalaSpecialFontSizeSmall,
      headerFontSizeLarge: headerFontSizeLarge ?? this.headerFontSizeLarge,
      headerFontSizeSmall: headerFontSizeSmall ?? this.headerFontSizeSmall,
      showBasmala: showBasmala ?? this.showBasmala,
      showHeader: showHeader ?? this.showHeader,
      showSajdaIndicator: showSajdaIndicator ?? this.showSajdaIndicator,
      sajdaIndicatorColor: sajdaIndicatorColor ?? this.sajdaIndicatorColor,
      useClassicBorder: useClassicBorder ?? this.useClassicBorder,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      ornamentColor: ornamentColor ?? this.ornamentColor,
      classicPageBackground: classicPageBackground ?? this.classicPageBackground,
      headerFooterBackground: headerFooterBackground ?? this.headerFooterBackground,
      headerWidthLarge: headerWidthLarge ?? this.headerWidthLarge,
      headerWidthSmall: headerWidthSmall ?? this.headerWidthSmall,
      customHeaderBuilder: customHeaderBuilder ?? this.customHeaderBuilder,
      headerBorderRadius: headerBorderRadius ?? this.headerBorderRadius,
      headerScale: headerScale ?? this.headerScale,
      surahNameScale: surahNameScale ?? this.surahNameScale,
      pageTopOverlayBuilder:
          pageTopOverlayBuilder ?? this.pageTopOverlayBuilder,
      pageBottomOverlayBuilder:
          pageBottomOverlayBuilder ?? this.pageBottomOverlayBuilder,
      firstPagesTopSpacerFactor:
          firstPagesTopSpacerFactor ?? this.firstPagesTopSpacerFactor,
      basmalaBuilder: basmalaBuilder ?? this.basmalaBuilder,
      verseNumberBuilder: verseNumberBuilder ?? this.verseNumberBuilder,
    );
  }

  /// Custom builder for Basmala.
  /// If provided, replaces the default Basmala text/image.
  final Widget Function(int surahNumber)? basmalaBuilder;

  /// Custom builder for verse numbers.
  /// If provided, replaces the default verse number text style.
  /// Must return an [InlineSpan] because it's rendered inside a Text.rich.
  final InlineSpan Function(int surah, int verse, String verseNumber)?
  verseNumberBuilder;
  factory QcfThemeData.dark() {
    return const QcfThemeData(
      verseTextColor: Color(0xFFE0E0E0),
      verseNumberColor: Color(0xFFFFB74D), // amber
      basmalaColor: Color(0xFFE0E0E0),
      headerTextColor: Color(0xFFE0E0E0), // Fixed: was black, now white
      pageBackgroundColor: Color(0xFF000000), // Changed to pure OLED black
    );
  }

  /// Creates a sepia/vintage theme preset.
  factory QcfThemeData.sepia() {
    return const QcfThemeData(
      verseTextColor: Color(0xFF3E2723),
      verseNumberColor: Color(0xFF6D4C41),
      basmalaColor: Color(0xFF3E2723),
      headerTextColor: Color(0xFF3E2723),
      pageBackgroundColor: Color(0xFFF5E6D3),
    );
  }

  /// Pure OLED black theme for AMOLED screens.
  /// Uses true black (#000000) to save battery and reduce eye strain at night.
  factory QcfThemeData.oled() {
    return const QcfThemeData(
      verseTextColor: Color(0xFFE0E0E0), // Brighter for better contrast
      verseNumberColor: Color(0xFFFFCC80),
      basmalaColor: Color(0xFFE0E0E0), // Brighter
      headerTextColor: Color(0xFFE0E0E0), // Brighter
      pageBackgroundColor: Color(0xFF000000), // True black
    );
  }

  /// Night-blue theme designed to reduce blue-light strain.
  /// Dark navy background with warm-tinted text for late-night reading.
  factory QcfThemeData.nightBlue() {
    return const QcfThemeData(
      verseTextColor: Color(0xFFCFD8DC),
      verseNumberColor: Color(0xFF80CBC4),
      basmalaColor: Color(0xFFCFD8DC),
      headerTextColor: Color(0xFFCFD8DC),
      pageBackgroundColor: Color(0xFF0F172A), // Deep Navy Blue
    );
  }

  /// Warm cream theme for comfortable daytime reading.
  /// Soft off-white background that's easier on the eyes than pure white.
  factory QcfThemeData.cream() {
    return const QcfThemeData(
      verseTextColor: Color(0xFF2E2E2E),
      verseNumberColor: Color(0xFF795548),
      basmalaColor: Color(0xFF424242),
      headerTextColor: Color(0xFF424242),
      pageBackgroundColor: Color(0xFFFFF8E7), // Warm cream
    );
  }

  factory QcfThemeData.graphite() {
    return const QcfThemeData(
      verseTextColor: Color(0xFFE6E6E6),
      verseNumberColor: Color(0xFF90CAF9),
      basmalaColor: Color(0xFFE6E6E6),
      headerTextColor: Color(0xFFE6E6E6),
      pageBackgroundColor: Color(0xFF212529), // Graphite Dark Grey
    );
  }

  factory QcfThemeData.midnightPurple() {
    return const QcfThemeData(
      verseTextColor: Color(0xFFEDE7F6),
      verseNumberColor: Color(0xFFB39DDB),
      basmalaColor: Color(0xFFEDE7F6),
      headerTextColor: Color(0xFFEDE7F6),
      pageBackgroundColor: Color(0xFF1E1B2A), // Midnight Purple
    );
  }

  factory QcfThemeData.paperWhite() {
    return const QcfThemeData(
      verseTextColor: Color(0xFF1F1F1F),
      verseNumberColor: Color(0xFF5D4037),
      basmalaColor: Color(0xFF1F1F1F),
      headerTextColor: Color(0xFF1F1F1F),
      pageBackgroundColor: Color(0xFFFFFFFF),
    );
  }

  factory QcfThemeData.sand() {
    return const QcfThemeData(
      verseTextColor: Color(0xFF2B2620),
      verseNumberColor: Color(0xFF6D4C41),
      basmalaColor: Color(0xFF2B2620),
      headerTextColor: Color(0xFF2B2620),
      pageBackgroundColor: Color(0xFFF3E7D3),
    );
  }

  /// Ayah-inspired light theme — warm white with navy-warm text.
  /// Matches the 'Ayah' Quran app aesthetic with soft beige undertones.
  factory QcfThemeData.ayah() {
    return const QcfThemeData(
      verseTextColor: Color(0xFF1C1C28),
      verseNumberColor: Color(0xFF6D4C41),
      basmalaColor: Color(0xFF1C1C28),
      headerTextColor: Color(0xFF1C1C28),
      pageBackgroundColor: Color(0xFFFAF8F5),
    );
  }

  /// Warm beige theme — soft beige background with dark text.
  factory QcfThemeData.beige() {
    return const QcfThemeData(
      verseTextColor: Color(0xFF2A2A35),
      verseNumberColor: Color(0xFF6D4C41),
      basmalaColor: Color(0xFF2A2A35),
      headerTextColor: Color(0xFF2A2A35),
      pageBackgroundColor: Color(0xFFF0EBE3),
    );
  }

  /// Dark beige theme — deeper beige/brown background for warmer reading.
  factory QcfThemeData.darkBeige() {
    return const QcfThemeData(
      verseTextColor: Color(0xFF1A1A22),
      verseNumberColor: Color(0xFF5D4037),
      basmalaColor: Color(0xFF1A1A22),
      headerTextColor: Color(0xFF1A1A22),
      pageBackgroundColor: Color(0xFFE0D5C5),
    );
  }

  /// Dark cream theme — rich cream/taupe background for cozy reading.
  factory QcfThemeData.creamDark() {
    return const QcfThemeData(
      verseTextColor: Color(0xFF151515),
      verseNumberColor: Color(0xFF5D4037),
      basmalaColor: Color(0xFF151515),
      headerTextColor: Color(0xFF151515),
      pageBackgroundColor: Color(0xFFD4C4A8),
    );
  }

  /// Charcoal dark theme — matches the app's "Quiet Luxury" Charcoal aesthetic.
  /// Deep slate background with warm-toned accents for elegant dark reading.
  factory QcfThemeData.charcoal() {
    return const QcfThemeData(
      verseTextColor: Color(0xFFF8F9FA),
      verseNumberColor: Color(0xFFADB5BD),
      basmalaColor: Color(0xFFF8F9FA),
      headerTextColor: Color(0xFFF8F9FA),
      pageBackgroundColor: Color(0xFF212529), // Deep Charcoal
    );
  }
}
