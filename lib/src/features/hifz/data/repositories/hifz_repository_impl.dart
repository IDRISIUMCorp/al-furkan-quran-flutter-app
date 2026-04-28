import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/error_handler.dart';
import '../../domain/entities/hifz.dart';
import '../../domain/repositories/hifz_repository.dart';
import '../datasources/hifz_data_source.dart';
import '../models/hifz_model.dart';

/// Hifz Repository Implementation — bridges domain and data layers
class HifzRepositoryImpl implements HifzRepository {
  final HifzLocalDataSource _localDataSource;

  HifzRepositoryImpl({required HifzLocalDataSource localDataSource})
      : _localDataSource = localDataSource;

  @override
  Future<Either<Failure, List<HifzProgress>>> getAllProgress() async {
    try {
      final models = _localDataSource.getAllProgress();
      return Right(models.map((m) => m.toDomain()).toList());
    } catch (e) {
      return Left(Failure.cache(message: 'Failed to load hifz progress: $e'));
    }
  }

  @override
  Future<Either<Failure, HifzProgress>> getProgress(int surahId) async {
    try {
      final all = _localDataSource.getAllProgress();
      final match = all.where((m) => m.surahId == surahId).firstOrNull;
      if (match == null) {
        return Left(Failure.cache(message: 'No hifz progress for surah $surahId'));
      }
      return Right(match.toDomain());
    } catch (e) {
      return Left(Failure.cache(message: 'Failed to load hifz progress: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveProgress(HifzProgress progress) {
    return ErrorHandler.guard(() async {
      final all = _localDataSource.getAllProgress();
      final models = all.where((m) => m.surahId != progress.surahId).toList()
        ..add(HifzProgressModel.fromDomain(progress));
      await _localDataSource.saveAllProgress(models);
    });
  }

  @override
  Future<Either<Failure, void>> recordSession(HifzSession session) {
    return ErrorHandler.guard(() async {
      final sessions = _localDataSource.getRecentSessions(limit: 1000);
      sessions.add(HifzSessionModel.fromDomain(session));
      await _localDataSource.saveSessions(sessions);
    });
  }

  @override
  Future<Either<Failure, List<HifzSession>>> getRecentSessions({int limit = 10}) async {
    try {
      final models = _localDataSource.getRecentSessions(limit: limit);
      return Right(models.map((m) => m.toDomain()).toList());
    } catch (e) {
      return Left(Failure.cache(message: 'Failed to load sessions: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HifzSession>>> getSessionsBySurah(int surahId) async {
    try {
      final all = _localDataSource.getRecentSessions(limit: 10000);
      final filtered = all.where((m) => m.surahId == surahId).toList();
      return Right(filtered.map((m) => m.toDomain()).toList());
    } catch (e) {
      return Left(Failure.cache(message: 'Failed to load sessions: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HifzProgress>>> getDueForReview() async {
    try {
      final all = _localDataSource.getAllProgress();
      final now = DateTime.now();
      final due = all.where((m) {
        final lastReviewed = DateTime.parse(m.lastReviewed);
        final daysSinceReview = now.difference(lastReviewed).inDays;
        // Spaced repetition: review based on mastery level
        final reviewInterval = switch (m.mastery) {
          'learning' => 1,
          'familiar' => 3,
          'confident' => 7,
          'mastered' => 14,
          _ => 1,
        };
        return daysSinceReview >= reviewInterval;
      }).toList();
      return Right(due.map((m) => m.toDomain()).toList());
    } catch (e) {
      return Left(Failure.cache(message: 'Failed to load due reviews: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProgress(int surahId) {
    return ErrorHandler.guard(() async {
      final all = _localDataSource.getAllProgress();
      final filtered = all.where((m) => m.surahId != surahId).toList();
      await _localDataSource.saveAllProgress(filtered);
    });
  }

  @override
  Future<Either<Failure, HifzStats>> getStats() async {
    try {
      final all = _localDataSource.getAllProgress();
      final sessions = _localDataSource.getRecentSessions(limit: 10000);

      int totalAyahs = 0;
      int totalSurahs = 0;
      double totalMastery = 0;

      for (final p in all) {
        totalAyahs += p.ayahEnd - p.ayahStart + 1;
        totalSurahs++;
        totalMastery += p.reviewCount > 0 ? (p.correctCount / p.reviewCount) * 100 : 0;
      }

      final avgMastery = all.isNotEmpty ? totalMastery / all.length : 0.0;
      final totalMinutes = sessions.fold<int>(0, (sum, s) => sum + s.durationSeconds) ~/ 60;

      // Calculate streaks from session dates
      final sessionDates = sessions
          .map((s) {
            final dt = DateTime.parse(s.date);
            return DateTime(dt.year, dt.month, dt.day);
          })
          .toSet()
          .toList()
        ..sort((a, b) => b.compareTo(a)); // descending

      int currentStreak = 0;
      int longestStreak = 0;
      if (sessionDates.isNotEmpty) {
        final today = DateTime.now();
        final todayDate = DateTime(today.year, today.month, today.day);
        final yesterday = todayDate.subtract(const Duration(days: 1));

        // Current streak: count consecutive days from today/yesterday backwards
        final checkDate = sessionDates.first;
        if (checkDate == todayDate || checkDate == yesterday) {
          currentStreak = 1;
          var expected = checkDate.subtract(const Duration(days: 1));
          for (int i = 1; i < sessionDates.length; i++) {
            if (sessionDates[i] == expected) {
              currentStreak++;
              expected = expected.subtract(const Duration(days: 1));
            } else {
              break;
            }
          }
        }

        // Longest streak: scan all dates
        var runLength = 1;
        for (int i = 1; i < sessionDates.length; i++) {
          final diff = sessionDates[i - 1].difference(sessionDates[i]).inDays;
          if (diff == 1) {
            runLength++;
          } else {
            if (runLength > longestStreak) longestStreak = runLength;
            runLength = 1;
          }
        }
        if (runLength > longestStreak) longestStreak = runLength;
      }

      return Right(HifzStats(
        totalSurahsMemorized: totalSurahs,
        totalAyahsMemorized: totalAyahs,
        totalPagesMemorized: totalAyahs ~/ 15, // Approx 15 ayahs per page
        overallMasteryPercentage: avgMastery,
        totalSessions: sessions.length,
        totalReviewMinutes: totalMinutes,
        currentStreakDays: currentStreak,
        longestStreakDays: longestStreak,
      ));
    } catch (e) {
      return Left(Failure.cache(message: 'Failed to load stats: $e'));
    }
  }
}
