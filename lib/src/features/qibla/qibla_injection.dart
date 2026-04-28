import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/datasources/qibla_data_source.dart';
import 'data/repositories/qibla_repository_impl.dart';
import 'domain/repositories/qibla_repository.dart';
import 'presentation/qibla_bloc.dart';

/// Qibla Module — Dependency Injection
/// Registers all Qibla feature dependencies with GetIt
void initQibla(GetIt sl) {
  // ── Data Sources ──
  sl.registerLazySingleton<QiblaLocalDataSource>(
    () => QiblaLocalDataSource(prefs: sl<SharedPreferences>()),
  );

  // ── Repositories ──
  sl.registerLazySingleton<QiblaRepository>(
    () => QiblaRepositoryImpl(localDataSource: sl<QiblaLocalDataSource>()),
  );

  // ── BLoC ──
  sl.registerFactory(() => QiblaBloc(qiblaRepository: sl<QiblaRepository>()));
}
