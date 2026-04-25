import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';

/// A sleek, Apple-style page position indicator for the mushaf.
///
/// Shows current Juz, Hizb, and page number in a compact pill.
/// Designed to float at the top or bottom of the mushaf view.
///
/// Example:
/// ```dart
/// QcfPagePositionIndicator(
///   currentPage: 42,
///   onPageChanged: (page) => controller.animateToPage(page - 1),
/// )
/// ```
class QcfPagePositionIndicator extends StatelessWidget {
  /// Current 1-based page number (1..604).
  final int currentPage;

  /// Optional callback when user taps the indicator to change page.
  final ValueChanged<int>? onPageChanged;

  /// Theme configuration.
  final QcfThemeData? theme;

  /// Whether to show the Juz number. Default: `true`
  final bool showJuz;

  /// Whether to show the Hizb number. Default: `true`
  final bool showHizb;

  /// Whether to show the Surah name. Default: `true`
  final bool showSurah;

  /// Position of the indicator on screen.
  final IndicatorPosition position;

  const QcfPagePositionIndicator({
    super.key,
    required this.currentPage,
    this.onPageChanged,
    this.theme,
    this.showJuz = true,
    this.showHizb = true,
    this.showSurah = true,
    this.position = IndicatorPosition.top,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? const QcfThemeData();
    final isDark = ThemeData.estimateBrightnessForColor(
            effectiveTheme.pageBackgroundColor) ==
        Brightness.dark;

    final juzNum = getJuzNumberFromPage(currentPage);
    final surahNames = _getSurahNamesForPage(currentPage);
    final hizbInfo = _getHizbForPage(currentPage);

    final bgColor = isDark
        ? const Color(0xFF2C2C2C).withValues(alpha: 0.9)
        : const Color(0xFFF5EBE0).withValues(alpha: 0.92);
    final textColor =
        isDark ? const Color(0xFFE0E0E0) : const Color(0xFF3E2723);
    final subColor = isDark
        ? Colors.white.withValues(alpha: 0.5)
        : const Color(0xFF8D6E63);

    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showJuz && juzNum != null) ...[
            _PillSegment(
              label: 'الجزء',
              value: '$juzNum',
              color: const Color(0xFF73877B),
              isDark: isDark,
            ),
            _DotDivider(color: subColor),
          ],
          if (showSurah && surahNames.isNotEmpty) ...[
            Flexible(
              child: Text(
                surahNames,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            _DotDivider(color: subColor),
          ],
          if (showHizb && hizbInfo != null) ...[
            _PillSegment(
              label: 'الحزب',
              value: hizbInfo,
              color: const Color(0xFF8D6E63),
              isDark: isDark,
            ),
            _DotDivider(color: subColor),
          ],
          Text(
            '$currentPage',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            ' / $totalPagesCount',
            style: TextStyle(
              fontSize: 10,
              color: subColor,
            ),
          ),
        ],
      ),
    );

    return Positioned(
      top: position == IndicatorPosition.top ? 8 : null,
      bottom: position == IndicatorPosition.bottom ? 8 : null,
      left: 0,
      right: 0,
      child: Center(
        child: GestureDetector(
          onTap: onPageChanged != null
              ? () {
                  // Simple tap cycles to next page
                  final next = currentPage < totalPagesCount
                      ? currentPage + 1
                      : 1;
                  onPageChanged!(next);
                }
              : null,
          child: content,
        ),
      ),
    );
  }

  int? getJuzNumberFromPage(int page) {
    try {
      final data = getPageData(page);
      if (data.isNotEmpty) {
        final firstSurah = data[0]['surah'] as int;
        final firstVerse = data[0]['start'] as int;
        return getJuzNumber(firstSurah, firstVerse);
      }
    } catch (_) {}
    return null;
  }

  String _getSurahNamesForPage(int page) {
    try {
      final data = getPageData(page);
      final names = <String>{};
      for (final entry in data) {
        final surahNum = entry['surah'] as int;
        names.add(getSurahNameArabic(surahNum));
      }
      return names.join(' ◆ ');
    } catch (_) {}
    return '';
  }

  String? _getHizbForPage(int page) {
    try {
      for (int q = 0; q < quarters.length; q++) {
        if (q % 2 == 0) {
          final surah = quarters[q]['surah'] as int;
          final ayah = quarters[q]['ayah'] as int;
          final qPage = getPageNumber(surah, ayah);
          if (qPage == page) {
            return '${(q ~/ 2) + 1}';
          }
        }
      }
    } catch (_) {}
    return null;
  }
}

class _PillSegment extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final bool isDark;

  const _PillSegment({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: isDark ? 0.8 : 1.0),
            ),
          ),
          const SizedBox(width: 3),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.9)
                  : const Color(0xFF3E2723),
            ),
          ),
        ],
      ),
    );
  }
}

class _DotDivider extends StatelessWidget {
  final Color color;
  const _DotDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '·',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Position options for [QcfPagePositionIndicator].
enum IndicatorPosition { top, bottom }
