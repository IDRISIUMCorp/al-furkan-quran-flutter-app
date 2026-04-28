import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_furkan/src/core/error/failures.dart';
import 'package:al_furkan/src/features/hifz/domain/entities/hifz.dart';
import 'package:al_furkan/src/features/hifz/domain/repositories/hifz_repository.dart';
import 'package:al_furkan/src/features/hifz/presentation/hifz_bloc.dart';

// Shared test data — non-const because DateTime is not const
final _testDate = DateTime(2026, 1, 1);
final _testProgress = HifzProgress(
  surahId: 1,
  ayahStart: 1,
  ayahEnd: 7,
  totalAyahs: 7,
  lastReviewed: _testDate,
  mastery: HifzMasteryLevel.mastered,
  reviewCount: 10,
  correctCount: 9,
  mistakeCount: 1,
);

class MockHifzRepository implements HifzRepository {
  final Either<Failure, List<HifzProgress>> allProgressResponse;
  final Either<Failure, HifzProgress> progressResponse;
  final Either<Failure, void> saveProgressResponse;
  final Either<Failure, void> recordSessionResponse;
  final Either<Failure, List<HifzSession>> recentSessionsResponse;
  final Either<Failure, List<HifzSession>> sessionsBySurahResponse;
  final Either<Failure, List<HifzProgress>> dueForReviewResponse;
  final Either<Failure, HifzStats> statsResponse;
  final Either<Failure, void> deleteProgressResponse;

  MockHifzRepository({
    this.allProgressResponse = const Right([]),
    required this.progressResponse,
    this.saveProgressResponse = const Right(null),
    this.recordSessionResponse = const Right(null),
    this.recentSessionsResponse = const Right([]),
    this.sessionsBySurahResponse = const Right([]),
    this.dueForReviewResponse = const Right([]),
    this.statsResponse = const Right(HifzStats(
      totalSurahsMemorized: 1,
      totalAyahsMemorized: 7,
      totalPagesMemorized: 1,
      overallMasteryPercentage: 90.0,
      totalSessions: 10,
      totalReviewMinutes: 120,
      currentStreakDays: 3,
      longestStreakDays: 7,
    )),
    this.deleteProgressResponse = const Right(null),
  });

  @override
  Future<Either<Failure, List<HifzProgress>>> getAllProgress() async =>
      allProgressResponse;

  @override
  Future<Either<Failure, HifzProgress>> getProgress(int surahId) async =>
      progressResponse;

  @override
  Future<Either<Failure, void>> saveProgress(HifzProgress progress) async =>
      saveProgressResponse;

  @override
  Future<Either<Failure, void>> recordSession(HifzSession session) async =>
      recordSessionResponse;

  @override
  Future<Either<Failure, List<HifzSession>>> getRecentSessions({int limit = 10}) async =>
      recentSessionsResponse;

  @override
  Future<Either<Failure, List<HifzSession>>> getSessionsBySurah(int surahId) async =>
      sessionsBySurahResponse;

  @override
  Future<Either<Failure, List<HifzProgress>>> getDueForReview() async =>
      dueForReviewResponse;

  @override
  Future<Either<Failure, HifzStats>> getStats() async => statsResponse;

  @override
  Future<Either<Failure, void>> deleteProgress(int surahId) async =>
      deleteProgressResponse;
}

void main() {
  group('HifzBloc', () {
    late HifzBloc bloc;

    setUp(() {
      bloc = HifzBloc(
        hifzRepository: MockHifzRepository(progressResponse: Right(_testProgress)),
      );
    });

    tearDown(() => bloc.close());

    test('initial state has status initial', () {
      expect(bloc.state.status, HifzStatus.initial);
      expect(bloc.state.allProgress, isEmpty);
      expect(bloc.state.stats, isNull);
    });

    test('LoadAllProgress emits [loading, loaded] with progress list', () async {
      final progressBloc = HifzBloc(
        hifzRepository: MockHifzRepository(
          progressResponse: Right(_testProgress),
          allProgressResponse: Right([_testProgress]),
        ),
      );

      final states = <HifzState>[];
      final subscription = progressBloc.stream.listen(states.add);

      progressBloc.add(const LoadAllProgress());
      await progressBloc.stream.first;

      await subscription.cancel();

      expect(states.first.status, HifzStatus.loading);
      expect(states.last.status, HifzStatus.loaded);
      expect(states.last.allProgress.length, 1);

      await progressBloc.close();
    });

    test('LoadAllProgress on error emits [loading, error]', () async {
      final errorBloc = HifzBloc(
        hifzRepository: MockHifzRepository(
          progressResponse: Right(_testProgress),
          allProgressResponse: Left(const Failure.cache(message: 'DB error')),
        ),
      );

      final states = <HifzState>[];
      final subscription = errorBloc.stream.listen(states.add);

      errorBloc.add(const LoadAllProgress());
      await errorBloc.stream.first;

      await subscription.cancel();

      expect(states.last.status, HifzStatus.error);
      expect(states.last.errorMessage, 'DB error');

      await errorBloc.close();
    });

    test('LoadStats emits loaded with stats', () async {
      final states = <HifzState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const LoadStats());
      await bloc.stream.first;

      await subscription.cancel();

      expect(states.last.status, HifzStatus.loaded);
      expect(states.last.stats, isNotNull);
      expect(states.last.stats!.totalSurahsMemorized, 1);
      expect(states.last.stats!.overallMasteryPercentage, 90.0);
      expect(states.last.stats!.totalReviewMinutes, 120);
    });

    test('LoadDueForReview emits loaded with due list', () async {
      final dueBloc = HifzBloc(
        hifzRepository: MockHifzRepository(
          progressResponse: Right(_testProgress),
          dueForReviewResponse: Right([
            HifzProgress(
              surahId: 2,
              ayahStart: 1,
              ayahEnd: 10,
              totalAyahs: 286,
              lastReviewed: _testDate,
              mastery: HifzMasteryLevel.familiar,
              reviewCount: 5,
              correctCount: 3,
              mistakeCount: 2,
            ),
          ]),
        ),
      );

      final states = <HifzState>[];
      final subscription = dueBloc.stream.listen(states.add);

      dueBloc.add(const LoadDueForReview());
      await dueBloc.stream.first;

      await subscription.cancel();

      expect(states.last.status, HifzStatus.loaded);
      expect(states.last.dueForReview.length, 1);

      await dueBloc.close();
    });

    test('LoadProgressForSurah sets currentProgress', () async {
      final states = <HifzState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const LoadProgressForSurah(1));
      await bloc.stream.first;

      await subscription.cancel();

      expect(states.last.status, HifzStatus.loaded);
      expect(states.last.currentProgress, isNotNull);
      expect(states.last.currentProgress!.surahId, 1);
    });
  });
}
