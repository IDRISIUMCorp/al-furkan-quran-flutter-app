import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/reciter.dart';

/// Audio Repository Interface — Abstract contract for audio/reciter data
abstract class AudioRepository {
  /// Get all available reciters
  Future<Either<Failure, List<Reciter>>> getAllReciters();

  /// Get a specific reciter by ID
  Future<Either<Failure, Reciter>> getReciter(int id);

  /// Get the currently selected reciter
  Future<Either<Failure, Reciter>> getSelectedReciter();

  /// Save the selected reciter preference
  Future<Either<Failure, void>> saveSelectedReciter(int reciterId);

  /// Get audio URL for a specific ayah
  Future<Either<Failure, String>> getAyahAudioUrl({
    required int reciterId,
    required String ayahKey,
  });

  /// Get audio URL for a full surah
  Future<Either<Failure, String>> getSurahAudioUrl({
    required int reciterId,
    required int surahId,
  });

  /// Download a surah audio for offline use
  Future<Either<Failure, void>> downloadSurahAudio({
    required int reciterId,
    required int surahId,
  });

  /// Delete downloaded surah audio
  Future<Either<Failure, void>> deleteSurahAudio({
    required int reciterId,
    required int surahId,
  });

  /// Check if a surah is downloaded for offline
  Future<Either<Failure, bool>> isSurahDownloaded({
    required int reciterId,
    required int surahId,
  });
}
