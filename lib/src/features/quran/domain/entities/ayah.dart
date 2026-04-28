/// Ayah Entity — Pure Dart, ZERO Flutter imports
/// Represents a single Ayah of the Holy Quran
class Ayah {
  final String key;
  final int surahId;
  final int ayahNumber;
  final int page;
  final int juz;
  final int hizb;
  final int ruku;
  final int manzil;
  final int sajdah;
  final String textUthmani;
  final String textIndopak;
  final String textImlai;

  const Ayah({
    required this.key,
    required this.surahId,
    required this.ayahNumber,
    required this.page,
    required this.juz,
    required this.hizb,
    required this.ruku,
    this.manzil = 0,
    this.sajdah = 0,
    required this.textUthmani,
    required this.textIndopak,
    required this.textImlai,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Ayah && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;
}
