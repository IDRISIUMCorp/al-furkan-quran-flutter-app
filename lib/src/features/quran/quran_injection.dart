import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../constants/app_strings.dart';
import '../quran/data/datasources/quran_local_data_source.dart';
import '../quran/data/repositories/quran_repository_impl.dart';
import '../quran/domain/repositories/quran_repository.dart';
import '../quran/domain/usecases/get_all_surahs.dart';
import '../quran/domain/usecases/get_quran_page.dart';
import '../quran/domain/usecases/search_ayahs.dart';
import '../quran/presentation/quran_bloc.dart';

/// Feature-level DI registration for the Quran module
/// Called from the main service locator during app bootstrap
class QuranInjection {
  QuranInjection._();

  static void init(GetIt sl) {
    // ── Data Sources ──
    sl.registerLazySingleton<QuranLocalDataSource>(
      () => QuranLocalDataSource(
        userBox: Hive.box(AppStrings.hiveBoxUser),
        pinnedBox: Hive.box(AppStrings.hiveBoxPinned),
      ),
    );

    // ── Repositories ──
    sl.registerLazySingleton<QuranRepository>(
      () => QuranRepositoryImpl(localDataSource: sl<QuranLocalDataSource>()),
    );

    // ── Use Cases ──
    sl.registerLazySingleton(() => GetAllSurahsUseCase(sl<QuranRepository>()));
    sl.registerLazySingleton(() => GetQuranPageUseCase(sl<QuranRepository>()));
    sl.registerLazySingleton(() => SearchAyahsUseCase(sl<QuranRepository>()));

    // ── BLoC ──
    sl.registerFactory(() => QuranBloc(
          getAllSurahs: sl<GetAllSurahsUseCase>(),
          getQuranPage: sl<GetQuranPageUseCase>(),
          searchAyahs: sl<SearchAyahsUseCase>(),
        ));
  }
}
