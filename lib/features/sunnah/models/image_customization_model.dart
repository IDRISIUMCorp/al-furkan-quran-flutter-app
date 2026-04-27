import 'package:flutter/material.dart';

/// 🎨 موديل إعدادات تخصيص الصورة
class ImageCustomizationSettings {
  // ═══════════════════════════════════════════
  // BACKGROUND SETTINGS
  // ═══════════════════════════════════════════
  BackgroundType backgroundType;
  Color backgroundColor;
  Color gradientStartColor;
  Color gradientEndColor;
  GradientDirection gradientDirection;
  PatternType patternType;
  double patternOpacity;
  
  // ═══════════════════════════════════════════
  // LAYOUT SETTINGS
  // ═══════════════════════════════════════════
  LayoutStyle layoutStyle;
  double cardPadding;
  double cardRadius;
  bool showBorder;
  Color borderColor;
  double borderWidth;
  bool showShadow;
  double shadowBlur;
  
  // ═══════════════════════════════════════════
  // TEXT SETTINGS
  // ═══════════════════════════════════════════
  String fontFamily;
  double titleFontSize;
  double descriptionFontSize;
  double evidenceFontSize;
  Color titleColor;
  Color descriptionColor;
  Color evidenceColor;
  TextAlign textAlign;
  double lineHeight;
  
  // ═══════════════════════════════════════════
  // HEADER SETTINGS
  // ═══════════════════════════════════════════
  bool showHeader;
  HeaderStyle headerStyle;
  Color headerColor;
  bool showIcon;
  IconStyle iconStyle;
  
  // ═══════════════════════════════════════════
  // BADGE SETTINGS
  // ═══════════════════════════════════════════
  bool showBadge;
  BadgeStyle badgeStyle;
  Color badgeColor;
  
  // ═══════════════════════════════════════════
  // FOOTER SETTINGS
  // ═══════════════════════════════════════════
  bool showFooter;
  String footerText;
  Color footerColor;
  double footerFontSize;
  
  // ═══════════════════════════════════════════
  // DECORATIVE ELEMENTS
  // ═══════════════════════════════════════════
  bool showTopDecoration;
  bool showBottomDecoration;
  DecorationType decorationType;
  Color decorationColor;
  
  // ═══════════════════════════════════════════
  // IMAGE SETTINGS
  // ═══════════════════════════════════════════
  ImageSize imageSize;
  ImageQuality imageQuality;
  
  ImageCustomizationSettings({
    // Background defaults
    this.backgroundType = BackgroundType.solid,
    this.backgroundColor = const Color(0xFFF8F6ED),
    this.gradientStartColor = const Color(0xFF4A7C59),
    this.gradientEndColor = const Color(0xFFC9A84C),
    this.gradientDirection = GradientDirection.topToBottom,
    this.patternType = PatternType.geometric,
    this.patternOpacity = 0.05,
    
    // Layout defaults
    this.layoutStyle = LayoutStyle.modern,
    this.cardPadding = 24.0,
    this.cardRadius = 20.0,
    this.showBorder = true,
    this.borderColor = const Color(0xFFDDD9CC),
    this.borderWidth = 2.0,
    this.showShadow = true,
    this.shadowBlur = 20.0,
    
    // Text defaults
    this.fontFamily = 'Cairo',
    this.titleFontSize = 32.0,
    this.descriptionFontSize = 20.0,
    this.evidenceFontSize = 16.0,
    this.titleColor = const Color(0xFF2C2C2C),
    this.descriptionColor = const Color(0xFF6B6B6B),
    this.evidenceColor = const Color(0xFF4A7C59),
    this.textAlign = TextAlign.right,
    this.lineHeight = 1.8,
    
    // Header defaults
    this.showHeader = true,
    this.headerStyle = HeaderStyle.gradient,
    this.headerColor = const Color(0xFF4A7C59),
    this.showIcon = true,
    this.iconStyle = IconStyle.filled,
    
    // Badge defaults
    this.showBadge = true,
    this.badgeStyle = BadgeStyle.rounded,
    this.badgeColor = const Color(0xFFC9A84C),
    
    // Footer defaults
    this.showFooter = true,
    this.footerText = 'تطبيق الفرقان للقرآن الكريم',
    this.footerColor = const Color(0xFF9B9B9B),
    this.footerFontSize = 14.0,
    
    // Decorative defaults
    this.showTopDecoration = true,
    this.showBottomDecoration = true,
    this.decorationType = DecorationType.islamic,
    this.decorationColor = const Color(0xFF4A7C59),
    
    // Image defaults - مربع بشكل افتراضي
    this.imageSize = ImageSize.square1080,
    this.imageQuality = ImageQuality.high,
  });
  
