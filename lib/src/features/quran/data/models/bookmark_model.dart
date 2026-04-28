import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/entities.dart';

part 'bookmark_model.freezed.dart';
part 'bookmark_model.g.dart';

/// Bookmark Data Model — freezed + json_serializable for data layer
@freezed
class BookmarkModel with _$BookmarkModel {
  const BookmarkModel._();

  const factory BookmarkModel({
    required String id,
    required String ayahKey,
    required int surahId,
    required int ayahNumber,
    required int page,
    required DateTime createdAt,
    @Default(null) String? note,
    required String type,
  }) = _BookmarkModel;

  factory BookmarkModel.fromJson(Map<String, dynamic> json) =>
      _$BookmarkModelFromJson(json);

  Bookmark toDomain() => Bookmark(
        id: id,
        ayahKey: ayahKey,
        surahId: surahId,
        ayahNumber: ayahNumber,
        page: page,
        createdAt: createdAt,
        note: note,
        type: _mapType(type),
      );

  static BookmarkModel fromDomain(Bookmark bookmark) => BookmarkModel(
        id: bookmark.id,
        ayahKey: bookmark.ayahKey,
        surahId: bookmark.surahId,
        ayahNumber: bookmark.ayahNumber,
        page: bookmark.page,
        createdAt: bookmark.createdAt,
        note: bookmark.note,
        type: bookmark.type.name,
      );

  static BookmarkType _mapType(String type) {
    switch (type) {
      case 'starred':
        return BookmarkType.starred;
      case 'note':
        return BookmarkType.note;
      case 'hifz':
        return BookmarkType.hifz;
      default:
        return BookmarkType.bookmark;
    }
  }
}
