import 'package:flutter/material.dart';

class AyahWidgetDesign extends StatelessWidget {
  final String ayahText;
  final String surahName;
  final double fontSize;
  final Color primaryColor;
  final String themeId;
  final String? fontFamily;
  final Color? customBgColor;
  final Color? customBgColor2;
  final bool isGradientBg;
  final Color? customTextColor;
  final Color? customSurahColor;

  const AyahWidgetDesign({
    super.key,
    required this.ayahText,
    required this.surahName,
    this.fontSize = 24,
    this.primaryColor = const Color(0xFF6C63FF),
    this.themeId = 'glass_dark',
    this.fontFamily,
    this.customBgColor,
    this.customBgColor2,
    this.isGradientBg = false,
    this.customTextColor,
    this.customSurahColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeId.contains('dark');
    final bg = customBgColor ?? (isDark ? const Color(0xFF1A1A2E) : const Color(0xFFF5F5F5));
    final bg2 = customBgColor2 ?? (isDark ? const Color(0xFF16213E) : const Color(0xFFE8E8E8));
    final txtColor = customTextColor ?? (isDark ? Colors.white : const Color(0xFF1B1B1B));
    final surahColor = customSurahColor ?? primaryColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: isGradientBg
          ? BoxDecoration(
              gradient: LinearGradient(
                colors: [bg, bg2],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            )
          : BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ayah Text
          Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              ayahText,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: fontFamily ?? 'AmiriQuran',
                fontSize: fontSize,
                color: txtColor,
                height: 2.0,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 16),
          // Surah Name & Ayah Number
          Directionality(
            textDirection: TextDirection.rtl,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: surahColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    surahName,
                    style: TextStyle(
                      color: surahColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Branding
          Opacity(
            opacity: 0.5,
            child: Text(
              'الفُرقان',
              style: TextStyle(
                color: txtColor,
                fontSize: 12,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AyahWidgetPreview extends StatefulWidget {
  const AyahWidgetPreview({super.key});

  @override
  State<AyahWidgetPreview> createState() => _AyahWidgetPreviewState();
}

class _AyahWidgetPreviewState extends State<AyahWidgetPreview> {
  double _fontSize = 24;
  bool _isDarkMode = true;
  String _fontFamily = 'AmiriQuran';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Preview
        AyahWidgetDesign(
          ayahText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          surahName: 'الفاتحة',
          fontSize: _fontSize,
          primaryColor: const Color(0xFF6C63FF),
          themeId: _isDarkMode ? 'glass_dark' : 'glass_light',
          fontFamily: _fontFamily,
        ),
        const SizedBox(height: 20),
        // Controls
        Row(
          children: [
            const Text('حجم الخط:'),
            Expanded(
              child: Slider(
                value: _fontSize,
                min: 16,
                max: 40,
                onChanged: (v) => setState(() => _fontSize = v),
              ),
            ),
            Text('${_fontSize.toInt()}'),
          ],
        ),
        SwitchListTile(
          title: const Text('الوضع الداكن'),
          value: _isDarkMode,
          onChanged: (v) => setState(() => _isDarkMode = v),
        ),
      ],
    );
  }
}
