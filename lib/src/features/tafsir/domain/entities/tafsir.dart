/// Tafsir Entity — Pure Dart, ZERO Flutter imports
class Tafsir {
  final int id;
  final String nameArabic;
  final String nameEnglish;
  final String authorArabic;
  final String authorEnglish;
  final String languageCode;
  final TafsirType type;
  final bool isOfflineAvailable;

  const Tafsir({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.authorArabic,
    required this.authorEnglish,
    required this.languageCode,
    required this.type,
    this.isOfflineAvailable = false,
  });
}

enum TafsirType {
  tafsir,       // Exegesis — meaning and context
  translation,  // Direct translation
  wordByWord,   // Word-level breakdown
  irab,         // Grammatical analysis (I'rab)
}

/// Tafsir Entry — a single ayah's tafsir/translation content
class TafsirEntry {
  final String ayahKey;
  final int tafsirId;
  final String text;
  final String? footnotes;

  const TafsirEntry({
    required this.ayahKey,
    required this.tafsirId,
    required this.text,
    this.footnotes,
  });
}
