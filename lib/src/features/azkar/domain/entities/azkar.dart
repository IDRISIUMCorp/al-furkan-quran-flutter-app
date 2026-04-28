/// Azkar Category Entity — Pure Dart, ZERO Flutter imports
class AzkarCategory {
  final int id;
  final String nameArabic;
  final String nameEnglish;
  final String iconKey;
  final int azkarCount;

  const AzkarCategory({
    required this.id,
    required this.nameArabic,
    required this.nameEnglish,
    required this.iconKey,
    required this.azkarCount,
  });
}

/// Azkar Item Entity — a single zikr
class AzkarItem {
  final int id;
  final int categoryId;
  final String textArabic;
  final String? textTransliteration;
  final String? textTranslation;
  final int count; // Number of times to repeat
  final String? reference; // Hadith/source reference
  final AzkarType type;
  final String? audioAsset;

  const AzkarItem({
    required this.id,
    required this.categoryId,
    required this.textArabic,
    this.textTransliteration,
    this.textTranslation,
    required this.count,
    this.reference,
    required this.type,
    this.audioAsset,
  });
}

enum AzkarType {
  morning,     // أذكار الصباح
  evening,     // أذكار المساء
  prayer,      // أذكار الصلاة
  sleep,       // أذكار النوم
  wakeup,      // أذكار الاستيقاظ
  general,     // أذكار عامة
  quran,       // أذكار من القرآن
  ruqyah,      // الرقية الشرعية
}
