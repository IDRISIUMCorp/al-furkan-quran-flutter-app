import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/hifz.dart';

/// Hifz Repository Interface — Abstract contract for memorization tracking
abstract class HifzRepository {
  /// Get all hifz progress entries
  Future<Either<Failure, List<HifzProgress>>> getAllProgress();

  /// Get hifz progress for a specific surah
  Future<Either<Failure, HifzProgress>> getProgress(int surahId);

  /// Save/update hifz progress
  Future<Either<Failure, void>> saveProgress(HifzProgress progress);

  /// Record a review session
  Future<Either<Failure, void>> recordSession(HifzSession session);

  /// Get recent review sessions
  Future<Either<Failure, List<HifzSession>>> getRecentSessions({int limit = 10});

  /// Get sessions for a specific surah
  Future<Either<Failure, List<HifzSession>>> getSessionsBySurah(int surahId);

  /// Get surahs that need review (spaced repetition)
  Future<Either<Failure, List<HifzProgress>>> getDueForReview();

  /// Delete hifz progress for a surah
  Future<Either<Failure, void>> deleteProgress(int surahId);

  /// Get overall hifz statistics
  Future<Either<Failure, HifzStats>> getStats();
}

/// Hifz Statistics — aggregated progress data
class HifzStats {
  final int totalSurahsMemorized;
  final int totalAyahsMemorized;
  final int totalPagesMemorized;
  final double overallMasteryPercentage;
  final int totalSessions;
  final int totalReviewMinutes;
  final int currentStreakDays;
  final int longestStreakDays;

  const HifzStats({
    required this.totalSurahsMemorized,
    required this.totalAyahsMemorized,
    required this.totalPagesMemorized,
    required this.overallMasteryPercentage,
    required this.totalSessions,
    required this.totalReviewMinutes,
    required this.currentStreakDays,
    required this.longestStreakDays,
  });
}
