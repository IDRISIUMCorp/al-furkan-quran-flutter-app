import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/app_strings.dart';
import '../audio/data/datasources/audio_data_source.dart';
import '../audio/data/repositories/audio_repository_impl.dart';
import '../audio/domain/repositories/audio_repository.dart';
import '../audio/presentation/audio_bloc.dart';

/// Feature-level DI registration for the Audio module
class AudioInjection {
  AudioInjection._();

  static void init(GetIt sl) {
    // ── Data Sources ──
    sl.registerLazySingleton<AudioRemoteDataSource>(
      () => AudioRemoteDataSource(),
    );
    sl.registerLazySingleton<AudioLocalDataSource>(
      () => AudioLocalDataSource(
        cacheBox: Hive.box(AppStrings.hiveBoxUser),
        prefs: sl<SharedPreferences>(),
      ),
    );

    // ── Repositories ──
    sl.registerLazySingleton<AudioRepository>(
      () => AudioRepositoryImpl(
        remoteDataSource: sl<AudioRemoteDataSource>(),
        localDataSource: sl<AudioLocalDataSource>(),
      ),
    );

    // ── BLoC ──
    sl.registerFactory(() => AudioBloc(audioRepository: sl<AudioRepository>()));
  }
}
