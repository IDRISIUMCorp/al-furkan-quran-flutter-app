import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';
import '../qcf_theme_data.dart';

/// Classic mushaf header with surah name and verse count.
///
/// Traditional header style matching printed Quran pages:
/// - Surah name in the center
/// - Verse count on the right
/// - Decorative border
class ClassicMushafHeader extends StatelessWidget {
  final int surahNumber;
  final QcfThemeData theme;

  const ClassicMushafHeader({
    super.key,
    required this.surahNumber,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (!theme.useClassicBorder) return const SizedBox.shrink();

    final surahName = getSurahNameArabic(surahNumber);
    final verseCount = getVerseCount(surahNumber);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.headerFooterBackground,
        border: Border(
          bottom: BorderSide(
            color: theme.borderColor,
            width: theme.borderWidth,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Surah name (centered)
          Expanded(
            child: Text(
              surahName,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'surah-name-v2',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.borderColor,
                height: 1.2,
              ),
            ),
          ),
          // Verse count (right side)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: theme.borderColor, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$verseCount آيات',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.borderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Classic mushaf footer with page number and juz info.
///
/// Traditional footer style matching printed Quran pages:
/// - Page number in the center
/// - Juz number on the right
/// - Decorative border
class ClassicMushafFooter extends StatelessWidget {
  final int pageNumber;
  final int surahNumber;
  final int startVerse;
  final QcfThemeData theme;

  const ClassicMushafFooter({
    super.key,
    required this.pageNumber,
    required this.surahNumber,
    required this.startVerse,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    if (!theme.useClassicBorder) return const SizedBox.shrink();

    final juzNumber = getJuzNumber(surahNumber, startVerse);
    final arabicNum = _toArabicNumerals(pageNumber);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: theme.headerFooterBackground,
        border: Border(
          top: BorderSide(
            color: theme.borderColor,
            width: theme.borderWidth,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Page number (centered)
          Expanded(
            child: Text(
              'صفحة $arabicNum',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: theme.borderColor,
              ),
            ),
          ),
          // Juz number (right side)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: theme.borderColor, width: 1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'الجزء ${_toArabicNumerals(juzNumber)}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: theme.borderColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _toArabicNumerals(int number) {
    const arabicNums = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((d) => arabicNums[int.parse(d)]).join();
  }
}
