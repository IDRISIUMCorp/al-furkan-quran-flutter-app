import 'dart:convert';
import 'package:flutter/material.dart';

/// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
/// AZKAR SHARE SETTINGS - State Class
/// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
/// ╪¬╪¼┘à┘è╪╣ ┘â┘ä ╪º┘ä╪Ñ╪╣╪»╪º╪»╪º╪¬ ┘ü┘è class ┘ê╪º╪¡╪»╪⌐ ╪¿╪»┘ä 30+ ┘à╪¬╪║┘è╪▒ ┘à╪¬┘ü╪▒┘é
/// ╪│┘ç┘ê┘ä╪⌐ ╪º┘ä┘Ç Undo/Redo ┘ê╪¡┘ü╪╕ ╪º┘ä╪¬┘ü╪╢┘è┘ä╪º╪¬
/// ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

/// ╪│╪¬╪º┘è┘ä ╪º┘ä╪╣┘å╪╡╪▒ ╪º┘ä┘ê╪º╪¡╪» (╪º┘ä╪░┘â╪▒╪î ╪º┘ä┘é╪│┘à╪î ╪º┘ä┘ê╪╡┘ü╪î ╪º┘ä┘à╪▒╪¼╪╣)
class ElementStyle {
  final Color? color;
  final String? font;
  final double? fontSize;
  final double? lineHeight;
  final String? styleId;

  const ElementStyle({
    this.color,
    this.font,
    this.fontSize,
    this.lineHeight,
    this.styleId,
  });

  ElementStyle copyWith({
    Color? color,
    String? font,
    double? fontSize,
    double? lineHeight,
    String? styleId,
    bool clearColor = false,
    bool clearFont = false,
    bool clearFontSize = false,
    bool clearLineHeight = false,
    bool clearStyleId = false,
  }) {
    return ElementStyle(
      color: clearColor ? null : (color ?? this.color),
      font: clearFont ? null : (font ?? this.font),
      fontSize: clearFontSize ? null : (fontSize ?? this.fontSize),
      lineHeight: clearLineHeight ? null : (lineHeight ?? this.lineHeight),
      styleId: clearStyleId ? 'classic' : (styleId ?? this.styleId),
    );
  }

  Map<String, dynamic> toJson() => {
    'color': color?.value,
    'font': font,
    'fontSize': fontSize,
    'lineHeight': lineHeight,
    'styleId': styleId,
  };

  factory ElementStyle.fromJson(Map<String, dynamic> json) {
    return ElementStyle(
      color: json['color'] != null ? Color(json['color']) : null,
      font: json['font'],
      fontSize: json['fontSize']?.toDouble(),
      lineHeight: json['lineHeight']?.toDouble(),
      styleId: json['styleId'],
    );
  }

  static const ElementStyle empty = ElementStyle();
}

/// ╪Ñ╪╣╪»╪º╪»╪º╪¬ ╪╡┘ê╪▒╪⌐ ╪º┘ä╪«┘ä┘ü┘è╪⌐
class ImageBackgroundSettings {
  final String? path;
  final Offset offset;
  final double scale;
  final double blur;
  final double overlayOpacity;

  const ImageBackgroundSettings({
    this.path,
    this.offset = Offset.zero,
    this.scale = 1.0,
    this.blur = 0.0,
    this.overlayOpacity = 0.0,
  });

  ImageBackgroundSettings copyWith({
    String? path,
    Offset? offset,
    double? scale,
    double? blur,
    double? overlayOpacity,
    bool clearPath = false,
  }) {
    return ImageBackgroundSettings(
      path: clearPath ? null : (path ?? this.path),
      offset: offset ?? this.offset,
      scale: scale ?? this.scale,
      blur: blur ?? this.blur,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
    );
  }

  Map<String, dynamic> toJson() => {
    'path': path,
    'offsetX': offset.dx,
    'offsetY': offset.dy,
    'scale': scale,
    'blur': blur,
    'overlayOpacity': overlayOpacity,
  };

  factory ImageBackgroundSettings.fromJson(Map<String, dynamic> json) {
    return ImageBackgroundSettings(
      path: json['path'],
      offset: Offset(
        json['offsetX']?.toDouble() ?? 0,
        json['offsetY']?.toDouble() ?? 0,
      ),
      scale: json['scale']?.toDouble() ?? 1.0,
      blur: json['blur']?.toDouble() ?? 0.0,
      overlayOpacity: json['overlayOpacity']?.toDouble() ?? 0.0,
    );
  }

