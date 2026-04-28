import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:al_furkan/src/core/error/failures.dart';
import 'package:al_furkan/src/features/qibla/domain/entities/qibla.dart';
import 'package:al_furkan/src/features/qibla/domain/repositories/qibla_repository.dart';
import 'package:al_furkan/src/features/qibla/presentation/qibla_bloc.dart';

const _testQiblaInfo = QiblaInfo(
  latitude: 30.0444,
  longitude: 31.2357,
  qiblaBearing: 135.0,
  locationName: 'Cairo',
);

class MockQiblaRepository implements QiblaRepository {
  final Either<Failure, QiblaInfo> qiblaInfoResponse;
  final Either<Failure, ({double latitude, double longitude})> savedLocationResponse;
  final Either<Failure, void> saveLocationResponse;
  final Either<Failure, bool> compassAvailableResponse;

  MockQiblaRepository({
    this.qiblaInfoResponse = const Right(_testQiblaInfo),
    this.savedLocationResponse = const Right((latitude: 30.0444, longitude: 31.2357)),
    this.saveLocationResponse = const Right(null),
    this.compassAvailableResponse = const Right(true),
  });

  @override
  Future<Either<Failure, QiblaInfo>> getQiblaInfo() async => qiblaInfoResponse;

  @override
  Future<Either<Failure, ({double latitude, double longitude})>> getSavedLocation() async =>
      savedLocationResponse;

  @override
  Future<Either<Failure, void>> saveLocation({
    required double latitude,
    required double longitude,
  }) async => saveLocationResponse;

  @override
  Future<Either<Failure, bool>> isCompassAvailable() async =>
      compassAvailableResponse;
}

void main() {
  group('QiblaBloc', () {
    late QiblaBloc bloc;

    setUp(() {
      bloc = QiblaBloc(qiblaRepository: MockQiblaRepository());
    });

    tearDown(() => bloc.close());

    test('initial state has status initial', () {
      expect(bloc.state.status, QiblaStatus.initial);
      expect(bloc.state.qiblaInfo, isNull);
    });

    test('LoadQiblaInfo emits [loading, loaded] with qibla info', () async {
      final states = <QiblaState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const LoadQiblaInfo());
      await bloc.stream.first;

      await subscription.cancel();

      expect(states.first.status, QiblaStatus.loading);
      expect(states.last.status, QiblaStatus.loaded);
      expect(states.last.qiblaInfo, isNotNull);
      expect(states.last.qiblaInfo!.locationName, 'Cairo');
      expect(states.last.qiblaInfo!.qiblaBearing, 135.0);
    });

    test('LoadQiblaInfo on error emits [loading, error]', () async {
      final errorBloc = QiblaBloc(
        qiblaRepository: MockQiblaRepository(
          qiblaInfoResponse: Left(const Failure.permission(message: 'Location denied')),
        ),
      );

      final states = <QiblaState>[];
      final subscription = errorBloc.stream.listen(states.add);

      errorBloc.add(const LoadQiblaInfo());
      await errorBloc.stream.first;

      await subscription.cancel();

      expect(states.last.status, QiblaStatus.error);
      expect(states.last.errorMessage, 'Location denied');

      await errorBloc.close();
    });

    test('UpdateLocation saves location and recalculates bearing', () async {
      final states = <QiblaState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const UpdateLocation(latitude: 30.0444, longitude: 31.2357));
      await bloc.stream.first;

      await subscription.cancel();

      expect(states.last.status, QiblaStatus.loaded);
      expect(states.last.savedLocation, isNotNull);
      expect(states.last.savedLocation!.latitude, 30.0444);
      expect(states.last.qiblaInfo, isNotNull);
    });

    test('CheckCompassAvailability updates compass availability', () async {
      final states = <QiblaState>[];
      final subscription = bloc.stream.listen(states.add);

      bloc.add(const CheckCompassAvailability());
      await bloc.stream.first;

      await subscription.cancel();

      expect(states.last.isCompassAvailable, true);
    });

    test('CheckCompassAvailability with no compass sets false', () async {
      final noCompassBloc = QiblaBloc(
        qiblaRepository: MockQiblaRepository(
          compassAvailableResponse: const Right(false),
        ),
      );

      final states = <QiblaState>[];
      final subscription = noCompassBloc.stream.listen(states.add);

      noCompassBloc.add(const CheckCompassAvailability());
      await noCompassBloc.stream.first;

      await subscription.cancel();

      expect(states.last.isCompassAvailable, false);

      await noCompassBloc.close();
    });
  });
}
