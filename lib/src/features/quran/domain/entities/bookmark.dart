/// Bookmark Entity — Pure Dart, ZERO Flutter imports
class Bookmark {
  final String id;
  final String ayahKey;
  final int surahId;
  final int ayahNumber;
  final int page;
  final DateTime createdAt;
  final String? note;
  final BookmarkType type;

  const Bookmark({
    required this.id,
    required this.ayahKey,
    required this.surahId,
    required this.ayahNumber,
    required this.page,
    required this.createdAt,
    this.note,
    required this.type,
  });
}

enum BookmarkType {
  bookmark,
  starred,
  note,
  hifz,
}
