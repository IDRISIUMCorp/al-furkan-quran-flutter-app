import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/error_handler.dart';
import '../../domain/entities/tafsir.dart';
import '../../domain/repositories/tafsir_repository.dart';
import '../datasources/tafsir_local_data_source.dart';

/// Tafsir Repository Implementation — bridges domain and data layers
class TafsirRepositoryImpl implements TafsirRepository {
  final TafsirLocalDataSource _localDataSource;

  TafsirRepositoryImpl({required TafsirLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<Tafsir>>> getAllTafsirs() {
    return ErrorHandler.guard(() async {
      final models = _localDataSource.getCachedTafsirs();
      return models.map((m) => m.toDomain()).toList();
    });
  }

  @override
  Future<Either<Failure, Tafsir>> getTafsir(int id) {
    return ErrorHandler.guard(() async {
      final models = _localDataSource.getCachedTafsirs();
      final model = models.firstWhere(
        (m) => m.id == id,
        orElse: () => throw NotFoundException(message: 'Tafsir $id not found'),
      );
      return model.toDomain();
    });
  }

  @override
  Future<Either<Failure, TafsirEntry>> getTafsirEntry({
    required int tafsirId,
    required String ayahKey,
  }) {
    return ErrorHandler.guard(() async {
      final model = _localDataSource.getTafsirEntry(
        tafsirId: tafsirId,
        ayahKey: ayahKey,
      );
      if (model == null) {
        throw CacheException(message: 'Tafsir entry not found for $ayahKey');
      }
      return model.toDomain();
    });
  }

  @override
  Future<Either<Failure, List<TafsirEntry>>> getTafsirForSurah({
    required int tafsirId,
    required int surahId,
  }) {
    return Future.value(Left<Failure, List<TafsirEntry>>(Failure.unknown(
      message: 'getTafsirForSurah — pending full surah tafsir loading',
    )));
  }

  @override
  Future<Either<Failure, Tafsir>> getSelectedTafsir() async {
    final id = _localDataSource.getSelectedTafsirId();
    return getTafsir(id);
  }

  @override
  Future<Either<Failure, void>> saveSelectedTafsir(int tafsirId) {
    return ErrorHandler.guard(() => _localDataSource.saveSelectedTafsirId(tafsirId));
  }

  @override
  Future<Either<Failure, void>> downloadTafsir(int tafsirId) {
    return Future.value(Left<Failure, void>(Failure.unknown(
      message: 'downloadTafsir — pending download manager implementation',
    )));
  }

  @override
  Future<Either<Failure, void>> deleteTafsir(int tafsirId) {
    return Future.value(Left<Failure, void>(Failure.unknown(
      message: 'deleteTafsir — pending implementation',
    )));
  }

  @override
  Future<Either<Failure, bool>> isTafsirDownloaded(int tafsirId) async {
    return const Right(false);
  }
}
