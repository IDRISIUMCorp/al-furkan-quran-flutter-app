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

/// Ayah Widget Design for Home Screen Widget
/// Renders the ayah display with customizable styling
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
      primaryBackground: Color(0xFF101010),
      secondaryBackground: Color(0xFF222222),
      accent: Color(0xFF65C1A8),
      textColor: Colors.white,
      surahColor: Color(0xFFBFF4E6),
      prefersGradient: true,
    ),
    AyahWidgetThemePreset(
      id: "dark_royal",
      name: "ملكي ذهبي",
      isDark: true,
      primaryBackground: Color(0xFF140F08),
      secondaryBackground: Color(0xFF2A1E11),
      accent: Color(0xFFE0B15D),
      textColor: Color(0xFFFFF4DF),
      surahColor: Color(0xFFF8D89A),
      prefersGradient: true,
    ),
    AyahWidgetThemePreset(
      id: "midnight_blue",
      name: "ليل أزرق",
      isDark: true,
      primaryBackground: Color(0xFF0C1A28),
      secondaryBackground: Color(0xFF17324A),
      accent: Color(0xFF73B8FF),
      textColor: Color(0xFFF2F8FF),
      surahColor: Color(0xFFB6D9FF),
      prefersGradient: true,
    ),
    AyahWidgetThemePreset(
      id: "emerald_gradient",
      name: "زمردي",
      isDark: true,
      primaryBackground: Color(0xFF0D1F18),
      secondaryBackground: Color(0xFF163429),
      accent: Color(0xFF58C19B),
      textColor: Color(0xFFF0FFF9),
      surahColor: Color(0xFFB8F4DF),
      prefersGradient: true,
    ),
    AyahWidgetThemePreset(
      id: "sunset",
      name: "غروب دافئ",
      isDark: true,
      primaryBackground: Color(0xFF351722),
      secondaryBackground: Color(0xFF6A2D30),
      accent: Color(0xFFFFB067),
      textColor: Color(0xFFFFF3E6),
      surahColor: Color(0xFFFFD5AE),
      prefersGradient: true,
    ),
    AyahWidgetThemePreset(
      id: "glass_light",
      name: "زجاجي فاتح",
      isDark: false,
      primaryBackground: Color(0xFFF9F4EC),
      secondaryBackground: Color(0xFFEFE5D5),
      accent: Color(0xFF9B7B4E),
      textColor: Color(0xFF2A2118),
      surahColor: Color(0xFF7F5E34),
      prefersGradient: true,
    ),
    AyahWidgetThemePreset(
      id: "ocean_night",
      name: "محيط ليلي",
      isDark: true,
      primaryBackground: Color(0xFF071821),
      secondaryBackground: Color(0xFF0E3642),
      accent: Color(0xFF6EE7E7),
      textColor: Color(0xFFEFFFFF),
      surahColor: Color(0xFFABF7F7),
      prefersGradient: true,
    ),
    AyahWidgetThemePreset(
      id: "sand",
      name: "رملي هادئ",
      isDark: false,
      primaryBackground: Color(0xFFF5E8D4),
      secondaryBackground: Color(0xFFEAD8BC),
      accent: Color(0xFF9C6F3A),
      textColor: Color(0xFF3C2D1D),
      surahColor: Color(0xFF7A5529),
      prefersGradient: true,
    ),
  ];

  static AyahWidgetThemePreset themeById(String id) {
    return availableThemes.firstWhere(
      (preset) => preset.id == id,
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
    final accent = primaryColor;
    final shouldUseGradient = isGradientBg || preset.prefersGradient;
    final surface = preset.isDark ? Colors.white : Colors.black;

    return Container(
      width: 800,
      height: 400,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: shouldUseGradient
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [bgColor, bgColor2],
              )
            : null,
        color: shouldUseGradient ? null : bgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: surface.withValues(alpha: preset.isDark ? 0.08 : 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: preset.isDark ? 0.18 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildDecorations(accent, preset, bgColor2),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: preset.isDark ? 0.04 : 0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: preset.isDark ? 0.08 : 0.35,
                ),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: accent.withValues(alpha: 0.20)),
              ),
              child: Text(
                surahName,
                style: TextStyle(
                  color: surahColor,
                  fontSize: fontSize * 0.42,
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            left: 18,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.16),
                shape: BoxShape.circle,
                border: Border.all(color: accent.withValues(alpha: 0.22)),
              ),
              alignment: Alignment.center,
              child: Text(
                _toArabicDigits(ayahNumber.toString()),
                style: TextStyle(
                  color: accent,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 54),
              child: Text(
                ayahText,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontFamily: fontFamily,
                  height: 1.85,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(
                        alpha: preset.isDark ? 0.12 : 0.06,
                      ),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          ),
          Positioned(
            bottom: 18,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: preset.isDark ? 0.07 : 0.30,
                ),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_stories_rounded,
                    size: 14,
                    color: accent.withValues(alpha: 0.72),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "الفرقان",
                    style: TextStyle(
                      color: accent.withValues(alpha: 0.72),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorations(
    Color accent,
    AyahWidgetThemePreset preset,
    Color secondary,
  ) {
    return Stack(
      children: [
        Positioned(
          top: -32,
          right: -20,
          child: _softOrb(size: 150, color: accent.withValues(alpha: 0.14)),
        ),
        Positioned(
          bottom: -56,
          left: -8,
          child: _softOrb(
            size: 180,
            color: secondary.withValues(alpha: preset.isDark ? 0.36 : 0.44),
          ),
        ),
        Positioned(
          top: 110,
          left: 36,
          right: 36,
          child: Container(
            height: 1.2,
            color: Colors.white.withValues(alpha: preset.isDark ? 0.04 : 0.16),
          ),
        ),
      ],
    );
  }

  Widget _softOrb({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }

  String _toArabicDigits(String number) {
    const arabics = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"];
    final buffer = StringBuffer();
    for (final ch in number.split("")) {
      final digit = int.tryParse(ch);
      if (digit == null) {
        buffer.write(ch);
      } else {
        buffer.write(arabics[digit]);
      }
    }
    return buffer.toString();
  }
}
