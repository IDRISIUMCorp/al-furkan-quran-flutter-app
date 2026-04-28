import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bookmark.dart';

/// Bookmark Repository Interface — Abstract contract for bookmark data access
abstract class BookmarkRepository {
  /// Get all bookmarks
  Future<Either<Failure, List<Bookmark>>> getAllBookmarks();

  /// Get bookmarks by type
  Future<Either<Failure, List<Bookmark>>> getBookmarksByType(BookmarkType type);

  /// Add a new bookmark
  Future<Either<Failure, Bookmark>> addBookmark(Bookmark bookmark);

  /// Remove a bookmark by ID
  Future<Either<Failure, void>> removeBookmark(String id);

  /// Update a bookmark's note
  Future<Either<Failure, Bookmark>> updateBookmarkNote({
    required String id,
    required String note,
  });

  /// Check if an ayah is bookmarked
  Future<Either<Failure, bool>> isAyahBookmarked(String ayahKey);

  /// Toggle bookmark on an ayah
  Future<Either<Failure, bool>> toggleBookmark({
    required String ayahKey,
    required int surahId,
    required int ayahNumber,
    required int page,
    required BookmarkType type,
  });
}
