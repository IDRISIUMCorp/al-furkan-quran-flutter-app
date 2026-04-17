import "package:flutter/material.dart";

class PrayerWidgetDesign extends StatelessWidget {
  static const Size canvasSize = Size(960, 300);

  final String themeId;
  final String prayerDisplayMode; 
  final Map<String, String>? prayerTimes; 
  final String? nextPrayerName;
  final bool isDark;

  const PrayerWidgetDesign({
    super.key,
    required this.themeId,
    required this.prayerDisplayMode,
    this.prayerTimes,
    this.nextPrayerName,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Basic dynamic theme handling
    final Color bgColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA);
    final Color textColor = isDark ? const Color(0xFFF5F5F5) : const Color(0xFF2C2A29);
    final Color borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE8E4DF);
    final Color accentColor = isDark ? const Color(0xFF33B18E) : const Color(0xFF5A7063);
    final Color surahColor = isDark ? const Color(0xFF9E9E9E) : const Color(0xFF8B8178);

    return Container(
      width: canvasSize.width,
      height: canvasSize.height,
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(42),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Center(
        child: _buildPrayerSection(textColor, surahColor, accentColor, borderColor),
      ),
    );
  }

  Widget _buildPrayerSection(Color textColor, Color surahColor, Color accentColor, Color borderColor) {
    if (prayerDisplayMode == "next" && nextPrayerName != null && prayerTimes != null) {
      final time = prayerTimes![nextPrayerName] ?? "";
      if (time.isEmpty) return const SizedBox.shrink();

      return Row(
        mainAxisSize: MainAxisSize.min,
        textDirection: TextDirection.rtl,
        children: [
          Icon(Icons.access_time_rounded, color: accentColor, size: 60),
          const SizedBox(width: 24),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "الصلاة القادمة: $nextPrayerName",
                style: TextStyle(
                  fontFamily: "Cairo-SemiBold",
                  fontSize: 32,
                  color: textColor.withValues(alpha: 0.9),
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  fontFamily: "Cairo-Bold",
                  fontSize: 48,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ],
      );
    } else if (prayerDisplayMode == "all" && prayerTimes != null) {
      final orderedPrayers = ["الفجر", "الشروق", "الظهر", "العصر", "المغرب", "العشاء"];
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        textDirection: TextDirection.rtl,
        children: orderedPrayers.map((prayer) {
          final isNext = nextPrayerName == prayer;
          final time = prayerTimes![prayer] ?? "-";
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                prayer,
                style: TextStyle(
                  fontFamily: isNext ? "Cairo-Bold" : "Cairo-Medium",
                  fontSize: isNext ? 28 : 22,
                  color: isNext ? accentColor : surahColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: isNext ? const EdgeInsets.symmetric(horizontal: 24, vertical: 8) : null,
                decoration: isNext ? BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ) : null,
                child: Text(
                  time,
                  style: TextStyle(
                    fontFamily: "Cairo-Bold",
                    fontSize: isNext ? 32 : 24,
                    color: isNext ? textColor : surahColor.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      );
    }
    return const SizedBox.shrink();
  }
}
