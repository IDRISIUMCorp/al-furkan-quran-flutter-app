import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/prayer_time.dart';

/// Prayer Repository Interface — Abstract contract for prayer time data
abstract class PrayerRepository {
  /// Get prayer times for today at current location
  Future<Either<Failure, DailyPrayerSchedule>> getTodayPrayerTimes();

  /// Get prayer times for a specific date
  Future<Either<Failure, DailyPrayerSchedule>> getPrayerTimes(DateTime date);

  /// Get monthly prayer schedule
  Future<Either<Failure, List<DailyPrayerSchedule>>> getMonthlyPrayerTimes({
    required int year,
    required int month,
  });

  /// Get the saved calculation method
  Future<Either<Failure, String>> getCalculationMethod();

  /// Save the calculation method preference
  Future<Either<Failure, void>> saveCalculationMethod(String method);

  /// Get the saved location coordinates
  Future<Either<Failure, ({double latitude, double longitude})>> getSavedLocation();

  /// Save location coordinates
  Future<Either<Failure, void>> saveLocation({
    required double latitude,
    required double longitude,
  });
}
