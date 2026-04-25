import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';

/// A lightweight overlay widget that marks Juz and Hizb boundaries
/// on a mushaf page.
///
/// Place this as a Stack layer on top of the QcfPage content.
/// It renders small, elegant markers at the exact position where
/// a new Juz or Hizb begins on the page.
///
/// Example:
/// ```dart
/// Stack(
///   children: [
///     QcfPage(pageNumber: page, ...),
///     QcfJuzHizbMarker(pageNumber: page),
///   ],
/// )
/// ```
class QcfJuzHizbMarker extends StatelessWidget {
  /// The 1-based page number (1..604).
  final int pageNumber;

  /// Theme configuration for marker styling.
  final QcfThemeData? theme;

  /// Whether to show Juz markers. Default: `true`
  final bool showJuz;

  /// Whether to show Hizb markers. Default: `true`
  final bool showHizb;

  /// Whether to show Quarter (Rub) markers. Default: `false`
  final bool showQuarter;

  /// Alignment override for marker position.
  /// Default: `Alignment.topRight` (RTL convention)
  final Alignment markerAlignment;

  const QcfJuzHizbMarker({
    super.key,
    required this.pageNumber,
    this.theme,
    this.showJuz = true,
    this.showHizb = true,
    this.showQuarter = false,
    this.markerAlignment = Alignment.topRight,
  });

  @override
  Widget build(BuildContext context) {
    final markers = _getMarkersForPage(pageNumber);
    if (markers.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: markerAlignment,
      child: Padding(
        padding: const EdgeInsets.only(top: 4, right: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: markers
              .map((m) => _MarkerChip(
                    label: m.label,
                    color: m.color,
                    isDark: _isDark(context),
                  ))
              .toList(),
        ),
      ),
    );
  }

  bool _isDark(BuildContext context) {
    final effectiveTheme = theme ?? const QcfThemeData();
    return ThemeData.estimateBrightnessForColor(
            effectiveTheme.pageBackgroundColor) ==
        Brightness.dark;
  }

  List<_MarkerInfo> _getMarkersForPage(int page) {
    final markers = <_MarkerInfo>[];

    // Check Juz boundaries — find which juz starts on this page
    if (showJuz) {
      try {
        final data = getPageData(page);
        if (data.isNotEmpty) {
          final firstSurah = data[0]['surah'] as int;
          final firstVerse = data[0]['start'] as int;
          final juzNum = getJuzNumber(firstSurah, firstVerse);
          // Check if this is the START of the juz (first page where it appears)
          // by verifying against the previous page
          bool isJuzStart = true;
          if (page > 1) {
            try {
              final prevData = getPageData(page - 1);
              if (prevData.isNotEmpty) {
                final prevSurah = prevData.last['surah'] as int;
                final prevVerse = prevData.last['end'] as int;
                final prevJuz = getJuzNumber(prevSurah, prevVerse);
                isJuzStart = prevJuz != juzNum;
              }
            } catch (_) {}
          }
          if (isJuzStart) {
            markers.add(_MarkerInfo(
              label: 'الجزء $juzNum',
              color: const Color(0xFF73877B), // Sage green
            ));
          }
        }
      } catch (_) {}
    }

    // Check Hizb boundaries (every 2 quarters = 1 hizb)
    if (showHizb) {
      for (int q = 0; q < quarters.length; q++) {
        // Hizb starts at every even quarter index (0, 2, 4, ...)
        if (q % 2 == 0) {
          final hizbNum = (q ~/ 2) + 1;
          final surah = quarters[q]['surah'] as int;
          final ayah = quarters[q]['ayah'] as int;
          try {
            final qPage = getPageNumber(surah, ayah);
            if (qPage == page) {
              markers.add(_MarkerInfo(
                label: 'الحزب $hizbNum',
                color: const Color(0xFF8D6E63), // Warm brown
              ));
            }
          } catch (_) {}
        }
      }
    }

    // Check Quarter boundaries
    if (showQuarter) {
      for (int q = 0; q < quarters.length; q++) {
        final quarterNum = q + 1;
        final surah = quarters[q]['surah'] as int;
        final ayah = quarters[q]['ayah'] as int;
        final qPage = getPageNumber(surah, ayah);
        if (qPage == page) {
          markers.add(_MarkerInfo(
            label: 'الربع $quarterNum',
            color: const Color(0xFF90A4AE), // Blue grey
          ));
        }
      }
    }

    return markers;
  }
}

class _MarkerInfo {
  final String label;
  final Color color;
  const _MarkerInfo({required this.label, required this.color});
}

class _MarkerChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool isDark;

  const _MarkerChip({
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.25),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: isDark
              ? Color.lerp(Colors.white, color, 0.3)
              : color,
          height: 1.3,
        ),
      ),
    );
  }
}
