import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/azkar_data_source.dart';
import 'data/repositories/azkar_repository_impl.dart';
import 'domain/repositories/azkar_repository.dart';
import 'presentation/azkar_bloc.dart';

/// Azkar Module — Dependency Injection
/// Registers all Azkar feature dependencies with GetIt
void initAzkar(GetIt sl) {
  // ── Data Sources ──
  sl.registerLazySingleton<AzkarLocalDataSource>(
    () => AzkarLocalDataSource(
      azkarBox: Hive.box('azkar'),
      prefs: sl<SharedPreferences>(),
    ),
  );

  // ── Repositories ──
  sl.registerLazySingleton<AzkarRepository>(
    () => AzkarRepositoryImpl(localDataSource: sl<AzkarLocalDataSource>()),
  );

  // ── BLoC ──
  sl.registerFactory(() => AzkarBloc(azkarRepository: sl<AzkarRepository>()));
}
