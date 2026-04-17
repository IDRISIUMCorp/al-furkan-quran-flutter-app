import "dart:developer";

import "package:al_furkan/src/core/notifications/notification_scheduler.dart";
import "package:al_furkan/src/core/quran_resources/quran_resources_repository.dart";
import "package:al_furkan/src/core/settings/settings_repository.dart";
import "package:al_furkan/src/platform_services.dart" as platform_services;
import "package:al_furkan/src/resources/translation/language_cubit.dart";
import "package:al_furkan/src/resources/translation/languages.dart";
import "package:al_furkan/src/screen/location_handler/model/location_data_qibla_data_state.dart";
import "package:al_furkan/src/theme/functions/theme_functions.dart";

class AppBootstrapSnapshot {
  const AppBootstrapSnapshot({
    required this.initialLocale,
    required this.locationState,
  });

  final MyAppLocalization initialLocale;
  final LocationQiblaPrayerDataState locationState;
}

class AppLaunchDestination {
  const AppLaunchDestination({required this.showOnboarding});

  final bool showOnboarding;
}

class AppBootstrapCoordinator {
  AppBootstrapCoordinator({
    required SettingsRepository settingsRepository,
    required NotificationScheduler notificationScheduler,
    required QuranResourcesRepository quranResourcesRepository,
  }) : _settingsRepository = settingsRepository,
       _notificationScheduler = notificationScheduler,
       _quranResourcesRepository = quranResourcesRepository;

  final SettingsRepository _settingsRepository;
  final NotificationScheduler _notificationScheduler;
  final QuranResourcesRepository _quranResourcesRepository;

  Future<AppBootstrapSnapshot> prepareApp({
    required Future<LocationQiblaPrayerDataState> Function() loadLocationState,
  }) async {
    final stopwatch = Stopwatch()..start();

    await _settingsRepository.applyFirstRunDefaults();
    _logPhase("first-run defaults", stopwatch);

    await _notificationScheduler.initialize();
    _logPhase("notifications", stopwatch);

    final initialLocale = await LanguageCubit.getInitialLocale();
    _logPhase("locale", stopwatch);

    await _quranResourcesRepository.initialize(locale: initialLocale.locale);
    _logPhase("quran resources", stopwatch);

    await ThemeFunctions.initThemeFunction();
    _logPhase("theme", stopwatch);

    final locationState = await loadLocationState();
    _logPhase("location state", stopwatch);

    return AppBootstrapSnapshot(
      initialLocale: initialLocale,
      locationState: locationState,
    );
  }

  Future<AppLaunchDestination> prepareLaunch() async {
    await _settingsRepository.ensureBootstrapDefaults();
    return AppLaunchDestination(
      showOnboarding: !_settingsRepository.isOnboardingV2Done(),
    );
  }

  Future<void> runDeferredWarmup() {
    final platform = platform_services.getPlatform();
    return _quranResourcesRepository.warmDeferredResources(
      scriptType: _settingsRepository.selectedQuranScriptType,
      enableBackgroundUpdates:
          platform == platform_services.PlatformOwn.isAndroid ||
          platform == platform_services.PlatformOwn.isIos,
    );
  }

  void _logPhase(String label, Stopwatch stopwatch) {
    log("[$label] ${stopwatch.elapsedMilliseconds}ms", name: "AppBootstrap");
  }
}
