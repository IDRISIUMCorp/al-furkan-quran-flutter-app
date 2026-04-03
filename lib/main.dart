import "dart:developer";
import "dart:ui";

import "package:al_quran_v3/l10n/app_localizations.dart";
import "package:al_quran_v3/src/core/audio/cubit/audio_ui_cubit.dart";
import "package:al_quran_v3/src/core/audio/cubit/ayah_key_cubit.dart";
import "package:al_quran_v3/src/core/audio/cubit/player_position_cubit.dart";
import "package:al_quran_v3/src/core/audio/cubit/player_state_cubit.dart";
import "package:al_quran_v3/src/core/audio/cubit/segmented_quran_reciter_cubit.dart";
import "package:al_quran_v3/src/core/audio/player/audio_player_manager.dart";
import "package:al_quran_v3/src/core/audio/services/audio_player_ui_bridge.dart";
import "package:al_quran_v3/src/core/bootstrap/app_bootstrap_coordinator.dart";
import "package:al_quran_v3/src/core/di/service_locator.dart";
import "package:al_quran_v3/src/core/reader_session/reader_session_repository.dart";
import "package:al_quran_v3/src/core/settings/settings_repository.dart";
import "package:al_quran_v3/src/core/storage/app_boxes.dart";
import "package:al_quran_v3/src/core/unified_quran_settings/cubit/quran_settings_cubit.dart";
import "package:al_quran_v3/src/platform_services.dart" as platform_services;
import "package:al_quran_v3/src/resources/translation/language_cubit.dart";
import "package:al_quran_v3/src/resources/translation/languages.dart";
import "package:al_quran_v3/src/screen/location_handler/cubit/location_data_qibla_data_cubit.dart";
import "package:al_quran_v3/src/screen/location_handler/model/location_data_qibla_data_state.dart";
import "package:al_quran_v3/src/screen/prayer_time/cubit/prayer_time_cubit.dart";
import "package:al_quran_v3/src/screen/quran_bootstrap/quran_bootstrap_page.dart";
import "package:al_quran_v3/src/screen/quran_reader/cubit/reader_ui_cubit.dart";
import "package:al_quran_v3/src/screen/quran_script_view/cubit/ayah_by_ayah_in_scroll_info_cubit.dart";
import "package:al_quran_v3/src/screen/quran_script_view/cubit/ayah_to_highlight.dart";
import "package:al_quran_v3/src/screen/quran_script_view/cubit/landscape_scroll_effect.dart";
import "package:al_quran_v3/src/screen/settings/cubit/quran_script_view_cubit.dart";
import "package:al_quran_v3/src/screen/setup/cubit/resources_progress_cubit_cubit.dart";
import "package:al_quran_v3/src/theme/app_theme.dart";
import "package:al_quran_v3/src/theme/controller/theme_cubit.dart";
import "package:al_quran_v3/src/theme/controller/theme_state.dart";
import "package:al_quran_v3/src/widget/history/cubit/quran_history_cubit.dart";
import "package:al_quran_v3/src/widget/quran_script_words/cubit/word_playing_state_cubit.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:google_fonts/google_fonts.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:just_audio_background/just_audio_background.dart";
import "package:just_audio_media_kit/just_audio_media_kit.dart";
import "package:shared_preferences/shared_preferences.dart";

String? applicationDataPath;
platform_services.PlatformOwn platformOwn = platform_services.getPlatform();

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await platform_services.initializePlatform();

  GoogleFonts.config.allowRuntimeFetching = false;
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  applicationDataPath = await platform_services.getApplicationDataPath();

  if (platformOwn == platform_services.PlatformOwn.isWindows ||
      platformOwn == platform_services.PlatformOwn.isLinux) {
    Hive.init("${applicationDataPath!}/db");
  } else {
    await Hive.initFlutter();
  }

  await Hive.openBox(AppBoxes.user);
  await Hive.openBox(AppBoxes.pinned);
  await Hive.openBox(AppBoxes.notes);

  if (platformOwn != platform_services.PlatformOwn.isLinux &&
      platformOwn != platform_services.PlatformOwn.isWindows) {
    await JustAudioBackground.init(
      androidNotificationChannelId: "com.ryanheise.bg_demo.channel.audio",
      androidNotificationChannelName: "Audio playback",
      androidNotificationOngoing: true,
    );
  } else {
    try {
      JustAudioMediaKit.ensureInitialized();
      JustAudioMediaKit.bufferSize = 8 * 1024 * 1024;
      JustAudioMediaKit.title = "Al Quran Audio";
    } catch (e) {
      log("Unable To Config JustAudioMediaKit with error: $e");
    }
  }

  final prefs = await SharedPreferences.getInstance();
  await configureDependencies(preferences: prefs);

  final bootstrapSnapshot = await getIt<AppBootstrapCoordinator>().prepareApp(
    loadLocationState: LocationQiblaPrayerDataCubit.getSavedState,
  );

  log(bootstrapSnapshot.locationState.madhab.toString(), name: "Madhab");

  runApp(
    MyApp(
      initialLocale: bootstrapSnapshot.initialLocale,
      locationQiblaPrayerDataState: bootstrapSnapshot.locationState,
    ),
  );
  platform_services.hideLoadingIndicator();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

