import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/error_handler.dart';
import '../../domain/entities/reciter.dart';
import '../../domain/repositories/audio_repository.dart';
import '../datasources/audio_data_source.dart';

/// Audio Repository Implementation — bridges domain and data layers
class AudioRepositoryImpl implements AudioRepository {
  final AudioRemoteDataSource _remoteDataSource;
  final AudioLocalDataSource _localDataSource;

  AudioRepositoryImpl({
    required AudioRemoteDataSource remoteDataSource,
    required AudioLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<Reciter>>> getAllReciters() {
    return ErrorHandler.guard(() async {
      // Try cache first
      var cached = _localDataSource.getCachedReciters();
      if (cached.isNotEmpty) return cached.map((m) => m.toDomain()).toList();

      // Fetch from remote (bundled asset — returns empty for now)
      cached = await _remoteDataSource.getReciters();
      if (cached.isNotEmpty) {
        await _localDataSource.cacheReciters(cached);
      }
      return cached.map((m) => m.toDomain()).toList();
    });
  }

  @override
  Future<Either<Failure, Reciter>> getReciter(int id) {
    return ErrorHandler.guard(() async {
      final reciters = _localDataSource.getCachedReciters();
      final model = reciters.firstWhere(
        (m) => m.id == id,
        orElse: () => throw NotFoundException(message: 'Reciter $id not found'),
      );
      return model.toDomain();
    });
  }

  @override
  Future<Either<Failure, Reciter>> getSelectedReciter() async {
    final id = _localDataSource.getSelectedReciterId();
    return getReciter(id);
  }

  @override
  Future<Either<Failure, void>> saveSelectedReciter(int reciterId) {
    return ErrorHandler.guard(() => _localDataSource.saveSelectedReciterId(reciterId));
  }

  @override
  Future<Either<Failure, String>> getAyahAudioUrl({
    required int reciterId,
    required String ayahKey,
  }) async {
    return Right(_remoteDataSource.getAyahAudioUrl(
      reciterId: reciterId,
      ayahKey: ayahKey,
    ));
  }

  @override
  Future<Either<Failure, String>> getSurahAudioUrl({
    required int reciterId,
    required int surahId,
  }) async {
    return Right(_remoteDataSource.getSurahAudioUrl(
      reciterId: reciterId,
      surahId: surahId,
    ));
  }

  @override
  Future<Either<Failure, void>> downloadSurahAudio({
    required int reciterId,
    required int surahId,
  }) {
    return Future.value(Left<Failure, void>(Failure.unknown(
      message: 'downloadSurahAudio — pending download manager implementation',
    )));
  }

  @override
  Future<Either<Failure, void>> deleteSurahAudio({
    required int reciterId,
    required int surahId,
  }) {
    return ErrorHandler.guard(() => _localDataSource.deleteSurahAudio(
          reciterId: reciterId,
          surahId: surahId,
        ));
  }

  @override
  Future<Either<Failure, bool>> isSurahDownloaded({
    required int reciterId,
    required int surahId,
  }) {
    return ErrorHandler.guard(() => _localDataSource.isSurahDownloaded(
          reciterId: reciterId,
          surahId: surahId,
        ));
  }
}
