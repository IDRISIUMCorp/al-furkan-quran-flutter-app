/// Surah Entity — Pure Dart, ZERO Flutter imports
/// Represents a single Surah of the Holy Quran
class Surah {
  final int id;
  final String nameArabic;
  final String nameEnglish;
  final String nameTransliteration;
  final int totalAyahs;
  final int totalPages;
  final int startPage;
  final RevelationType revelationType;
  final int rukuCount;
  final int manzilOrder;
  final int sajdaCount;
  final SajdaType? sajdaType;

  const Surah({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.nameTransliteration,
    required this.totalAyahs,
    required this.totalPages,
    required this.startPage,
    required this.revelationType,
    this.rukuCount = 0,
    this.manzilOrder = 0,
    this.sajdaCount = 0,
    this.sajdaType,
  });

  /// Ayah key format: "surahId:ayahNumber" e.g. "1:1"
  String ayahKey(int ayahNumber) => '$id:$ayahNumber';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Surah && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

enum RevelationType {
  meccan,
  medinan,
}

enum SajdaType {
  obligatory,
  recommended,
}
