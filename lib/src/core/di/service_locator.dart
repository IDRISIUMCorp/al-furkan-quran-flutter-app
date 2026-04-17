import "package:al_furkan/src/core/audio/services/audio_playback_service.dart";
import "package:al_furkan/src/core/bootstrap/app_bootstrap_coordinator.dart";
import "package:al_furkan/src/core/notifications/notification_scheduler.dart";
import "package:al_furkan/src/core/quran_resources/quran_resources_repository.dart";
import "package:al_furkan/src/core/reader_session/reader_session_repository.dart";
import "package:al_furkan/src/core/settings/settings_repository.dart";
import "package:al_furkan/src/core/storage/app_boxes.dart";
import "package:al_furkan/src/core/storage/app_storage.dart";
import "package:get_it/get_it.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:shared_preferences/shared_preferences.dart";

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies({
  required SharedPreferences preferences,
}) async {
  if (getIt.isRegistered<AppStorage>()) {
    await getIt.reset();
  }

  getIt.registerSingleton<AppStorage>(
    AppStorage(
      preferences: preferences,
      userBox: Hive.box<dynamic>(AppBoxes.user),
      pinnedBox: Hive.box<dynamic>(AppBoxes.pinned),
      notesBox: Hive.box<dynamic>(AppBoxes.notes),
    ),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => LocalSettingsRepository(getIt<AppStorage>()),
  );
  getIt.registerLazySingleton<ReaderSessionRepository>(
    () => LocalReaderSessionRepository(getIt<AppStorage>()),
  );
  getIt.registerLazySingleton<AudioPlaybackService>(
    LocalAudioPlaybackService.new,
  );
  getIt.registerLazySingleton<QuranResourcesRepository>(
    LocalQuranResourcesRepository.new,
  );
  getIt.registerLazySingleton<NotificationScheduler>(
    LocalNotificationScheduler.new,
  );
  getIt.registerLazySingleton<AppBootstrapCoordinator>(
    () => AppBootstrapCoordinator(
      settingsRepository: getIt<SettingsRepository>(),
      notificationScheduler: getIt<NotificationScheduler>(),
      quranResourcesRepository: getIt<QuranResourcesRepository>(),
    ),
  );
}
