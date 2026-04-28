import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/entities.dart';

/// Quran Repository Interface — Abstract contract for Quran data access
/// Domain layer depends on this interface, Data layer implements it.
abstract class QuranRepository {
  /// Get all 114 surahs
  Future<Either<Failure, List<Surah>>> getAllSurahs();

  /// Get a specific surah by ID (1-114)
  Future<Either<Failure, Surah>> getSurah(int surahId);

  /// Get ayahs for a specific surah
  Future<Either<Failure, List<Ayah>>> getAyahsBySurah(int surahId);

  /// Get a single ayah by its key (e.g., "1:1")
  Future<Either<Failure, Ayah>> getAyah(String ayahKey);

  /// Get a full Mushaf page (1-604)
  Future<Either<Failure, QuranPage>> getPage(int pageNumber);

  /// Get multiple pages for batch loading
  Future<Either<Failure, List<QuranPage>>> getPages(int start, int end);

  /// Search ayahs by text content
  Future<Either<Failure, List<Ayah>>> searchAyahs(String query);

  /// Get the last read page and ayah key
  Future<Either<Failure, ({int page, String ayahKey})>> getLastReadPosition();

  /// Save the last read position
  Future<Either<Failure, void>> saveLastReadPosition({
    required int page,
    required String ayahKey,
  });

  /// Verify data integrity using SHA-256 checksums
  Future<Either<Failure, bool>> verifyDataIntegrity(String resourceKey);
}
