import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkTheme();
    final bgColor = customBgColor ?? (isDark ? const Color(0xFF0A0A0A) : const Color(0xFFFDFAF5));
    final bgColor2 = customBgColor2 ?? (isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF5F0E8));
    final textColor = customTextColor ?? (isDark ? Colors.white : Colors.black87);
    final surahColor = customSurahColor ?? primaryColor;

    return Container(
      width: 800,
      height: 400,
      decoration: BoxDecoration(
        gradient: isGradientBg
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [bgColor, bgColor2],
              )
            : null,
        color: isGradientBg ? null : bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Decorative Elements
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                surahName,
                style: TextStyle(
                  color: surahColor,
                  fontSize: fontSize * 0.5,
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),

          // Ayah Number Badge
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                _toArabicDigits(ayahNumber.toString()),
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Main Ayah Text
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Text(
                ayahText,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontFamily: fontFamily,
                  height: 1.8,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          ),

          // Branding
          Positioned(
            bottom: 16,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  size: 14,
                  color: primaryColor.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  'الفُرقان',
                  style: TextStyle(
                    color: primaryColor.withValues(alpha: 0.6),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isDarkTheme() {
    final darkThemes = ['glass_dark', 'dark_royal', 'midnight_blue', 'emerald_gradient', 'sunset', 'ocean_night', 'forest_green'];
    return darkThemes.contains(themeId);
  }

  String _toArabicDigits(String number) {
    const arabics = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    final buffer = StringBuffer();
    for (final ch in number.split('')) {
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
