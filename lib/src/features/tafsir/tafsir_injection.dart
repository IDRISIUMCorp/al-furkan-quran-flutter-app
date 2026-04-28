import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_strings.dart';
import '../tafsir/data/datasources/tafsir_local_data_source.dart';
import '../tafsir/data/repositories/tafsir_repository_impl.dart';
import '../tafsir/domain/repositories/tafsir_repository.dart';
import '../tafsir/presentation/tafsir_bloc.dart';

/// Feature-level DI registration for the Tafsir module
class TafsirInjection {
  TafsirInjection._();

  static void init(GetIt sl) {
    // ── Data Sources ──
    sl.registerLazySingleton<TafsirLocalDataSource>(
      () => TafsirLocalDataSource(
        cacheBox: Hive.box(AppStrings.hiveBoxUser),
        prefs: sl<SharedPreferences>(),
      ),
    );

    // ── Repositories ──
    sl.registerLazySingleton<TafsirRepository>(
      () => TafsirRepositoryImpl(localDataSource: sl<TafsirLocalDataSource>()),
    );

    // ── BLoC ──
    sl.registerFactory(() => TafsirBloc(tafsirRepository: sl<TafsirRepository>()));
  }
}