  static const ImageBackgroundSettings empty = ImageBackgroundSettings();
}

/// ╪│╪¬╪º┘è┘ä ╪º┘ä┘Ç Text Effects (Shadow, Outline, Glow)
class TextEffects {
  final double shadowBlur;
  final Color shadowColor;
  final Offset shadowOffset;
  final double outlineWidth;
  final Color outlineColor;
  final bool enableGlow;

  const TextEffects({
    this.shadowBlur = 0,
    this.shadowColor = Colors.black,
    this.shadowOffset = Offset.zero,
    this.outlineWidth = 0,
    this.outlineColor = Colors.white,
    this.enableGlow = false,
  });

  TextEffects copyWith({
    double? shadowBlur,
    Color? shadowColor,
    Offset? shadowOffset,
    double? outlineWidth,
    Color? outlineColor,
    bool? enableGlow,
  }) {
    return TextEffects(
      shadowBlur: shadowBlur ?? this.shadowBlur,
      shadowColor: shadowColor ?? this.shadowColor,
      shadowOffset: shadowOffset ?? this.shadowOffset,
      outlineWidth: outlineWidth ?? this.outlineWidth,
      outlineColor: outlineColor ?? this.outlineColor,
      enableGlow: enableGlow ?? this.enableGlow,
    );
  }

  Map<String, dynamic> toJson() => {
    'shadowBlur': shadowBlur,
    'shadowColor': shadowColor.value,
    'shadowOffsetX': shadowOffset.dx,
    'shadowOffsetY': shadowOffset.dy,
    'outlineWidth': outlineWidth,
    'outlineColor': outlineColor.value,
    'enableGlow': enableGlow,
  };

  factory TextEffects.fromJson(Map<String, dynamic> json) {
    return TextEffects(
      shadowBlur: json['shadowBlur']?.toDouble() ?? 0,
      shadowColor: json['shadowColor'] != null 
          ? Color(json['shadowColor']) 
          : Colors.black,
      shadowOffset: Offset(
        json['shadowOffsetX']?.toDouble() ?? 0,
        json['shadowOffsetY']?.toDouble() ?? 0,
      ),
      outlineWidth: json['outlineWidth']?.toDouble() ?? 0,
      outlineColor: json['outlineColor'] != null 
          ? Color(json['outlineColor']) 
          : Colors.white,
      enableGlow: json['enableGlow'] ?? false,
    );
  }

  static const TextEffects empty = TextEffects();

  /// ╪¬╪╖╪¿┘è┘é ╪º┘ä╪¬╪ú╪½┘è╪▒╪º╪¬ ╪╣┘ä┘ë TextStyle
  TextStyle applyTo(TextStyle base) {
    if (shadowBlur == 0 && !enableGlow) return base;
    
    return base.copyWith(
      shadows: [
        if (shadowBlur > 0)
          Shadow(
            color: shadowColor,
            blurRadius: shadowBlur,
            offset: shadowOffset,
          ),
        if (enableGlow)
          Shadow(
            color: shadowColor.withValues(alpha: 0.5),
            blurRadius: shadowBlur * 2,
            offset: Offset.zero,
          ),
      ],
    );
  }
}

