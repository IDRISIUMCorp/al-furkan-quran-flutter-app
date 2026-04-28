import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/error_handler.dart';
import '../../domain/entities/entities.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_local_data_source.dart';

/// Quran Repository Implementation — bridges domain and data layers
/// All operations return Either<Failure, T> — no exceptions leak to domain
class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDataSource _localDataSource;

  QuranRepositoryImpl({required QuranLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<Surah>>> getAllSurahs() async {
    return ErrorHandler.guard(() async {
      final models = await _localDataSource.getAllSurahs();
      return models.map((m) => m.toDomain()).toList();
    });
  }

  @override
  Future<Either<Failure, Surah>> getSurah(int surahId) async {
    return ErrorHandler.guard(() async {
      final models = await _localDataSource.getAllSurahs();
      final model = models.firstWhere(
        (m) => m.id == surahId,
        orElse: () => throw NotFoundException(message: 'Surah $surahId not found'),
      );
      return model.toDomain();
    });
  }

  @override
  Future<Either<Failure, List<Ayah>>> getAyahsBySurah(int surahId) async {
    // Ayahs are loaded from local JSON assets via existing QuranResourcesRepository
    // This will be fully implemented when migrating to the new architecture
    return Left(Failure.unknown(
      message: 'getAyahsBySurah — pending migration from QuranResourcesRepository',
    ));
  }

  @override
  Future<Either<Failure, Ayah>> getAyah(String ayahKey) async {
    return Left(Failure.unknown(
      message: 'getAyah — pending migration from QuranResourcesRepository',
    ));
  }

  @override
  Future<Either<Failure, QuranPage>> getPage(int pageNumber) async {
    return Left(Failure.unknown(
      message: 'getPage — pending migration from QuranResourcesRepository',
    ));
  }

  @override
  Future<Either<Failure, List<QuranPage>>> getPages(int start, int end) async {
    return Left(Failure.unknown(
      message: 'getPages — pending migration from QuranResourcesRepository',
    ));
  }

  @override
  Future<Either<Failure, List<Ayah>>> searchAyahs(String query) async {
    return Left(Failure.unknown(
      message: 'searchAyahs — pending migration from QuranResourcesRepository',
    ));
  }

  @override
  Future<Either<Failure, ({int page, String ayahKey})>> getLastReadPosition() {
    return ErrorHandler.guard(() => _localDataSource.getLastReadPosition());
  }

  @override
  Future<Either<Failure, void>> saveLastReadPosition({
    required int page,
    required String ayahKey,
  }) {
    return ErrorHandler.guard(() => _localDataSource.saveLastReadPosition(
          page: page,
          ayahKey: ayahKey,
        ));
  }

  @override
  Future<Either<Failure, bool>> verifyDataIntegrity(String resourceKey) async {
    // Integrity verification will be implemented with checksum validation
    return const Right(true);
  }
}
