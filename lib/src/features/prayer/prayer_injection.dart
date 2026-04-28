import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_strings.dart';
import '../prayer/data/datasources/prayer_data_source.dart';
import '../prayer/data/repositories/prayer_repository_impl.dart';
import '../prayer/domain/repositories/prayer_repository.dart';
import '../prayer/domain/usecases/get_today_prayer_times.dart';
import '../prayer/presentation/prayer_bloc.dart';

/// Feature-level DI registration for the Prayer module
class PrayerInjection {
  PrayerInjection._();

  static void init(GetIt sl) {
    // ── Data Sources ──
    sl.registerLazySingleton<PrayerRemoteDataSource>(
      () => PrayerRemoteDataSource(),
    );
    sl.registerLazySingleton<PrayerLocalDataSource>(
      () => PrayerLocalDataSource(
        cacheBox: Hive.box(AppStrings.hiveBoxUser),
        prefs: sl<SharedPreferences>(),
      ),
    );

    // ── Repositories ──
    sl.registerLazySingleton<PrayerRepository>(
      () => PrayerRepositoryImpl(
        remoteDataSource: sl<PrayerRemoteDataSource>(),
        localDataSource: sl<PrayerLocalDataSource>(),
      ),
    );

    // ── Use Cases ──
    sl.registerLazySingleton(() => GetTodayPrayerTimesUseCase(sl<PrayerRepository>()));

    // ── BLoC ──
    sl.registerFactory(() => PrayerBloc(
          getTodayPrayerTimes: sl<GetTodayPrayerTimesUseCase>(),
        ));
  }
}
