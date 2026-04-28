import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/tafsir.dart';

/// Tafsir Repository Interface — Abstract contract for tafsir/translation data
abstract class TafsirRepository {
  /// Get all available tafsirs and translations
  Future<Either<Failure, List<Tafsir>>> getAllTafsirs();

  /// Get a specific tafsir by ID
  Future<Either<Failure, Tafsir>> getTafsir(int id);

  /// Get tafsir entry for a specific ayah
  Future<Either<Failure, TafsirEntry>> getTafsirEntry({
    required int tafsirId,
    required String ayahKey,
  });

  /// Get tafsir entries for a full surah
  Future<Either<Failure, List<TafsirEntry>>> getTafsirForSurah({
    required int tafsirId,
    required int surahId,
  });

  /// Get the currently selected tafsir
  Future<Either<Failure, Tafsir>> getSelectedTafsir();

  /// Save the selected tafsir preference
  Future<Either<Failure, void>> saveSelectedTafsir(int tafsirId);

  /// Download a tafsir for offline use
  Future<Either<Failure, void>> downloadTafsir(int tafsirId);

  /// Delete a downloaded tafsir
  Future<Either<Failure, void>> deleteTafsir(int tafsirId);

  /// Check if a tafsir is available offline
  Future<Either<Failure, bool>> isTafsirDownloaded(int tafsirId);
}
