import "package:auto_size_text/auto_size_text.dart";
import "package:flutter/material.dart";

class AyahWidgetThemePreset {
  final String id;
  final String name;
  final bool isDark;
  final Color primaryBackground;
  final Color secondaryBackground;
  final Color accent;
  final Color textColor;
  final Color surahColor;
  final bool prefersGradient;

  const AyahWidgetThemePreset({
    required this.id,
    required this.name,
    required this.isDark,
    required this.primaryBackground,
    required this.secondaryBackground,
    required this.accent,
    required this.textColor,
    required this.surahColor,
    required this.prefersGradient,
  });
}

class AyahWidgetDesign extends StatelessWidget {
  final String ayahText;
  final String surahName;
  final Color primaryColor;
  final double fontSize;
  final String themeId;
  final String fontFamily;
  final Color? customBgColor;
  final Color? customBgColor2;
  final bool isGradientBg;
  final Color? customTextColor;
  final Color? customSurahColor;
  final int ayahNumber;

  const AyahWidgetDesign({
    super.key,
    required this.ayahText,
    required this.surahName,
    required this.primaryColor,
    required this.fontSize,
    required this.themeId,
    required this.fontFamily,
    required this.ayahNumber,
    this.customBgColor,
    this.customBgColor2,
    this.isGradientBg = false,
    this.customTextColor,
    this.customSurahColor,
  });

  static const List<AyahWidgetThemePreset> availableThemes = [
    AyahWidgetThemePreset(
      id: "glass_dark",
      name: "زجاجي داكن",
      isDark: true,
      primaryBackground: Color(0xFF08090B),
      secondaryBackground: Color(0xFF1A1D22),
      accent: Color(0xFF62C5A4),
      textColor: Color(0xFFF9FAFC),
      surahColor: Color(0xFFB7C9BE),
      prefersGradient: true,
    ),
    AyahWidgetThemePreset(
      id: "glass_light",
      name: "زجاجي فاتح",
      isDark: false,
      primaryBackground: Color(0xFFF6F1E9),
      secondaryBackground: Color(0xFFE7DECF),
      accent: Color(0xFF8D7756),
      textColor: Color(0xFF201A15),
      surahColor: Color(0xFF6C5A40),
      prefersGradient: true,
    ),
    AyahWidgetThemePreset(
      id: "ocean_night",
      name: "أوبسيديان",
      isDark: true,
      primaryBackground: Color(0xFF0B0D11),
      secondaryBackground: Color(0xFF161A20),
      accent: Color(0xFF7C8CA5),
      textColor: Color(0xFFF5F7FB),
      surahColor: Color(0xFF9EAABE),
      prefersGradient: true,
    ),
    AyahWidgetThemePreset(
      id: "dark_royal",
      name: "رويال ملكي",
      isDark: true,
      primaryBackground: Color(0xFF120E12),
      secondaryBackground: Color(0xFF2A1826),
      accent: Color(0xFFC6A26D),
      textColor: Color(0xFFFFF8EF),
      surahColor: Color(0xFFE8C58F),
      prefersGradient: true,
    ),
    AyahWidgetThemePreset(
      id: "midnight_blue",
      name: "زفير",
      isDark: true,
      primaryBackground: Color(0xFF09131F),
      secondaryBackground: Color(0xFF11314A),
      accent: Color(0xFF5BAFFF),
      textColor: Color(0xFFF2F9FF),
      surahColor: Color(0xFF9FD0FF),
      prefersGradient: true,
    ),
    AyahWidgetThemePreset(
      id: "sunset",
      name: "أميثست",
      isDark: true,
      primaryBackground: Color(0xFF150C1E),
      secondaryBackground: Color(0xFF30163B),
      accent: Color(0xFFC797FF),
      textColor: Color(0xFFFCF6FF),
      surahColor: Color(0xFFE2C7FF),
      prefersGradient: true,
    ),
    AyahWidgetThemePreset(
      id: "emerald_gradient",
      name: "زمردي",
      isDark: true,
      primaryBackground: Color(0xFF081A16),
      secondaryBackground: Color(0xFF103229),
      accent: Color(0xFF4CCB9E),
      textColor: Color(0xFFF3FFFA),
      surahColor: Color(0xFFAEEED4),
      prefersGradient: true,
    ),
    AyahWidgetThemePreset(
      id: "sand",
      name: "ذهبي",
      isDark: false,
      primaryBackground: Color(0xFFF3E8CF),
      secondaryBackground: Color(0xFFE1D0A5),
      accent: Color(0xFFAA8341),
      textColor: Color(0xFF2A2216),
      surahColor: Color(0xFF7A5E2B),
      prefersGradient: true,
    ),
  ];

  static AyahWidgetThemePreset themeById(String id) {
    final aliases = <String, String>{
      "royal": "dark_royal",
      "obsidian": "ocean_night",
      "sapphire": "midnight_blue",
      "amethyst": "sunset",
      "emerald": "emerald_gradient",
      "gold": "sand",
    };
    final resolvedId = aliases[id] ?? id;
    return availableThemes.firstWhere(
      (preset) => preset.id == resolvedId,
      orElse: () => availableThemes.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final preset = themeById(themeId);
    final bgColor = customBgColor ?? preset.primaryBackground;
    final bgColor2 = customBgColor2 ?? preset.secondaryBackground;
    final textColor = customTextColor ?? preset.textColor;
    final surahColor = customSurahColor ?? preset.surahColor;
    final accent = preset.accent;
    final borderColor = preset.isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.08);
    final shouldUseGradient = isGradientBg || preset.prefersGradient;

    return Container(
      width: 800,
      height: 400,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: shouldUseGradient
            ? LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [bgColor, bgColor2],
              )
            : null,
        color: shouldUseGradient ? null : bgColor,
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: preset.isDark ? 0.18 : 0.10),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: preset.isDark ? 0.05 : 0.20),
                    Colors.transparent,
                    Colors.black.withValues(alpha: preset.isDark ? 0.18 : 0.04),
                  ],
                  stops: const [0.0, 0.35, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            top: -50,
            left: -30,
            child: _GlowOrb(
              size: 170,
              color: accent.withValues(alpha: preset.isDark ? 0.10 : 0.08),
            ),
          ),
          Positioned(
            bottom: -65,
            right: -20,
            child: _GlowOrb(
              size: 210,
              color: bgColor2.withValues(alpha: preset.isDark ? 0.25 : 0.12),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(52, 26, 52, 34),
              child: Column(
                children: [
                  Text(
                    surahName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: surahColor,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: Center(
                      child: AutoSizeText(
                        ayahText,
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        minFontSize: 20,
                        maxFontSize: fontSize,
                        maxLines: 4,
                        stepGranularity: 1,
                        overflow: TextOverflow.visible,
                        style: TextStyle(
                          color: textColor,
                          fontSize: fontSize,
                          fontFamily: fontFamily,
                          fontFamilyFallback: const [
                            "AmiriQuran-Regular",
                            "KFGQPC-Uthmanic-HAFS-Regular",
                          ],
                          height: 1.78,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(
                                alpha: preset.isDark ? 0.16 : 0.05,
                              ),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 22,
            right: 22,
            bottom: 18,
            child: Container(
              height: 1.2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    accent.withValues(alpha: 0.36),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
        ),
      ),
    );
  }
}