  ImageCustomizationSettings copyWith({
    BackgroundType? backgroundType,
    Color? backgroundColor,
    Color? gradientStartColor,
    Color? gradientEndColor,
    GradientDirection? gradientDirection,
    PatternType? patternType,
    double? patternOpacity,
    LayoutStyle? layoutStyle,
    double? cardPadding,
    double? cardRadius,
    bool? showBorder,
    Color? borderColor,
    double? borderWidth,
    bool? showShadow,
    double? shadowBlur,
    String? fontFamily,
    double? titleFontSize,
    double? descriptionFontSize,
    double? evidenceFontSize,
    Color? titleColor,
    Color? descriptionColor,
    Color? evidenceColor,
    TextAlign? textAlign,
    double? lineHeight,
    bool? showHeader,
    HeaderStyle? headerStyle,
    Color? headerColor,
    bool? showIcon,
    IconStyle? iconStyle,
    bool? showBadge,
    BadgeStyle? badgeStyle,
    Color? badgeColor,
    bool? showFooter,
    String? footerText,
    Color? footerColor,
    double? footerFontSize,
    bool? showTopDecoration,
    bool? showBottomDecoration,
    DecorationType? decorationType,
    Color? decorationColor,
    ImageSize? imageSize,
    ImageQuality? imageQuality,
  }) {
    return ImageCustomizationSettings(
      backgroundType: backgroundType ?? this.backgroundType,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      gradientStartColor: gradientStartColor ?? this.gradientStartColor,
      gradientEndColor: gradientEndColor ?? this.gradientEndColor,
      gradientDirection: gradientDirection ?? this.gradientDirection,
      patternType: patternType ?? this.patternType,
      patternOpacity: patternOpacity ?? this.patternOpacity,
      layoutStyle: layoutStyle ?? this.layoutStyle,
      cardPadding: cardPadding ?? this.cardPadding,
      cardRadius: cardRadius ?? this.cardRadius,
      showBorder: showBorder ?? this.showBorder,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      showShadow: showShadow ?? this.showShadow,
      shadowBlur: shadowBlur ?? this.shadowBlur,
      fontFamily: fontFamily ?? this.fontFamily,
      titleFontSize: titleFontSize ?? this.titleFontSize,
      descriptionFontSize: descriptionFontSize ?? this.descriptionFontSize,
      evidenceFontSize: evidenceFontSize ?? this.evidenceFontSize,
      titleColor: titleColor ?? this.titleColor,
      descriptionColor: descriptionColor ?? this.descriptionColor,
      evidenceColor: evidenceColor ?? this.evidenceColor,
      textAlign: textAlign ?? this.textAlign,
      lineHeight: lineHeight ?? this.lineHeight,
      showHeader: showHeader ?? this.showHeader,
      headerStyle: headerStyle ?? this.headerStyle,
      headerColor: headerColor ?? this.headerColor,
      showIcon: showIcon ?? this.showIcon,
      iconStyle: iconStyle ?? this.iconStyle,
      showBadge: showBadge ?? this.showBadge,
      badgeStyle: badgeStyle ?? this.badgeStyle,
      badgeColor: badgeColor ?? this.badgeColor,
      showFooter: showFooter ?? this.showFooter,
      footerText: footerText ?? this.footerText,
      footerColor: footerColor ?? this.footerColor,
      footerFontSize: footerFontSize ?? this.footerFontSize,
      showTopDecoration: showTopDecoration ?? this.showTopDecoration,
      showBottomDecoration: showBottomDecoration ?? this.showBottomDecoration,
      decorationType: decorationType ?? this.decorationType,
      decorationColor: decorationColor ?? this.decorationColor,
      imageSize: imageSize ?? this.imageSize,
      imageQuality: imageQuality ?? this.imageQuality,
    );
  }
}

// ═══════════════════════════════════════════
// ENUMS
// ═══════════════════════════════════════════

