import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import 'data/datasources/hifz_data_source.dart';
import 'data/repositories/hifz_repository_impl.dart';
import 'domain/repositories/hifz_repository.dart';
import 'presentation/hifz_bloc.dart';

/// Hifz Module — Dependency Injection
/// Registers all Hifz feature dependencies with GetIt
void initHifz(GetIt sl) {
  // ── Data Sources ──
  sl.registerLazySingleton<HifzLocalDataSource>(
    () => HifzLocalDataSource(notesBox: Hive.box('hifz')),
  );

  // ── Repositories ──
  sl.registerLazySingleton<HifzRepository>(
    () => HifzRepositoryImpl(localDataSource: sl<HifzLocalDataSource>()),
  );

  // ── BLoC ──
  sl.registerFactory(() => HifzBloc(hifzRepository: sl<HifzRepository>()));
}