/// ╪º┘ä┘Ç State Class ╪º┘ä╪▒╪ª┘è╪│┘è╪⌐
class AzkarShareSettings {
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // THEME & DESIGN
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  final String themeId;
  final String templateType;
  final double fontSize;
  final bool isGradientBg;
  final Color customBgColor;
  final Color customBgColor2;
  final Color customTextColor;
  final Color customAccentColor;
  final String fontFamily;

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // LAYOUT
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  final bool showBranding;
  final bool showCategoryHeader;
  final double padding;
  final bool isStoryMode;
  final double borderRadius;
  final double bgOpacity;
  final TextAlign textAlign;
  final double lineHeight;
  final double verticalAlignment;

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // ELEMENT CUSTOMIZATION
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  final ElementStyle zekrStyle;
  final ElementStyle categoryStyle;
  final ElementStyle descriptionStyle;
  final ElementStyle referenceStyle;

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // IMAGE BACKGROUND
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  final ImageBackgroundSettings imageBackground;

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // TEXT EFFECTS
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  final TextEffects textEffects;

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // QUALITY
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  final String quality; // 'standard', 'high', 'ultra'

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // CONSTRUCTOR
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  const AzkarShareSettings({
    // Theme & Design
    this.themeId = 'glass_dark',
    this.templateType = 'classic',
    this.fontSize = 24.0,
    this.isGradientBg = false,
    this.customBgColor = const Color(0xFF141414),
    this.customBgColor2 = const Color(0xFF1E1E1E),
    this.customTextColor = Colors.white,
    this.customAccentColor = const Color(0xFF33B18E),
    this.fontFamily = 'IDRISIUM',
    
    // Layout
    this.showBranding = true,
    this.showCategoryHeader = true,
    this.padding = 60.0,
    this.isStoryMode = false,
    this.borderRadius = 32.0,
    this.bgOpacity = 0.98,
    this.textAlign = TextAlign.center,
    this.lineHeight = 1.7,
    this.verticalAlignment = 0.0,
    
    // Element Customization
    this.zekrStyle = ElementStyle.empty,
    this.categoryStyle = const ElementStyle(styleId: 'classic'),
    this.descriptionStyle = const ElementStyle(styleId: 'classic'),
    this.referenceStyle = ElementStyle.empty,
    
    // Image Background
    this.imageBackground = ImageBackgroundSettings.empty,
    
    // Text Effects
    this.textEffects = TextEffects.empty,
    
    // Quality
    this.quality = 'ultra',
  });

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // COPY WITH
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  AzkarShareSettings copyWith({
    // Theme & Design
    String? themeId,
    String? templateType,
    double? fontSize,
    bool? isGradientBg,
    Color? customBgColor,
    Color? customBgColor2,
    Color? customTextColor,
    Color? customAccentColor,
    String? fontFamily,
    
    // Layout
    bool? showBranding,
    bool? showCategoryHeader,
    double? padding,
    bool? isStoryMode,
    double? borderRadius,
    double? bgOpacity,
    TextAlign? textAlign,
    double? lineHeight,
    double? verticalAlignment,
    
    // Element Customization
    ElementStyle? zekrStyle,
    ElementStyle? categoryStyle,
    ElementStyle? descriptionStyle,
    ElementStyle? referenceStyle,
    
    // Image Background
    ImageBackgroundSettings? imageBackground,
    
    // Text Effects
    TextEffects? textEffects,
    
    // Quality
    String? quality,
  }) {
    return AzkarShareSettings(
      themeId: themeId ?? this.themeId,
      templateType: templateType ?? this.templateType,
      fontSize: fontSize ?? this.fontSize,
      isGradientBg: isGradientBg ?? this.isGradientBg,
      customBgColor: customBgColor ?? this.customBgColor,
      customBgColor2: customBgColor2 ?? this.customBgColor2,
      customTextColor: customTextColor ?? this.customTextColor,
      customAccentColor: customAccentColor ?? this.customAccentColor,
      fontFamily: fontFamily ?? this.fontFamily,
      
      showBranding: showBranding ?? this.showBranding,
      showCategoryHeader: showCategoryHeader ?? this.showCategoryHeader,
      padding: padding ?? this.padding,
      isStoryMode: isStoryMode ?? this.isStoryMode,
      borderRadius: borderRadius ?? this.borderRadius,
      bgOpacity: bgOpacity ?? this.bgOpacity,
      textAlign: textAlign ?? this.textAlign,
      lineHeight: lineHeight ?? this.lineHeight,
      verticalAlignment: verticalAlignment ?? this.verticalAlignment,
      
      zekrStyle: zekrStyle ?? this.zekrStyle,
      categoryStyle: categoryStyle ?? this.categoryStyle,
      descriptionStyle: descriptionStyle ?? this.descriptionStyle,
      referenceStyle: referenceStyle ?? this.referenceStyle,
      
      imageBackground: imageBackground ?? this.imageBackground,
      textEffects: textEffects ?? this.textEffects,
      quality: quality ?? this.quality,
    );
  }

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // JSON SERIALIZATION (┘ä┘ä┘Ç Undo/Redo ┘ê SharedPreferences)
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  Map<String, dynamic> toJson() => {
    // Theme & Design
    'themeId': themeId,
    'templateType': templateType,
    'fontSize': fontSize,
    'isGradientBg': isGradientBg,
    'customBgColor': customBgColor.value,
    'customBgColor2': customBgColor2.value,
    'customTextColor': customTextColor.value,
    'customAccentColor': customAccentColor.value,
    'fontFamily': fontFamily,
    
    // Layout
    'showBranding': showBranding,
    'showCategoryHeader': showCategoryHeader,
    'padding': padding,
    'isStoryMode': isStoryMode,
    'borderRadius': borderRadius,
    'bgOpacity': bgOpacity,
    'textAlign': textAlign.index,
    'lineHeight': lineHeight,
    'verticalAlignment': verticalAlignment,
    
    // Element Customization
    'zekrStyle': zekrStyle.toJson(),
    'categoryStyle': categoryStyle.toJson(),
    'descriptionStyle': descriptionStyle.toJson(),
    'referenceStyle': referenceStyle.toJson(),
    
    // Image Background
    'imageBackground': imageBackground.toJson(),
    
    // Text Effects
    'textEffects': textEffects.toJson(),
    
    // Quality
    'quality': quality,
  };