enum BackgroundType {
  solid,
  gradient,
  pattern,
  image,
}

enum GradientDirection {
  topToBottom,
  bottomToTop,
  leftToRight,
  rightToLeft,
  diagonal,
  radial,
}

enum PatternType {
  none,
  geometric,
  islamic,
  dots,
  lines,
  waves,
}

enum LayoutStyle {
  modern,
  classic,
  minimal,
  elegant,
  bold,
  card,
}

enum HeaderStyle {
  simple,
  gradient,
  outlined,
  filled,
}

enum IconStyle {
  filled,
  outlined,
  gradient,
  none,
}

enum BadgeStyle {
  rounded,
  square,
  pill,
  minimal,
}

enum DecorationType {
  none,
  islamic,
  floral,
  geometric,
  simple,
}

enum ImageSize {
  square1080,      // 1080x1080 (Instagram Square)
  instagram,       // 1080x1920 (Instagram Story)
  facebook,        // 1200x630 (Facebook Post)
  twitter,         // 1200x675 (Twitter Post)
  square800,       // 800x800 (صغير)
  square1200,      // 1200x1200 (كبير)
  custom,
}

enum ImageQuality {
  low,
  medium,
  high,
  ultra,
}

// ═══════════════════════════════════════════
// EXTENSIONS
// ═══════════════════════════════════════════

extension ImageSizeExtension on ImageSize {
  // Custom size storage — updated when user enters custom dimensions
  static Size _customSize = const Size(1080, 1080);

  /// Save custom dimensions entered by the user
  static void setCustomSize(double width, double height) {
    _customSize = Size(
      width.clamp(100, 4096),
      height.clamp(100, 4096),
    );
  }

  /// Get the current custom size
  static Size get customSize => _customSize;

  Size get dimensions {
    switch (this) {
      case ImageSize.square1080:
        return const Size(1080, 1080);
      case ImageSize.square800:
        return const Size(800, 800);
      case ImageSize.square1200:
        return const Size(1200, 1200);
      case ImageSize.instagram:
        return const Size(1080, 1920);
      case ImageSize.facebook:
        return const Size(1200, 630);
      case ImageSize.twitter:
        return const Size(1200, 675);
      case ImageSize.custom:
        return _customSize;
    }
  }
  
  String get label {
    switch (this) {
      case ImageSize.square1080:
        return 'مربع متوسط (1080×1080)';
      case ImageSize.square800:
        return 'مربع صغير (800×800)';
      case ImageSize.square1200:
        return 'مربع كبير (1200×1200)';
      case ImageSize.instagram:
        return 'إنستجرام (1080×1920)';
      case ImageSize.facebook:
        return 'فيسبوك (1200×630)';
      case ImageSize.twitter:
        return 'تويتر (1200×675)';
      case ImageSize.custom:
        final s = _customSize;
        return 'مخصص (${s.width.toInt()}×${s.height.toInt()})';
    }
  }
  
  /// حساب scale factor للنصوص بناءً على حجم الصورة
  double get scaleFactor {
    final width = dimensions.width;
    final height = dimensions.height;
    
    // حساب scale بناءً على المساحة الكلية
    // 1080x1080 = 1,166,400 هو الحجم المرجعي
    final referenceArea = 1080.0 * 1080.0;
    final currentArea = width * height;
    final areaScale = currentArea / referenceArea;
    
    // استخدام الجذر التربيعي للحصول على scale متوازن
    return areaScale.clamp(0.5, 2.0);
  }
}

extension BackgroundTypeExtension on BackgroundType {
  String get label {
    switch (this) {
      case BackgroundType.solid:
        return 'لون واحد';
      case BackgroundType.gradient:
        return 'تدرج لوني';
      case BackgroundType.pattern:
        return 'نمط';
      case BackgroundType.image:
        return 'صورة';
    }
  }
}

extension LayoutStyleExtension on LayoutStyle {
  String get label {
    switch (this) {
      case LayoutStyle.modern:
        return 'عصري';
      case LayoutStyle.classic:
        return 'كلاسيكي';
      case LayoutStyle.minimal:
        return 'بسيط';
      case LayoutStyle.elegant:
        return 'أنيق';
      case LayoutStyle.bold:
        return 'جريء';
      case LayoutStyle.card:
        return 'بطاقة';
    }
  }
}