TextTheme getTextTheme(Locale locale, bool isDarkMode) {
  final textTheme = isDarkMode
      ? ThemeData.dark().textTheme
      : ThemeData.light().textTheme;
  return textTheme.apply(fontFamily: "NotoSans");
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.initialLocale,
    required this.locationQiblaPrayerDataState,
  });

  final MyAppLocalization initialLocale;
  final LocationQiblaPrayerDataState locationQiblaPrayerDataState;

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();

    const pageTransitionsTheme = PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      },
    );

    return _UsageTimeTracker(
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ResourcesProgressCubit()),
          BlocProvider(create: (_) => ThemeCubit()),
          BlocProvider(create: (_) => AudioUiCubit()),
          BlocProvider(create: (_) => PlayerPositionCubit()),
          BlocProvider(create: (_) => AyahKeyCubit()),
          BlocProvider(create: (_) => AyahByAyahInScrollInfoCubit()),
          BlocProvider(
            create: (_) => LocationQiblaPrayerDataCubit(
              initState: locationQiblaPrayerDataState,
            ),
          ),
          BlocProvider(create: (_) => SegmentedQuranReciterCubit()),
          BlocProvider(create: (_) => PlayerStateCubit(PlayerState())),
          BlocProvider(create: (_) => WordPlayingStateCubit()),
          BlocProvider(
            create: (_) => QuranViewCubit(getIt<SettingsRepository>()),
          ),
          BlocProvider(
            create: (_) => PrayerReminderCubit(getIt<SettingsRepository>()),
          ),
          BlocProvider(create: (_) => LanguageCubit(initialLocale)),
          BlocProvider(create: (_) => LandscapeScrollEffect()),
          BlocProvider(create: (_) => QuranHistoryCubit()),
          BlocProvider(create: (_) => AyahToHighlight(null)),
          BlocProvider(
            create: (_) => ReaderUICubit(getIt<ReaderSessionRepository>()),
          ),
          BlocProvider(create: (_) => QuranSettingsCubit()),
        ],
        child: BlocBuilder<LanguageCubit, MyAppLocalization>(
          builder: (context, languageState) {
            return BlocBuilder<ThemeCubit, ThemeState>(
              builder: (context, themeState) {
                return ScreenUtilInit(
                  designSize: const Size(360, 690),
                  minTextAdapt: true,
                  splitScreenMode: true,
                  builder: (_, child) {
                    return MaterialApp(
                      navigatorKey: navigatorKey,
                      debugShowCheckedModeBanner: false,
                      locale: languageState.locale,
                      localizationsDelegates: const [
                        AppLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      supportedLocales: AppLocalizations.supportedLocales,
                      onGenerateTitle: (_) => "الفُرقان",
                      theme: AppTheme.lightTheme(themeState.flexScheme)
                          .copyWith(
                            pageTransitionsTheme: pageTransitionsTheme,
                            textTheme: getTextTheme(
                              languageState.locale,
                              false,
                            ),
                          ),
                      darkTheme: AppTheme.darkTheme(themeState.flexScheme)
                          .copyWith(
                            pageTransitionsTheme: pageTransitionsTheme,
                            textTheme: getTextTheme(languageState.locale, true),
                          ),
                      themeMode: themeState.themeMode,
                      builder: (context, child) {
                        return _AudioPlayerBridgeBinder(
                          child: child ?? const SizedBox.shrink(),
                        );
                      },
                      scrollBehavior: AppScrollBehavior(),
                      home: const QuranBootstrapPage(),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _UsageTimeTracker extends StatefulWidget {
  const _UsageTimeTracker({required this.child});

  final Widget child;

  @override
  State<_UsageTimeTracker> createState() => _UsageTimeTrackerState();
}

class _UsageTimeTrackerState extends State<_UsageTimeTracker>
    with WidgetsBindingObserver {
  static const _kUsageSeconds = "usage_time_seconds";
  DateTime? _sessionStart;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _sessionStart = DateTime.now();
  }

  @override
  void dispose() {
    _flush();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _sessionStart ??= DateTime.now();
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _flush();
    }
  }

  void _flush() {
    final start = _sessionStart;
    if (start == null) {
      return;
    }

    final seconds = DateTime.now().difference(start).inSeconds;
    _sessionStart = null;

    if (seconds <= 0) {
      return;
    }

    try {
      final box = Hive.box<dynamic>(AppBoxes.user);
      final previousValue =
          (box.get(_kUsageSeconds, defaultValue: 0) as int?) ?? 0;
      box.put(_kUsageSeconds, previousValue + seconds);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.trackpad,
    PointerDeviceKind.stylus,
  };
}

class _AudioPlayerBridgeBinder extends StatefulWidget {
  const _AudioPlayerBridgeBinder({required this.child});

  final Widget child;

  @override
  State<_AudioPlayerBridgeBinder> createState() =>
      _AudioPlayerBridgeBinderState();
}

class _AudioPlayerBridgeBinderState extends State<_AudioPlayerBridgeBinder> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    AudioPlayerManager.bindUiBridge(
      BlocAudioPlayerUiBridge(
        context: context,
        audioUiCubit: context.read<AudioUiCubit>(),
        playerPositionCubit: context.read<PlayerPositionCubit>(),
        playerStateCubit: context.read<PlayerStateCubit>(),
        ayahKeyCubit: context.read<AyahKeyCubit>(),
        quranViewCubit: context.read<QuranViewCubit>(),
        wordPlayingStateCubit: context.read<WordPlayingStateCubit>(),
      ),
    );
  }

  @override
  void dispose() {
    AudioPlayerManager.bindUiBridge(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
