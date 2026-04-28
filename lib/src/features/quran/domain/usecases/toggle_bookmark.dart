import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bookmark.dart';
import '../repositories/bookmark_repository.dart';

/// Toggle Bookmark Use Case — Single Responsibility: toggle bookmark on/off
class ToggleBookmarkUseCase {
  final BookmarkRepository _repository;
  ToggleBookmarkUseCase(this._repository);

  Future<Either<Failure, bool>> call({
    required String ayahKey,
    required int surahId,
    required int ayahNumber,
    required int page,
    required BookmarkType type,
  }) =>
      _repository.toggleBookmark(
        ayahKey: ayahKey,
        surahId: surahId,
        ayahNumber: ayahNumber,
        page: page,
        type: type,
      );
}
