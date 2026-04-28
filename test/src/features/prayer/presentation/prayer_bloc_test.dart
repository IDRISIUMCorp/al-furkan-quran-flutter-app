import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_furkan/src/core/error/failures.dart';
import 'package:al_furkan/src/features/prayer/domain/entities/prayer_time.dart';
import 'package:al_furkan/src/features/prayer/domain/usecases/get_today_prayer_times.dart';
import 'package:al_furkan/src/features/prayer/presentation/prayer_bloc.dart';

final _testSchedule = DailyPrayerSchedule(
  date: DateTime(2026, 4, 28),
  hijriDate: '1 Dhul Qadah 1448',
  hijriMonth: 'Dhul Qadah',
  hijriYear: 1448,
  prayers: [
    PrayerTime(name: 'Fajr', time: DateTime(2026, 4, 28, 4, 30), type: PrayerType.fajr),
    PrayerTime(name: 'Dhuhr', time: DateTime(2026, 4, 28, 12, 15), type: PrayerType.dhuhr, isCurrent: true),
    PrayerTime(name: 'Asr', time: DateTime(2026, 4, 28, 15, 45), type: PrayerType.asr),
    PrayerTime(name: 'Maghrib', time: DateTime(2026, 4, 28, 18, 30), type: PrayerType.maghrib),
    PrayerTime(name: 'Isha', time: DateTime(2026, 4, 28, 20, 0), type: PrayerType.isha),
  ],
  location: 'Cairo',
  latitude: 30.0444,
  longitude: 31.2357,
  calculationMethod: 'EGAS',
);

class MockGetTodayPrayerTimes implements GetTodayPrayerTimesUseCase {
  final Either<Failure, DailyPrayerSchedule> response;
  MockGetTodayPrayerTimes(this.response);

  @override
  Future<Either<Failure, DailyPrayerSchedule>> call() async => response;

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('PrayerBloc', () {
    late PrayerBloc bloc;

    setUp(() {
      bloc = PrayerBloc(
        getTodayPrayerTimes: MockGetTodayPrayerTimes(Right(_testSchedule)),
      );
    });

    tearDown(() => bloc.close());

    test('initial state has status initial', () {
      expect(bloc.state.status, PrayerStatus.initial);
      expect(bloc.state.schedule, isNull);
    });

    test('LoadTodayPrayerTimes emits [loading, loaded] with schedule', () async {
      final states = <PrayerState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const LoadTodayPrayerTimes());
      await bloc.stream.first;

      await subscription.cancel();

      expect(states.first.status, PrayerStatus.loading);
      expect(states.last.status, PrayerStatus.loaded);
      expect(states.last.schedule, isNotNull);
      expect(states.last.schedule!.prayers.length, 5);
      expect(states.last.schedule!.location, 'Cairo');
    });

    test('LoadTodayPrayerTimes on error emits [loading, error]', () async {
      final errorBloc = PrayerBloc(
        getTodayPrayerTimes: MockGetTodayPrayerTimes(
          Left(const Failure.network(message: 'No GPS signal')),
        ),
      );

      final states = <PrayerState>[];
      final subscription = errorBloc.stream.listen(states.add);

      errorBloc.add(const LoadTodayPrayerTimes());
      await errorBloc.stream.first;

      await subscription.cancel();

      expect(states.last.status, PrayerStatus.error);
      expect(states.last.errorMessage, 'No GPS signal');

      await errorBloc.close();
    });

    test('RefreshPrayerTimes emits loaded with schedule (no loading state)', () async {
      final states = <PrayerState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const RefreshPrayerTimes());
      await bloc.stream.first;

      await subscription.cancel();

      expect(states.last.status, PrayerStatus.loaded);
      expect(states.last.schedule, isNotNull);
    });
  });
}
