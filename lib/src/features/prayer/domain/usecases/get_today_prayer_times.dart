import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/prayer_time.dart';
import '../repositories/prayer_repository.dart';

/// Get Today Prayer Times Use Case
class GetTodayPrayerTimesUseCase {
  final PrayerRepository _repository;
  GetTodayPrayerTimesUseCase(this._repository);

  Future<Either<Failure, DailyPrayerSchedule>> call() =>
      _repository.getTodayPrayerTimes();
}
