import "package:auto_size_text/auto_size_text.dart";
import "package:flutter/material.dart";

/// تصميم ويدجيت الآية الممتاز - نمط البساطة العضوية (Organic Minimalism)
class PremiumWidgetDesign extends StatelessWidget {
  static const Size canvasSize = Size(960, 500);

  final String ayahText;
  final String surahName;
  final String fontFamily;
  final String themeId;
  final String contentType; // "quran" or "azkar"
  final double fontSizeMultiplier;

  const PremiumWidgetDesign({
    super.key,
    required this.ayahText,
    required this.surahName,
    required this.fontFamily,
    required this.themeId,
    this.contentType = "quran",
    this.fontSizeMultiplier = 1.0,
  });

  static const List<WidgetThemePreset> availableThemes = [
    WidgetThemePreset(
      id: "graphite_glass",
      name: "زجاج جرافيتي",
      isDark: true,
      backgroundColor: Color(0xFF1E1E1E), 
      textColor: Color(0xFFE3D5CA), 
      surahColor: Color(0xFF9E9E9E), 
      borderColor: Color(0xFF333333),
      accentColor: Color(0xFFE0E0E0),
    ),
    WidgetThemePreset(
      id: "midnight_ocean",
      name: "أعماق المحيط",
      backgroundColor: Color(0xFF0F172A),
      textColor: Color(0xFFF8FAFC),
      surahColor: Color(0xFF94A3B8),
      accentColor: Color(0xFF38BDF8),
      borderColor: Colors.transparent, // Completely transparent borders
      isDark: true,
    ),
    WidgetThemePreset(
      id: "graphite_glass_v2",
      name: "ليلي زجاجي",
      backgroundColor: Color(0xFF141414), // Very dark near-black
      textColor: Color(0xFFFAFAFA),
      surahColor: Color(0xFFA1A1AA),
      accentColor: Color(0xFFE4E4E7),
      borderColor: Colors.transparent, // Completely transparent
      isDark: true,
    ),
    WidgetThemePreset(
      id: "desert_sand",
      name: "رمال صحراوية",
      isDark: false,
      backgroundColor: Color(0xFFF5EBE0), 
      textColor: Color(0xFF4A443A), 
      surahColor: Color(0xFF8F887A), 
      borderColor: Color(0xFFE2E6E2),
      accentColor: Color(0xFF5A7063),
    ),
    WidgetThemePreset(
      id: "emerald_breeze",
      name: "زمرد نقي",
      isDark: true,
      backgroundColor: Color(0xFF064E3B),
      textColor: Color(0xFFECFDF5),
      surahColor: Color(0xFF6EE7B7),
      borderColor: Colors.transparent,
      accentColor: Color(0xFF10B981),
    ),
    WidgetThemePreset(
      id: "ruby_sunset",
      name: "غروب ياقوتي",
      isDark: true,
      backgroundColor: Color(0xFF450A0A),
      textColor: Color(0xFFFEF2F2),
      surahColor: Color(0xFFFCA5A5),
      borderColor: Colors.transparent,
      accentColor: Color(0xFFEF4444),
    ),
    WidgetThemePreset(
      id: "sapphire_glow",
      name: "وهج الياقوت الأزرق",
      isDark: true,
      backgroundColor: Color(0xFF172554),
      textColor: Color(0xFFEFF6FF),
      surahColor: Color(0xFF93C5FD),
      borderColor: Colors.transparent,
      accentColor: Color(0xFF3B82F6),
    ),
    WidgetThemePreset(
      id: "amethyst_night",
      name: "ليالي الجمشت",
      isDark: true,
      backgroundColor: Color(0xFF3B0764),
      textColor: Color(0xFFFAF5FF),
      surahColor: Color(0xFFD8B4FE),
      borderColor: Colors.transparent,
      accentColor: Color(0xFFA855F7),
    ),
    WidgetThemePreset(
      id: "coffee_mocha",
      name: "موكا دافئة",
      isDark: false,
      backgroundColor: Color(0xFFFFF7ED),
      textColor: Color(0xFF431407),
      surahColor: Color(0xFF9A3412),
      borderColor: Colors.transparent,
      accentColor: Color(0xFFEA580C),
    ),
    WidgetThemePreset(
      id: "light_crystal",
      name: "بلور نقي",
      isDark: false,
      backgroundColor: Color(0xFFFFFFFF),
      textColor: Color(0xFF18181B),
      surahColor: Color(0xFF71717A),
      borderColor: Color(0xFFE4E4E7),
      accentColor: Color(0xFF1E1E1E),
    ),
    WidgetThemePreset(
      id: "mystic_forest",
      name: "غابة صوفية",
      isDark: true,
      backgroundColor: Color(0xFF14532D),
      textColor: Color(0xFFF0FDF4),
      surahColor: Color(0xFF86EFAC),
      borderColor: Colors.transparent,
      accentColor: Color(0xFF22C55E),
    ),
    WidgetThemePreset(
      id: "olive_grove",
      name: "بستان زيتون",
      isDark: false,
      backgroundColor: Color(0xFFF4F6F4), 
      textColor: Color(0xFF2A312B), 
      surahColor: Color(0xFF73877B), 
      borderColor: Color(0xFFE2E6E2),
      accentColor: Color(0xFF5A7063),
    ),
  ];

  static WidgetThemePreset themeById(String id) {
    return availableThemes.firstWhere(
      (preset) => preset.id == id,
      orElse: () => availableThemes.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final preset = themeById(themeId);
    
    final isQuran = contentType == "quran";
    final resolvedFontFamily = fontFamily.isEmpty 
        ? (isQuran ? "KFGQPC-Uthmanic-HAFS-Regular" : "Cairo-Bold") 
        : fontFamily;
        
    final textFallback = const ["AmiriQuran-Regular", "KFGQPC-Uthmanic-HAFS-Regular"];

    return Container(
      width: canvasSize.width,
      height: canvasSize.height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: preset.backgroundColor,
        borderRadius: BorderRadius.circular(32),
        border: preset.borderColor == Colors.transparent 
            ? null 
            : Border.all(color: preset.borderColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top: Surah Name / Reference
            Text(
              surahName,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: preset.surahColor,
                fontSize: (28 * fontSizeMultiplier).roundToDouble(),
                fontWeight: FontWeight.w600,
                fontFamily: "Cairo-SemiBold",
                letterSpacing: 0.3,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Center: Ayah Text
            Expanded(
              child: Center(
                child: AutoSizeText(
                  ayahText,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  minFontSize: 28,
                  maxFontSize: (70 * fontSizeMultiplier).roundToDouble(),
                  maxLines: 3,
                  stepGranularity: 2,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    color: preset.textColor,
                    fontFamily: resolvedFontFamily,
                    fontFamilyFallback: textFallback,
                    height: isQuran ? 2.0 : 1.6,
                    fontWeight: isQuran ? FontWeight.w400 : FontWeight.w700,
                    fontSize: (isQuran ? 52.0 * fontSizeMultiplier : 48.0 * fontSizeMultiplier).roundToDouble(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WidgetThemePreset {
  final String id;
  final String name;
  final bool isDark;
  final Color backgroundColor;
  final Color textColor;
  final Color surahColor;
  final Color borderColor;
  final Color accentColor;

  const WidgetThemePreset({
    required this.id,
    required this.name,
    required this.isDark,
    required this.backgroundColor,
    required this.textColor,
    required this.surahColor,
    required this.borderColor,
    required this.accentColor,
  });
}
