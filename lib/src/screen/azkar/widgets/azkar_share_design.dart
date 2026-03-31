import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AzkarShareDesign extends StatelessWidget {
  final String zekr;
  final String? description;
  final String? reference;
  final String categoryName;
  final Color primaryColor;
  final double fontSize;
  final String themeId;
  final String templateType;
  final Color? customBgColor;
  final Color? customBgColor2;
  final bool isGradientBg;
  final Color? customTextColor;
  final Color? customAccentColor;
  final String fontFamily;
  final bool showBranding; // Logo + credits only
  final bool showCategoryHeader; // Category name header
  final double padding;
  final bool isStoryMode;
  final double borderRadius;
  final double bgOpacity;
  final TextAlign textAlign;
  final double lineHeight;
  final double verticalAlignment; // 0.0 for center, -1.0 for top, 1.0 for bottom
  
  // Granular Customization
  final Color? zekrColor;
  final String? zekrFont;
  
  final Color? categoryColor;
  final String? categoryFont;
  final String categoryStyleId; // classic, pill, modern, neon
  
  final Color? descriptionColor;
  final String? descriptionFont;
  final String descriptionStyleId; // classic, soft_pill, quote, underline
  
  final Color? referenceColor;
  final String? referenceFont;

  // Granular Font Customization (Override global fontSize/lineHeight)
  final double? zekrFontSize;
  final double? zekrLineHeight;
  final double zekrOffsetX;
  final double zekrOffsetY;
  
  final double? categoryFontSize;
  final double? categoryLineHeight;
  final double categoryOffsetX;
  final double categoryOffsetY;
  
  final double? descriptionFontSize;
  final double? descriptionLineHeight;
  final double descriptionOffsetX;
  final double descriptionOffsetY;
  
  final double? referenceFontSize;
  final double? referenceLineHeight;
  final double referenceOffsetX;
  final double referenceOffsetY;

  // Image Background Customization
  final String? backgroundImagePath; // Local file path
  final String imageFilter; // none, grayscale, sepia, vintage, cool, warm, dramatic, fade, contrast, bright
  final Offset imageOffset;
  final double imageScale;
  final double imageBlur;
  final double imageOverlayOpacity;


  const AzkarShareDesign({
    super.key,
    required this.zekr,
    this.description,
    this.reference,
    required this.categoryName,
    required this.primaryColor,
    this.fontSize = 18.0,
    this.themeId = 'glass_dark',
    this.templateType = 'classic',
    this.customBgColor,
    this.customBgColor2,
    this.isGradientBg = false,
    this.customTextColor,
    this.customAccentColor,
    this.fontFamily = "KFGQPC-Uthmanic-HAFS-Regular",
    this.showBranding = true,
    this.showCategoryHeader = true,
    this.padding = 60.0,
    this.isStoryMode = false,
    this.borderRadius = 32.0,
    this.bgOpacity = 0.98,
    this.textAlign = TextAlign.center,
    this.lineHeight = 1.7,
    this.verticalAlignment = 0.0,
    this.zekrColor,
    this.zekrFont,
    this.categoryColor,
    this.categoryFont,
    this.categoryStyleId = 'classic',
    this.descriptionColor,
    this.descriptionFont,
    this.descriptionStyleId = 'classic',
    this.referenceColor,
    this.referenceFont,
    this.backgroundImagePath,
    this.imageFilter = 'none',
    this.imageOffset = Offset.zero,
    this.imageScale = 1.0,
    this.imageBlur = 0.0,
    this.imageOverlayOpacity = 0.0,
    this.zekrFontSize,
    this.zekrLineHeight,
    this.zekrOffsetX = 0.0,
    this.zekrOffsetY = 0.0,
    this.categoryFontSize,
    this.categoryLineHeight,
    this.categoryOffsetX = 0.0,
    this.categoryOffsetY = 0.0,
    this.descriptionFontSize,
    this.descriptionLineHeight,
    this.descriptionOffsetX = 0.0,
    this.descriptionOffsetY = 0.0,
    this.referenceFontSize,
    this.referenceLineHeight,
    this.referenceOffsetX = 0.0,
    this.referenceOffsetY = 0.0,
  });


  @override
  Widget build(BuildContext context) {
    BoxDecoration decoration;
    Color textColor = Colors.white;
    Color accentColor = primaryColor;

    final double canvasWidth = 1080;
    final double canvasHeight = isStoryMode ? 1920 : 1080;

    switch (themeId) {
      case 'glass_light':
        textColor = const Color(0xFF1B1B1B);
        accentColor = primaryColor;
        decoration = BoxDecoration(
          color: const Color(0xFFFDFAF5).withValues(alpha: bgOpacity),
          borderRadius: BorderRadius.circular(isStoryMode ? 0 : borderRadius),
        );
        break;
      case 'dark_royal':
        textColor = const Color(0xFFF5E6C8);
        accentColor = const Color(0xFFD4A746);
        decoration = BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0A0806).withValues(alpha: bgOpacity),
              const Color(0xFF1A130A).withValues(alpha: bgOpacity),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(isStoryMode ? 0 : borderRadius),
          border: isStoryMode ? null : Border.all(color: accentColor.withValues(alpha: 0.35), width: 3),
        );
        break;
      case 'midnight_blue':
        textColor = const Color(0xFFE3F2FD);
        accentColor = const Color(0xFF64B5F6);
        decoration = BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0D1B2A).withValues(alpha: bgOpacity),
              const Color(0xFF1B2838).withValues(alpha: bgOpacity)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(isStoryMode ? 0 : borderRadius),
        );
        break;
      case 'emerald_gradient':
        textColor = const Color(0xFFE0F2F1);
        accentColor = const Color(0xFF80CBC4);
        decoration = BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0A1F1A).withValues(alpha: bgOpacity),
              const Color(0xFF1A3C34).withValues(alpha: bgOpacity)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(isStoryMode ? 0 : borderRadius),
        );
        break;
      case 'sunset':
        textColor = const Color(0xFFF3E5F5);
        accentColor = const Color(0xFFCE93D8);
        decoration = BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF1A0A2E).withValues(alpha: bgOpacity),
              const Color(0xFF2D1B69).withValues(alpha: bgOpacity),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(isStoryMode ? 0 : borderRadius),
        );
        break;
      case 'sand_dunes':
        textColor = const Color(0xFF3E2723);
        accentColor = const Color(0xFF8D6E63);
        decoration = BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFEFEBE9).withValues(alpha: bgOpacity),
              const Color(0xFFD7CCC8).withValues(alpha: bgOpacity)
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(isStoryMode ? 0 : borderRadius),
        );
        break;
      case 'ocean_night':
        textColor = const Color(0xFFB2EBF2);
        accentColor = const Color(0xFF4DD0E1);
        decoration = BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0A1628).withValues(alpha: bgOpacity),
              const Color(0xFF0D2137).withValues(alpha: bgOpacity),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(isStoryMode ? 0 : borderRadius),
        );
        break;
      case 'rose_gold':
        textColor = const Color(0xFF2C1A1D);
        accentColor = const Color(0xFFB76E79);
        decoration = BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFBE9E7).withValues(alpha: bgOpacity),
              const Color(0xFFF8BBD0).withValues(alpha: bgOpacity),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(isStoryMode ? 0 : borderRadius),
        );
        break;
      case 'forest_green':
        textColor = const Color(0xFFE8F5E9);
        accentColor = const Color(0xFF66BB6A);
        decoration = BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF0B1F0E).withValues(alpha: bgOpacity),
              const Color(0xFF1B3A20).withValues(alpha: bgOpacity),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(isStoryMode ? 0 : borderRadius),
        );
        break;
      case 'custom':
        textColor = customTextColor ?? Colors.white;
        accentColor = customAccentColor ?? primaryColor;
        if (isGradientBg) {
          decoration = BoxDecoration(
            gradient: LinearGradient(
              colors: [
                (customBgColor ?? const Color(0xFF141414)).withValues(alpha: bgOpacity),
                (customBgColor2 ?? const Color(0xFF141414)).withValues(alpha: bgOpacity)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(isStoryMode ? 0 : borderRadius),
          );
        } else {
          decoration = BoxDecoration(
            color: (customBgColor ?? const Color(0xFF141414)).withValues(alpha: bgOpacity),
            borderRadius: BorderRadius.circular(isStoryMode ? 0 : borderRadius),
          );
        }
        break;
      case 'glass_dark':
      default:
        textColor = Colors.white;
        // Boost accent color lightness for dark backgrounds
        final hsl = HSLColor.fromColor(primaryColor);
        accentColor = hsl.withLightness((hsl.lightness < 0.6) ? 0.7 : hsl.lightness).toColor();
        decoration = BoxDecoration(
          color: const Color(0xFF0A0A0A).withValues(alpha: bgOpacity),
          borderRadius: BorderRadius.circular(isStoryMode ? 0 : borderRadius),
          border: isStoryMode ? null : Border.all(color: Colors.white.withValues(alpha: 0.1), width: 1.5),
        );
        break;
    }

    // Logic for individual text styles
    TextStyle getStyle(Color defaultColor, String? customFont, Color? customColor, double? customSize, double? customHeight, double sizeBoost, FontWeight weight) {
      final finalFont = customFont ?? fontFamily;
      final finalColor = customColor ?? defaultColor;
      final finalSize = customSize ?? (fontSize + sizeBoost);
      final finalHeight = customHeight ?? lineHeight;
      
      return TextStyle(color: finalColor, fontSize: finalSize, height: finalHeight, fontWeight: weight, fontFamily: finalFont, fontFamilyFallback: const ['Amiri-Regular', 'KFGQPC-Uthmanic-HAFS-Regular']);
    }

    final zekrStyle = getStyle(textColor, zekrFont, zekrColor, zekrFontSize, zekrLineHeight, 16, FontWeight.bold);
    final catHeaderStyle = getStyle(accentColor, categoryFont, categoryColor, categoryFontSize, categoryLineHeight, 12, FontWeight.w900);
    final descStyle = getStyle(accentColor.withValues(alpha: 0.95), descriptionFont, descriptionColor, descriptionFontSize, descriptionLineHeight, 4, FontWeight.w600);
    final refStyle = getStyle(textColor.withValues(alpha: 0.65), referenceFont, referenceColor, referenceFontSize, referenceLineHeight, -4, FontWeight.normal);

    // If image background is present, make the main decoration background transparent
    // so it doesn't cover the image.
    final BoxDecoration effectiveDecoration = backgroundImagePath != null 
      ? decoration.copyWith(color: Colors.transparent, gradient: null, border: Border.all(color: Colors.transparent, width: 0))
      : decoration;

    if (templateType == 'minimalist') {
      return _buildMinimalist(canvasWidth, canvasHeight, decoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle);
    }
    
    // Switch for all 20+ templates
    Widget content;
    switch (templateType) {
      case 'modern_card': content = _buildModernCard(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'glass_blur': content = _buildGlassBlur(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'neumorphic': content = _buildNeumorphic(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'bauhaus': content = _buildBauhaus(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'insta_quote': content = _buildInstaQuote(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'manuscript': content = _buildManuscript(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'side_accent': content = _buildSideAccent(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'typo_master': content = _buildTypoMaster(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'mesh_gradient': content = _buildMeshGradient(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'bento': content = _buildBento(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'framed': content = _buildFramed(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'brutalist': content = _buildBrutalist(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'mosaic': content = _buildMosaic(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'reflective': content = _buildReflective(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'zen': content = _buildZen(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'royal': content = _buildRoyal(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'watercolor': content = _buildWatercolor(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'sticky_note': content = _buildStickyNote(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle); break;
      case 'classic':
      default:
        content = _buildClassic(canvasWidth, canvasHeight, effectiveDecoration, textColor, accentColor, zekrStyle, catHeaderStyle, descStyle, refStyle);
    }

    // Wrap with Image Background if exists
    if (backgroundImagePath != null || imageBlur > 0) {
      content = Container(
        width: canvasWidth,
        height: canvasHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(isStoryMode ? 0 : borderRadius)),
        child: Stack(
          children: [
            // 1. Image Layer
            if (backgroundImagePath != null)
              Positioned.fill(
                child: Transform.translate(
                  offset: imageOffset,
                  child: Transform.scale(
                    scale: imageScale,
                    child: _applyImageFilter(
                      Image.file(
                        File(backgroundImagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(color: Colors.red.withValues(alpha: 0.15)),
                      ),
                    ),
                  ),
                ),
              ),
            // 2. Blur Layer
            if (imageBlur > 0)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: imageBlur, sigmaY: imageBlur),
                  child: Container(color: Colors.transparent),
                ),
              ),
            // 3. Overlay Layer
            if (imageOverlayOpacity > 0)
              Positioned.fill(child: Container(color: Colors.black.withValues(alpha: imageOverlayOpacity))),
            // 4. Content Layer
            Positioned.fill(child: content),
          ],
        ),
      );
    }

    return content;
  }

  Widget _applyImageFilter(Widget child) {
    final filter = _getColorFilter(imageFilter);
    if (filter == null) return child;
    return ColorFiltered(colorFilter: filter, child: child);
  }

  ColorFilter? _getColorFilter(String id) {
    switch (id) {
      case 'grayscale':
        return const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case 'sepia':
        return const ColorFilter.matrix(<double>[
          0.393, 0.769, 0.189, 0, 0,
          0.349, 0.686, 0.168, 0, 0,
          0.272, 0.534, 0.131, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case 'vintage':
        return const ColorFilter.matrix(<double>[
          0.9, 0.1, 0.0, 0, 10,
          0.0, 0.85, 0.1, 0, 10,
          0.0, 0.1, 0.8, 0, 10,
          0, 0, 0, 1, 0,
        ]);
      case 'cool':
        return const ColorFilter.matrix(<double>[
          1.0, 0.0, 0.0, 0, 0,
          0.0, 1.0, 0.0, 0, 0,
          0.0, 0.0, 1.15, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case 'warm':
        return const ColorFilter.matrix(<double>[
          1.15, 0.0, 0.0, 0, 0,
          0.0, 1.05, 0.0, 0, 0,
          0.0, 0.0, 0.95, 0, 0,
          0, 0, 0, 1, 0,
        ]);
      case 'dramatic':
        return const ColorFilter.matrix(<double>[
          1.25, 0.0, 0.0, 0, -20,
          0.0, 1.25, 0.0, 0, -20,
          0.0, 0.0, 1.25, 0, -20,
          0, 0, 0, 1, 0,
        ]);
      case 'fade':
        return const ColorFilter.matrix(<double>[
          0.9, 0.0, 0.0, 0, 20,
          0.0, 0.9, 0.0, 0, 20,
          0.0, 0.0, 0.9, 0, 20,
          0, 0, 0, 1, 0,
        ]);
      case 'contrast':
        return const ColorFilter.matrix(<double>[
          1.4, 0.0, 0.0, 0, -50,
          0.0, 1.4, 0.0, 0, -50,
          0.0, 0.0, 1.4, 0, -50,
          0, 0, 0, 1, 0,
        ]);
      case 'bright':
        return const ColorFilter.matrix(<double>[
          1.1, 0.0, 0.0, 0, 15,
          0.0, 1.1, 0.0, 0, 15,
          0.0, 0.0, 1.1, 0, 15,
          0, 0, 0, 1, 0,
        ]);
      case 'none':
      default:
        return null;
    }
  }

  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ
  // Template Builders
  // ΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉΓòÉ

  Widget _buildClassic(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width,
      height: height,
      decoration: decoration,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment(0, verticalAlignment),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showCategoryHeader) ...[
                      Transform.translate(
                        offset: Offset(categoryOffsetX, categoryOffsetY),
                        child: _buildStyledCategory(catHeaderStyle),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Transform.translate(
                      offset: Offset(zekrOffsetX, zekrOffsetY),
                      child: AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, maxLines: isStoryMode ? 30 : 15, minFontSize: 14, maxFontSize: 60, style: zekrStyle),
                    ),
                    if (description != null && description!.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      Transform.translate(
                        offset: Offset(descriptionOffsetX, descriptionOffsetY),
                        child: _buildStyledDescription(descStyle, accentColor, textColor),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (reference != null && reference!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Transform.translate(
                offset: Offset(referenceOffsetX, referenceOffsetY),
                child: Text(reference!, textAlign: TextAlign.center, style: refStyle),
              ),
            ],
            if (showBranding) _buildBranding(accentColor, textColor),
          ],
        ),
      ),
    );
  }

  Widget _buildModernCard(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
     return Container(
      width: width, height: height, decoration: decoration,
      child: Center(
        child: Container(
          width: width * 0.85,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: (decoration.color ?? Colors.white).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 40, offset: const Offset(0, 20))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showCategoryHeader) _buildStyledCategory(catHeaderStyle),
              const SizedBox(height: 30),
              AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, maxLines: 12, style: zekrStyle),
              if (description != null) ...[const SizedBox(height: 20), _buildStyledDescription(descStyle, accentColor, textColor)],
              if (showBranding) ...[const SizedBox(height: 30), _buildBranding(accentColor, textColor)],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassBlur(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width, height: height, decoration: decoration,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: width * 0.9,
              padding: const EdgeInsets.all(50),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showCategoryHeader) _buildStyledCategory(catHeaderStyle),
                  const SizedBox(height: 20),
                  AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, style: zekrStyle.copyWith(shadows: [const Shadow(color: Colors.black45, blurRadius: 10)])),
                  if (showBranding) ...[const SizedBox(height: 30), _buildBranding(accentColor, textColor)],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeumorphic(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    final baseColor = decoration.color ?? const Color(0xFFE0E0E0);
    return Container(
      width: width, height: height, color: baseColor,
      child: Center(
        child: Container(
          width: width * 0.85,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(color: Colors.white, offset: const Offset(-10, -10), blurRadius: 20),
              BoxShadow(color: Colors.black.withValues(alpha: 0.1), offset: const Offset(10, 10), blurRadius: 20),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, style: zekrStyle.copyWith(color: Colors.grey[700])),
              if (showBranding) ...[const SizedBox(height: 30), _buildBranding(accentColor, textColor)],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBauhaus(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width, height: height, decoration: decoration,
      child: Stack(
        children: [
          Positioned(top: -100, left: -100, child: CircleAvatar(radius: 200, backgroundColor: accentColor.withValues(alpha: 0.15))),
          Positioned(bottom: 100, right: -50, child: Transform.rotate(angle: 0.5, child: Container(width: 300, height: 300, color: accentColor.withValues(alpha: 0.1)))),
          Padding(
            padding: EdgeInsets.all(padding),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, style: zekrStyle.copyWith(fontSize: zekrStyle.fontSize! * 1.2, fontWeight: FontWeight.w900, color: textColor)),
                if (showBranding) _buildBranding(accentColor, textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstaQuote(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width, height: height, decoration: decoration,
      child: Stack(
        children: [
          Positioned(top: 40, right: 40, child: Icon(Icons.format_quote_rounded, size: 150, color: accentColor.withValues(alpha: 0.2))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 120),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (showCategoryHeader) Text(categoryName, style: catHeaderStyle.copyWith(letterSpacing: 8, fontSize: 18)),
                const SizedBox(height: 40),
                AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, style: zekrStyle.copyWith(fontSize: 42, height: 1.3)),
                const Spacer(),
                if (showBranding) _buildBranding(accentColor, textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManuscript(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width, height: height,
      decoration: decoration.copyWith(color: const Color(0xFFF4E4BC)),
      child: Container(
        margin: const EdgeInsets.all(40),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFF8B4513), width: 4)),
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showCategoryHeader) Text(categoryName, style: catHeaderStyle.copyWith(color: const Color(0xFF8B4513))),
              const SizedBox(height: 30),
              AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, style: zekrStyle.copyWith(color: Colors.black87, fontFamily: 'Amiri')),
              if (showBranding) _buildBranding(accentColor, Colors.black54),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSideAccent(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width, height: height, decoration: decoration,
      child: Row(
        children: [
          Container(width: 40, height: height, color: accentColor),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(60),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, style: zekrStyle),
                  if (showBranding) _buildBranding(accentColor, textColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypoMaster(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width, height: height, decoration: decoration,
      padding: const EdgeInsets.all(60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showCategoryHeader) Text(categoryName.toUpperCase(), style: catHeaderStyle.copyWith(fontSize: 40, letterSpacing: -2)),
          const SizedBox(height: 40),
          Expanded(child: AutoSizeText(zekr, textDirection: TextDirection.rtl, style: zekrStyle.copyWith(fontSize: 50, fontWeight: FontWeight.w900))),
          if (showBranding) _buildBranding(accentColor, textColor),
        ],
      ),
    );
  }

  Widget _buildMeshGradient(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width, height: height,
      child: Stack(
        children: [
          Positioned.fill(child: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [accentColor.withValues(alpha: 0.3), Colors.blue.withValues(alpha: 0.2)], begin: Alignment.topLeft, end: Alignment.bottomRight)))),
          Positioned(top: 100, left: 100, child: BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container(width: 400, height: 400, decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.4), shape: BoxShape.circle)))),
          Padding(
            padding: const EdgeInsets.all(80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, style: zekrStyle.copyWith(color: Colors.white, shadows: [const Shadow(color: Colors.black26, blurRadius: 20)])),
                if (showBranding) _buildBranding(accentColor, Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBento(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width, height: height, decoration: decoration,
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(flex: 2, child: _bentoCell(categoryName, catHeaderStyle, accentColor)),
              const SizedBox(width: 20),
              Expanded(child: _bentoCell("الفرقان", const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), accentColor)),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(child: _bentoCell(zekr, zekrStyle, Colors.transparent, isContent: true)),
          const SizedBox(height: 20),
          if (showBranding) _buildBranding(accentColor, textColor),
        ],
      ),
    );
  }

  Widget _bentoCell(String text, TextStyle style, Color color, {bool isContent = false}) {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(30), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Center(child: AutoSizeText(text, textAlign: TextAlign.center, textDirection: TextDirection.rtl, style: style)),
    );
  }

  Widget _buildFramed(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width, height: height, decoration: decoration,
      child: Container(
        margin: const EdgeInsets.all(60),
        decoration: BoxDecoration(border: Border.all(color: accentColor, width: 2)),
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(border: Border.all(color: accentColor.withValues(alpha: 0.4), width: 1)),
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (showCategoryHeader) _buildStyledCategory(catHeaderStyle),
              const SizedBox(height: 20),
              AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, style: zekrStyle),
              if (showBranding) _buildBranding(accentColor, textColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrutalist(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width, height: height, color: Colors.white,
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.yellow, border: Border.all(color: Colors.black, width: 4)),
            child: Text(categoryName, style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black)),
          ),
          const SizedBox(height: 40),
          Expanded(child: AutoSizeText(zekr, textDirection: TextDirection.rtl, style: zekrStyle.copyWith(color: Colors.black, fontSize: 45, fontWeight: FontWeight.w900))),
          if (showBranding) _buildBranding(Colors.black, Colors.black),
        ],
      ),
    );
  }

  Widget _buildMosaic(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width, height: height, decoration: decoration,
      child: Stack(
        children: [
          Opacity(opacity: 0.05, child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5), itemBuilder: (c, i) => Icon(Icons.grid_4x4_rounded, size: 100, color: accentColor))),
          Padding(
            padding: const EdgeInsets.all(60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, style: zekrStyle),
                if (showBranding) _buildBranding(accentColor, textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReflective(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width, height: height, decoration: decoration,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, style: zekrStyle),
          const SizedBox(height: 10),
          Opacity(
            opacity: 0.2,
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationX(3.14),
              child: AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, style: zekrStyle, maxLines: 1),
            ),
          ),
          if (showBranding) _buildBranding(accentColor, textColor),
        ],
      ),
    );
  }

  Widget _buildZen(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width, height: height, color: const Color(0xFFF9F9F9),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 100, height: 100, decoration: BoxDecoration(color: accentColor.withValues(alpha: 0.1), shape: BoxShape.circle)),
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, style: zekrStyle.copyWith(color: Colors.black54, letterSpacing: 2)),
            ),
            const SizedBox(height: 60),
            if (showBranding) _buildBranding(accentColor, Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildRoyal(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width, height: height,
      decoration: const BoxDecoration(color: Color(0xFF1A1A1A)),
      child: Container(
        margin: const EdgeInsets.all(50),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD4AF37), width: 3)),
        child: Padding(
          padding: const EdgeInsets.all(50),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(categoryName, style: catHeaderStyle.copyWith(color: const Color(0xFFD4AF37), fontFamily: 'Serif')),
              const SizedBox(height: 40),
              AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, style: zekrStyle.copyWith(color: const Color(0xFFD4AF37), fontSize: 35)),
              if (showBranding) _buildBranding(const Color(0xFFD4AF37), Colors.white38),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWatercolor(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width, height: height, decoration: decoration,
      child: Stack(
        children: [
          Positioned(top: 100, left: 100, child: Icon(Icons.blur_on_rounded, size: 400, color: accentColor.withValues(alpha: 0.2))),
          Padding(
            padding: const EdgeInsets.all(80),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, style: zekrStyle),
                if (showBranding) _buildBranding(accentColor, textColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyNote(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catHeaderStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width, height: height, decoration: decoration,
      child: Center(
        child: Transform.rotate(
          angle: -0.05,
          child: Container(
            width: width * 0.8,
            height: width * 0.8,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(color: Colors.yellow[200], boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 20, offset: const Offset(10, 10))]),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, style: zekrStyle.copyWith(color: Colors.black87, fontFamily: 'Indie')),
                if (showBranding) _buildBranding(Colors.black, Colors.black45),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBranding(Color accentColor, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.12),
            accentColor.withValues(alpha: 0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    color: accentColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "الفرقان",
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          fontFamily: "IDRISIUM",
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "IDRISIUM Corp",
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.5),
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                          fontFamily: "NotoSans",
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: 0.3),
                  accentColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(13),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                "assets/img/Quran_Logo_v3.png",
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildMinimalist(double width, double height, BoxDecoration decoration, Color textColor, Color accentColor, TextStyle zekrStyle, TextStyle catStyle, TextStyle descStyle, TextStyle refStyle) {
    return Container(
      width: width,
      height: height,
      color: decoration.color ?? Colors.white,
      padding: EdgeInsets.all(padding * 1.5),
      child: Column(
        crossAxisAlignment: textAlign == TextAlign.right ? CrossAxisAlignment.end : (textAlign == TextAlign.left ? CrossAxisAlignment.start : CrossAxisAlignment.center),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showCategoryHeader)
             Transform.translate(
               offset: Offset(categoryOffsetX, categoryOffsetY),
               child: Text(categoryName.toUpperCase(), style: catStyle.copyWith(letterSpacing: 6)),
             ),
          const SizedBox(height: 40),
          Transform.translate(
            offset: Offset(zekrOffsetX, zekrOffsetY),
            child: AutoSizeText(zekr, textAlign: textAlign, textDirection: TextDirection.rtl, maxLines: isStoryMode ? 25 : 10, style: zekrStyle),
          ),
          if (description != null && description!.isNotEmpty) ...[
             const SizedBox(height: 40),
             Transform.translate(
               offset: Offset(descriptionOffsetX, descriptionOffsetY),
               child: Text(description!, textAlign: textAlign, style: descStyle),
             ),
          ],
          if (reference != null && reference!.isNotEmpty) ...[
            const SizedBox(height: 30),
            Transform.translate(
              offset: Offset(referenceOffsetX, referenceOffsetY),
              child: Text(reference!, textAlign: textAlign, style: refStyle),
            ),
          ],
          if (showBranding) ...[
            const SizedBox(height: 80),
            Text("AL-FURKAN APP", style: TextStyle(color: accentColor.withValues(alpha: 0.5), fontSize: 16, letterSpacing: 6, fontWeight: FontWeight.bold, fontFamily: "NotoSans")),
          ]
        ],
      ),
    );
  }

  Widget _buildStyledCategory(TextStyle style) {
    final double baseSize = style.fontSize ?? 16;
    switch (categoryStyleId) {
      case 'pill':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            color: style.color!.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: style.color!.withValues(alpha: 0.2)),
          ),
          child: Text(categoryName, style: style.copyWith(fontSize: baseSize * 0.7)),
        );
      case 'modern':
        return Column(
          children: [
            Text(categoryName, style: style.copyWith(letterSpacing: 3, fontSize: baseSize * 0.9)),
            const SizedBox(height: 6),
            Container(width: 60, height: 3, color: style.color),
          ],
        );
      case 'classic':
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(width: 45, height: 3, decoration: BoxDecoration(color: style.color!.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 20),
            Text(categoryName, style: style),
            const SizedBox(width: 20),
            Container(width: 45, height: 3, decoration: BoxDecoration(color: style.color!.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(2))),
          ],
        );
    }
  }

  Widget _buildStyledDescription(TextStyle style, Color accentColor, Color textColor) {
    switch (descriptionStyleId) {
      case 'soft_pill':
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: style.color!.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: style.color!.withValues(alpha: 0.15)),
          ),
          child: Text(description!, textAlign: TextAlign.center, style: style.copyWith(fontSize: style.fontSize! * 0.9)),
        );
      case 'quote':
        return Stack(
          alignment: Alignment.center,
          children: [
            Opacity(opacity: 0.2, child: Icon(Icons.format_quote_rounded, size: 60, color: style.color)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Text(description!, textAlign: TextAlign.center, style: style.copyWith(fontStyle: FontStyle.italic)),
            ),
          ],
        );
      case 'underline':
        return Container(
          margin: const EdgeInsets.only(top: 26),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.035),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.25),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                "Quran App",
                style: TextStyle(
                  color: textColor.withValues(alpha: 0.5),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w600,
                  fontFamily: "NotoSans",
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        );
      case 'classic':
      default:
        return Text(
          description ?? '',
          textAlign: TextAlign.center,
          style: style,
        );
    }
  }
}
