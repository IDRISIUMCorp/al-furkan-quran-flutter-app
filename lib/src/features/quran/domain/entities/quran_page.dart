/// Quran Page Entity — Pure Dart, ZERO Flutter imports
/// Represents a single page of the Mushaf (604 pages total)
class QuranPage {
  final int pageNumber;
  final List<AyahOnPage> ayahs;
  final int surahIdStart;
  final int surahIdEnd;
  final int juz;

  const QuranPage({
    required this.pageNumber,
    required this.ayahs,
    required this.surahIdStart,
    required this.surahIdEnd,
    required this.juz,
  });
}

/// Lightweight ayah reference on a page
class AyahOnPage {
  final String key;
  final int surahId;
  final int ayahNumber;
  final String text;

  const AyahOnPage({
    required this.key,
    required this.surahId,
    required this.ayahNumber,
    required this.text,
  });
}
