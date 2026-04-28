import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/error_handler.dart';
import '../../domain/entities/prayer_time.dart';
import '../../domain/repositories/prayer_repository.dart';
import '../datasources/prayer_data_source.dart';

/// Prayer Repository Implementation — bridges domain and data layers
class PrayerRepositoryImpl implements PrayerRepository {
  final PrayerRemoteDataSource _remoteDataSource;
  final PrayerLocalDataSource _localDataSource;

  PrayerRepositoryImpl({
    required PrayerRemoteDataSource remoteDataSource,
    required PrayerLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Either<Failure, DailyPrayerSchedule>> getTodayPrayerTimes() async {
    // Try cache first
    final cached = _localDataSource.getCachedPrayerSchedule();
    if (cached != null) {
      final domain = cached.toDomain();
      // Return cache if it's from today
      if (_isSameDay(domain.date, DateTime.now())) {
        return Right(domain);
      }
    }

    // Fetch from remote
    return ErrorHandler.guard(() async {
      final location = _localDataSource.getSavedLocation();
      final method = _localDataSource.getCalculationMethod();

      if (location == null) {
        throw CacheException(message: 'No saved location — location required for prayer times');
      }

      final model = await _remoteDataSource.getPrayerTimes(
        date: DateTime.now(),
        latitude: location.latitude,
        longitude: location.longitude,
        method: method,
      );

      // Cache the result
      await _localDataSource.cachePrayerSchedule(model);
      return model.toDomain();
    });
  }

  @override
  Future<Either<Failure, DailyPrayerSchedule>> getPrayerTimes(DateTime date) async {
    return ErrorHandler.guard(() async {
      final location = _localDataSource.getSavedLocation();
      final method = _localDataSource.getCalculationMethod();

      if (location == null) {
        throw CacheException(message: 'No saved location');
      }

      final model = await _remoteDataSource.getPrayerTimes(
        date: date,
        latitude: location.latitude,
        longitude: location.longitude,
        method: method,
      );
      return model.toDomain();
    });
  }

  @override
  Future<Either<Failure, List<DailyPrayerSchedule>>> getMonthlyPrayerTimes({
    required int year,
    required int month,
  }) async {
    // Monthly fetch — iterate dates or use Aladhan calendar endpoint
    return Left(Failure.unknown(
      message: 'getMonthlyPrayerTimes — pending Aladhan calendar API integration',
    ));
  }

  @override
  Future<Either<Failure, String>> getCalculationMethod() async {
    return Right(_localDataSource.getCalculationMethod());
  }

  @override
  Future<Either<Failure, void>> saveCalculationMethod(String method) {
    return ErrorHandler.guard(() => _localDataSource.saveCalculationMethod(method));
  }

  @override
  Future<Either<Failure, ({double latitude, double longitude})>> getSavedLocation() async {
    final location = _localDataSource.getSavedLocation();
    if (location == null) {
      return Left(Failure.cache(message: 'No saved location'));
    }
    return Right(location);
  }

  @override
  Future<Either<Failure, void>> saveLocation({
    required double latitude,
    required double longitude,
  }) {
    return ErrorHandler.guard(() => _localDataSource.saveLocation(
          latitude: latitude,
          longitude: longitude,
        ));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
