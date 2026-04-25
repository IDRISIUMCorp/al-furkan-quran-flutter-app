import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';

/// A beautiful card widget displaying surah metadata.
///
/// Shows surah name (Arabic), English name, verse count,
/// place of revelation, and revelation type icon.
///
/// Example:
/// ```dart
/// QcfSurahInfoCard(
///   surahNumber: 1,
///   onTap: () => navigateToSurah(1),
/// )
/// ```
class QcfSurahInfoCard extends StatelessWidget {
  /// 1-based surah number (1..114).
  final int surahNumber;

  /// Optional callback when the card is tapped.
  final VoidCallback? onTap;

  /// Whether to show the sajda indicator if the surah contains a sajda verse.
  /// Default: `true`
  final bool showSajdaIndicator;

  /// Custom text style for the Arabic surah name.
  final TextStyle? arabicNameStyle;

  /// Custom text style for the English surah name.
  final TextStyle? englishNameStyle;

  /// Custom background color. If null, uses theme's card color.
  final Color? backgroundColor;

  /// Border radius for the card. Default: `12.0`
  final double borderRadius;

  const QcfSurahInfoCard({
    super.key,
    required this.surahNumber,
    this.onTap,
    this.showSajdaIndicator = true,
    this.arabicNameStyle,
    this.englishNameStyle,
    this.backgroundColor,
    this.borderRadius = 12.0,
  }) : assert(surahNumber >= 1 && surahNumber <= 114);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final arabicName = getSurahNameArabic(surahNumber);
    final englishName = getSurahNameEnglish(surahNumber);
    final verseCount = getVerseCount(surahNumber);
    final place = getPlaceOfRevelation(surahNumber);
    final isMakki = place == 'Makkah';
    final hasSajda = showSajdaIndicator && _surahHasSajda(surahNumber);

    final defaultBg = isDark
        ? const Color(0xFF1E1E1E)
        : const Color(0xFFF5F0E8);
    final bg = backgroundColor ?? defaultBg;

    final defaultArabicStyle = arabicNameStyle ??
        TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white : const Color(0xFF1B1B1B),
        );
    final defaultEnglishStyle = englishNameStyle ??
        TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: isDark
              ? Colors.white.withValues(alpha: 0.6)
              : const Color(0xFF6D4C41),
        );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              // Surah number badge
              _SurahNumberBadge(
                surahNumber: surahNumber,
                isMakki: isMakki,
              ),
              const SizedBox(width: 14),
              // Surah info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            arabicName,
                            style: defaultArabicStyle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasSajda) ...[
                          const SizedBox(width: 6),
                          _SajdaBadge(isDark: isDark),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          englishName,
                          style: defaultEnglishStyle,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: defaultEnglishStyle,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$verseCount آية',
                          style: defaultEnglishStyle.copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Revelation type icon
              Icon(
                isMakki ? Icons.mosque_outlined : Icons.domain_outlined,
                size: 18,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.4)
                    : const Color(0xFF8D6E63),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _surahHasSajda(int surahNumber) {
    return allSajdaVerses.any((s) => s.surah == surahNumber);
  }
}

class _SurahNumberBadge extends StatelessWidget {
  final int surahNumber;
  final bool isMakki;

  const _SurahNumberBadge({
    required this.surahNumber,
    required this.isMakki,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = isMakki
        ? (isDark ? const Color(0xFF80CBC4) : const Color(0xFF73877B))
        : (isDark ? const Color(0xFFFFB74D) : const Color(0xFF8D6E63));

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          surahNumber.toString(),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: accentColor,
          ),
        ),
      ),
    );
  }
}

class _SajdaBadge extends StatelessWidget {
  final bool isDark;

  const _SajdaBadge({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFFCE93D8) : const Color(0xFFAB47BC))
            .withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'سجدة',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFFCE93D8) : const Color(0xFF7B1FA2),
        ),
      ),
    );
  }
}