  factory AzkarShareSettings.fromJson(Map<String, dynamic> json) {
    return AzkarShareSettings(
      themeId: json['themeId'] ?? 'glass_dark',
      templateType: json['templateType'] ?? 'classic',
      fontSize: json['fontSize']?.toDouble() ?? 24.0,
      isGradientBg: json['isGradientBg'] ?? false,
      customBgColor: json['customBgColor'] != null 
          ? Color(json['customBgColor']) 
          : const Color(0xFF141414),
      customBgColor2: json['customBgColor2'] != null 
          ? Color(json['customBgColor2']) 
          : const Color(0xFF1E1E1E),
      customTextColor: json['customTextColor'] != null 
          ? Color(json['customTextColor']) 
          : Colors.white,
      customAccentColor: json['customAccentColor'] != null 
          ? Color(json['customAccentColor']) 
          : const Color(0xFF33B18E),
      fontFamily: json['fontFamily'] ?? 'KFGQPC-Uthmanic-HAFS-Regular',
      
      showBranding: json['showBranding'] ?? true,
      showCategoryHeader: json['showCategoryHeader'] ?? true,
      padding: json['padding']?.toDouble() ?? 60.0,
      isStoryMode: json['isStoryMode'] ?? false,
      borderRadius: json['borderRadius']?.toDouble() ?? 32.0,
      bgOpacity: json['bgOpacity']?.toDouble() ?? 0.98,
      textAlign: json['textAlign'] != null 
          ? TextAlign.values[json['textAlign']] 
          : TextAlign.center,
      lineHeight: json['lineHeight']?.toDouble() ?? 1.7,
      verticalAlignment: json['verticalAlignment']?.toDouble() ?? 0.0,
      
      zekrStyle: json['zekrStyle'] != null 
          ? ElementStyle.fromJson(json['zekrStyle']) 
          : ElementStyle.empty,
      categoryStyle: json['categoryStyle'] != null 
          ? ElementStyle.fromJson(json['categoryStyle']) 
          : const ElementStyle(styleId: 'classic'),
      descriptionStyle: json['descriptionStyle'] != null 
          ? ElementStyle.fromJson(json['descriptionStyle']) 
          : const ElementStyle(styleId: 'classic'),
      referenceStyle: json['referenceStyle'] != null 
          ? ElementStyle.fromJson(json['referenceStyle']) 
          : ElementStyle.empty,
      
      imageBackground: json['imageBackground'] != null 
          ? ImageBackgroundSettings.fromJson(json['imageBackground']) 
          : ImageBackgroundSettings.empty,
      
      textEffects: json['textEffects'] != null 
          ? TextEffects.fromJson(json['textEffects']) 
          : TextEffects.empty,
      
      quality: json['quality'] ?? 'ultra',
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory AzkarShareSettings.fromJsonString(String jsonString) {
    return AzkarShareSettings.fromJson(jsonDecode(jsonString));
  }

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // DEFAULT INSTANCE
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  static const AzkarShareSettings defaultSettings = AzkarShareSettings();
}
