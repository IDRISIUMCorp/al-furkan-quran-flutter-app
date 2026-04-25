import 'package:qcf_quran/src/data/page_data.dart';

/// The 14+1 Sajdah (prostration) verses.
///
/// 14 are agreed upon by the majority of scholars as Sajdah Tilawah (واجبة).
/// Surah Sad 38:24 is disputed — considered Sajdah Shukr by some (مستحبة).
const List<({int surah, int verse, String type})> _sajdaVerses = [
  (surah: 7, verse: 206, type: 'واجبة'),   // Al-A'raf
  (surah: 13, verse: 15, type: 'واجبة'),   // Ar-Ra'd
  (surah: 16, verse: 50, type: 'واجبة'),   // An-Nahl
  (surah: 17, verse: 109, type: 'واجبة'),  // Al-Isra
  (surah: 19, verse: 58, type: 'واجبة'),   // Maryam
  (surah: 22, verse: 18, type: 'واجبة'),   // Al-Hajj
  (surah: 22, verse: 77, type: 'واجبة'),   // Al-Hajj (2nd sajda)
  (surah: 25, verse: 60, type: 'واجبة'),   // Al-Furqan
  (surah: 27, verse: 26, type: 'واجبة'),   // An-Naml
  (surah: 32, verse: 15, type: 'واجبة'),   // As-Sajdah
  (surah: 38, verse: 24, type: 'مستحبة'),  // Sad (sajda shukr — disputed)
  (surah: 41, verse: 38, type: 'واجبة'),   // Fussilat
  (surah: 53, verse: 62, type: 'واجبة'),   // An-Najm
  (surah: 84, verse: 21, type: 'واجبة'),   // Al-Inshiqaq
  (surah: 96, verse: 19, type: 'واجبة'),   // Al-Alaq
];

/// Returns `true` if the given [surahNumber] and [verseNumber] is a Sajdah verse.
///
/// Includes the 14 consensus sajdas plus Surah Sad 38:24 (disputed).
bool isSajdaVerse(int surahNumber, int verseNumber) {
  return _sajdaVerses.any(
    (s) => s.surah == surahNumber && s.verse == verseNumber,
  );
}

/// Returns the sajda type for the given verse, or `null` if not a sajda verse.
///
/// Types:
/// - `'واجبة'` — obligatory prostration (majority view)
/// - `'مستحبة'` — recommended prostration (disputed, e.g. Sad 38:24)
String? getSajdaType(int surahNumber, int verseNumber) {
  for (final s in _sajdaVerses) {
    if (s.surah == surahNumber && s.verse == verseNumber) {
      return s.type;
    }
  }
  return null;
}

/// Returns all sajda verses as an unmodifiable list.
List<({int surah, int verse, String type})> get allSajdaVerses =>
    List.unmodifiable(_sajdaVerses);

/// Returns all sajda verses on a given [pageNumber] (1..604).
///
/// Useful for rendering sajda indicators on specific mushaf pages.
List<({int surah, int verse, String type})> getSajdaVersesByPage(
    int pageNumber) {
  if (pageNumber < 1 || pageNumber > 604) return const [];
  return _sajdaVerses.where((s) {
    try {
      final page = _lookupPageNumber(s.surah, s.verse);
      return page == pageNumber;
    } catch (_) {
      return false;
    }
  }).toList();
}

int _lookupPageNumber(int surahNumber, int verseNumber) {
  for (int pageIndex = 0; pageIndex < pageData.length; pageIndex++) {
    for (int surahIndexInPage = 0;
        surahIndexInPage < pageData[pageIndex].length;
        surahIndexInPage++) {
      final e = pageData[pageIndex][surahIndexInPage];
      if (e['surah'] == surahNumber &&
          e['start'] <= verseNumber &&
          e['end'] >= verseNumber) {
        return pageIndex + 1;
      }
    }
  }
  throw "Invalid verse number.";
}
