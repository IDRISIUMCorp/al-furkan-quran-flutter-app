import "dart:async";
import "dart:developer";
import "dart:io";
import "dart:ui";

import "package:al_furkan/l10n/app_localizations.dart";
import "package:al_furkan/src/core/audio/cubit/audio_ui_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/ayah_key_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/player_position_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/player_state_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/segmented_quran_reciter_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/offline_download_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/sleep_timer_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/ayah_repeat_cubit.dart";
import "package:al_furkan/src/core/reading_stats/reading_stats_cubit.dart";
import "package:al_furkan/src/core/hifz/hifz_cubit.dart";
import "package:al_furkan/src/core/night_mode/night_reading_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/custom_playlist_cubit.dart";
import "package:al_furkan/src/core/audio/player/audio_player_manager.dart";
import "package:al_furkan/src/core/audio/services/audio_player_ui_bridge.dart";
import "package:al_furkan/src/core/bootstrap/app_bootstrap_coordinator.dart";
import "package:al_furkan/src/core/di/service_locator.dart";
import "package:al_furkan/src/core/reader_session/reader_session_repository.dart";
import "package:al_furkan/src/core/settings/settings_repository.dart";
import "package:al_furkan/src/core/storage/app_boxes.dart";
import "package:al_furkan/src/core/unified_quran_settings/cubit/quran_settings_cubit.dart";
import "package:al_furkan/src/core/error/release_error_handler.dart";
import "package:al_furkan/src/core/services/ayah_of_the_day_service.dart";
import "package:al_furkan/src/platform_services.dart" as platform_services;
import "package:al_furkan/src/resources/translation/language_cubit.dart";
import "package:al_furkan/src/resources/translation/languages.dart";
import "package:al_furkan/src/screen/location_handler/cubit/location_data_qibla_data_cubit.dart";
import "package:al_furkan/src/screen/location_handler/model/location_data_qibla_data_state.dart";
import "package:al_furkan/src/screen/mushaf/mushaf_screen.dart";
import "package:al_furkan/src/screen/prayer_time/cubit/prayer_time_cubit.dart";
import "package:al_furkan/src/screen/prayer_time/prayer_time_page.dart";
import "package:al_furkan/src/screen/azkar/azkar_categories_screen.dart";
import "package:al_furkan/src/screen/quran_script_view/quran_script_view.dart";
import "package:al_furkan/src/utils/quran_ayahs_function/gen_ayahs_key.dart";
import "package:al_furkan/src/screen/quran_reader/cubit/reader_ui_cubit.dart";
import "package:al_furkan/src/screen/quran_script_view/cubit/ayah_by_ayah_in_scroll_info_cubit.dart";
import "package:al_furkan/src/screen/quran_script_view/cubit/ayah_to_highlight.dart";
import "package:al_furkan/src/screen/quran_script_view/cubit/landscape_scroll_effect.dart";
import "package:al_furkan/src/screen/settings/cubit/quran_script_view_cubit.dart";
import "package:al_furkan/src/screen/setup/cubit/resources_progress_cubit_cubit.dart";
import "package:al_furkan/core/auth/auth_cubit.dart";
import "package:al_furkan/src/theme/app_theme.dart";
import "package:al_furkan/src/theme/controller/theme_cubit.dart";
import "package:al_furkan/src/theme/controller/theme_state.dart";
import "package:al_furkan/src/core/audio/services/idrisium_audio_tracker.dart";
import "package:al_furkan/src/widget/history/cubit/quran_history_cubit.dart";
import "package:al_furkan/src/widget/quran_script_words/cubit/word_playing_state_cubit.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_native_splash/flutter_native_splash.dart";
import "package:flutter_screenutil/flutter_screenutil.dart";
import "package:google_fonts/google_fonts.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:home_widget/home_widget.dart";
import "package:just_audio_background/just_audio_background.dart";
import "package:just_audio_media_kit/just_audio_media_kit.dart";
import "package:shared_preferences/shared_preferences.dart";

import "package:al_furkan/src/screen/prayer_time/sunnah_prayer_page.dart";
import "package:al_furkan/src/screen/prayer_time/sunnah_wudu_page.dart";
import "package:al_furkan/core/services/firebase_service.dart";
import "package:al_furkan/features/analytics/services/analytics_tracker.dart";


String? applicationDataPath;
platform_services.PlatformOwn platformOwn = platform_services.getPlatform();

/// Opens a Hive box with timeout and corruption recovery.
/// If the box fails to open (corruption, lock, etc.), it deletes and recreates it.
/// Throws as a last resort so the caller can handle the unrecoverable case.
Future<void> _safeOpenBox(String name, {Duration timeout = const Duration(seconds: 8)}) async {
  try {
    if (Hive.isBoxOpen(name)) return;
    await Hive.openBox(name).timeout(timeout);
  } catch (e) {
    log("⚠️ Failed to open box '$name': $e — attempting recovery", name: "HiveSafeOpen");
    try {
      // Close any stale reference first
      if (Hive.isBoxOpen(name)) {
        await Hive.box(name).close().timeout(const Duration(seconds: 3));
      }
      // Try to delete the corrupted box and recreate it.
      await Hive.deleteBoxFromDisk(name).timeout(const Duration(seconds: 5));
      await Hive.openBox(name).timeout(timeout);
      log("✅ Box '$name' recovered successfully", name: "HiveSafeOpen");
    } catch (e2) {
      log("❌ CRITICAL: Box '$name' recovery also failed: $e2 — nuclear reset", name: "HiveSafeOpen");
      // Nuclear: delete ALL boxes from disk and retry
      try {
        await Hive.deleteBoxFromDisk(name).timeout(const Duration(seconds: 5));
        await Hive.openBox(name).timeout(timeout);
        log("✅ Box '$name' opened after nuclear reset", name: "HiveSafeOpen");
      } catch (e3) {
        log("💥 UNRECOVERABLE: Box '$name' cannot be opened: $e3", name: "HiveSafeOpen");
        // Don't silently swallow — let the caller know
        rethrow;
      }
    }
  }
}

/// Opens a Hive LazyBox with timeout and corruption recovery.
Future<void> _safeOpenLazyBox(String name, {Duration timeout = const Duration(seconds: 8)}) async {
  try {
    if (Hive.isBoxOpen(name)) return;
    await Hive.openLazyBox(name).timeout(timeout);
  } catch (e) {
    log("⚠️ Failed to open lazy box '$name': $e — attempting recovery", name: "HiveSafeOpen");
    try {
      if (Hive.isBoxOpen(name)) {
        await Hive.box(name).close().timeout(const Duration(seconds: 3));
      }
      await Hive.deleteBoxFromDisk(name).timeout(const Duration(seconds: 5));
      await Hive.openLazyBox(name).timeout(timeout);
      log("✅ Lazy box '$name' recovered", name: "HiveSafeOpen");
    } catch (_) {
      // Lazy box corruption is less critical — log and continue
      log("⚠️ Lazy box '$name' skipped (corrupted)", name: "HiveSafeOpen");
    }
  }
}

Future<void> main() async {
  // تفعيل معالج الأخطاء للـ Release Mode
  ReleaseErrorHandler.initialize();
  
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  
  // Safety timeout - إزالة الـ splash بعد 10 ثواني كحد أقصى
  Future.delayed(const Duration(seconds: 10), () {
    try {
      FlutterNativeSplash.remove();
    } catch (e) {
      log("Timeout splash removal failed: $e", name: "SplashTimeout");
    }
  });

  try {
    await platform_services.initializePlatform();
    await FirebaseService.instance.init();

    // تكوين Google Fonts لاستخدام الخطوط المحلية
    GoogleFonts.config.allowRuntimeFetching = false;
    
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    applicationDataPath = await platform_services.getApplicationDataPath();

    if (platformOwn == platform_services.PlatformOwn.isWindows ||
        platformOwn == platform_services.PlatformOwn.isLinux) {
      Hive.init("${applicationDataPath!}/db");
    } else {
      await Hive.initFlutter();
    }

    await _safeOpenBox(AppBoxes.user);
    await _safeOpenBox(AppBoxes.pinned);
    await _safeOpenBox(AppBoxes.notes);
    await _safeOpenBox(AppBoxes.readingStats);

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

    final bootstrapCoordinator = getIt<AppBootstrapCoordinator>();
    final bootstrapSnapshot = await bootstrapCoordinator.prepareApp(
      loadLocationState: LocationQiblaPrayerDataCubit.getSavedState,
    );
    await bootstrapCoordinator.prepareLaunch();

    log(bootstrapSnapshot.locationState.madhab.toString(), name: "Madhab");

    // Initialize Analytics Tracker
    await AnalyticsTracker.instance.init();

    runApp(
      MyApp(
        initialLocale: bootstrapSnapshot.initialLocale,
        locationQiblaPrayerDataState: bootstrapSnapshot.locationState,
      ),
    );
    
    unawaited(
      bootstrapCoordinator.runDeferredWarmup().catchError((error, stackTrace) {
        log(
          "Deferred warmup failed after app launch: $error\n$stackTrace",
          name: "AppBootstrapWarmup",
        );
      }),
    );
    
    // Automatically render widgets on startup so they don't look like empty icons.
    unawaited(
      AyahOfTheDayService.updateWidget(forceRefresh: true).catchError((_) {}),
    );
    
    platform_services.hideLoadingIndicator();
  } catch (e, stackTrace) {
    log("Fatal error during app initialization: $e\n$stackTrace", name: "AppInit");
    // إزالة الـ splash حتى لو حصل error
    try {
      FlutterNativeSplash.remove();
    } catch (_) {}
    
    // في حالة الخطأ الكارثي، نعرض شاشة خطأ مع خيار مسح البيانات
    runApp(
      MaterialApp(
        home: _FatalErrorScreen(error: e),
      ),
    );
  }
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
    // إزالة الـ splash screen بشكل آمن
    try {
      FlutterNativeSplash.remove();
    } catch (e) {
      log("Failed to remove splash: $e", name: "SplashRemoval");
    }

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
          BlocProvider(create: (_) => AuthCubit()),
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
          BlocProvider(create: (_) => OfflineDownloadCubit()),
          BlocProvider(create: (_) => PlayerStateCubit(PlayerState())),
          BlocProvider(create: (_) => WordPlayingStateCubit()),
          BlocProvider(create: (_) => AudioAyahHighlightCubit()),
          BlocProvider(create: (_) => SleepTimerCubit()),
          BlocProvider(create: (_) => AyahRepeatCubit()),
          BlocProvider(create: (_) => ReadingStatsCubit()),
          BlocProvider(create: (_) => HifzCubit()),
          BlocProvider(create: (_) => NightReadingCubit()),
          BlocProvider(create: (_) => CustomPlaylistCubit()),
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
                      theme: AppTheme.lightTheme()
                          .copyWith(
                            pageTransitionsTheme: pageTransitionsTheme,
                            textTheme: getTextTheme(
                              languageState.locale,
                              false,
                            ),
                          ),
                      darkTheme: AppTheme.darkTheme()
                          .copyWith(
                            pageTransitionsTheme: pageTransitionsTheme,
                            textTheme: getTextTheme(languageState.locale, true),
                          ),
                      themeMode: themeState.themeMode,
                      builder: (context, child) {
                        return _FullscreenEnforcer(
                          child: _AudioPlayerBridgeBinder(
                            child: child ?? const SizedBox.shrink(),
                          ),
                        );
                      },
                      scrollBehavior: AppScrollBehavior(),
                      home: const _DefaultScreenHandler(),
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingSunnahPage();
      _setupHomeWidgetDeepLinks();
      _connectSleepTimerAndRepeat();
    });
  }

  void _connectSleepTimerAndRepeat() {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) return;

    // Sleep Timer → stop playback when timer expires
    final sleepCubit = ctx.read<SleepTimerCubit>();
    sleepCubit.onSleepTimerExpired.listen((_) {
      AudioPlayerManager.audioPlayer.pause();
    });

    // Playback completed → notify sleep timer (end-of-surah) & repeat
    AudioPlayerManager.onPlaybackCompleted = () {
      sleepCubit.onSurahCompleted();
      final repeatCubit = ctx.read<AyahRepeatCubit>();
      if (repeatCubit.state.isActive) {
        repeatCubit.onRepetitionCompleted();
      }
    };
  }

  void _setupHomeWidgetDeepLinks() {
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_handleWidgetDeepLink);
    HomeWidget.widgetClicked.listen(_handleWidgetDeepLink);
  }

  void _handleWidgetDeepLink(Uri? uri) {
    if (uri == null || navigatorKey.currentContext == null) return;
    final action = uri.queryParameters['action'];
    if (action == 'jump_to_ayah') {
      final surahStr = uri.queryParameters['surah'];
      final verseStr = uri.queryParameters['verse'];
      if (surahStr != null && verseStr != null) {
        final surah = int.tryParse(surahStr);
        final verse = int.tryParse(verseStr);
        if (surah != null && verse != null) {
          final context = navigatorKey.currentContext!;
          Navigator.of(context).popUntil((route) => route.isFirst);
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuranScriptView(
                startKey: "$surah:1",
                endKey: getEndAyahKeyFromSurahNumber(surah),
                toScrollKey: "$surah:$verse",
              ),
            ),
          );
          
          final isAudioPlaying = context.read<AudioAyahHighlightCubit>().state.activeAyahKey != null;
          if (!isAudioPlaying) {
            context.read<AyahToHighlight>().changeAyah("$surah:$verse");
          }
          
          Future.delayed(const Duration(seconds: 5), () {
            if (context.mounted && !isAudioPlaying) {
              context.read<AyahToHighlight>().changeAyah(null);
            }
          });
        }
      }
    } else if (action == 'open_azkar') {
      Navigator.of(navigatorKey.currentContext!).popUntil((route) => route.isFirst);
      Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (_) => const AzkarCategoriesScreen()),
      );
    } else if (action == 'open_prayer') {
      Navigator.of(navigatorKey.currentContext!).popUntil((route) => route.isFirst);
      Navigator.push(
        navigatorKey.currentContext!,
        MaterialPageRoute(builder: (_) => const PrayerTimePage()),
      );
    }
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
      _checkPendingSunnahPage();
      return;
    }

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _flush();
    }
  }

  Future<void> _checkPendingSunnahPage() async {
    try {
      final box = Hive.box(AppBoxes.user);
      final pending = box.get("pending_sunnah_page") as String?;
      if (pending != null && pending.isNotEmpty) {
        await box.delete("pending_sunnah_page");
        if (navigatorKey.currentContext != null) {
          if (pending == "SUNNAH_WUDU") {
            Navigator.push(
              navigatorKey.currentContext!,
              MaterialPageRoute(builder: (_) => const SunnahWuduPage()),
            );
          } else if (pending == "SUNNAH_PRAYER") {
            Navigator.push(
              navigatorKey.currentContext!,
              MaterialPageRoute(builder: (_) => const SunnahPrayerPage()),
            );
          }
        }
      }
    } catch (_) {}
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
      AnalyticsTracker.instance.endSession();
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
  bool _isBound = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isBound) return;
    _isBound = true;
    AudioPlayerManager.bindUiBridge(
      BlocAudioPlayerUiBridge(
        context: context,
        audioUiCubit: context.read<AudioUiCubit>(),
        playerPositionCubit: context.read<PlayerPositionCubit>(),
        playerStateCubit: context.read<PlayerStateCubit>(),
        ayahKeyCubit: context.read<AyahKeyCubit>(),
        quranViewCubit: context.read<QuranViewCubit>(),
        wordPlayingStateCubit: context.read<WordPlayingStateCubit>(),
        highlightCubit: context.read<AudioAyahHighlightCubit>(),
        reciterCubit: context.read<SegmentedQuranReciterCubit>(),
        ayahToHighlight: context.read<AyahToHighlight>(),
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

/// 🖥️ يفرض وضع ملء الشاشة (immersiveSticky) بشكل دائم
/// أي تغيير في SystemUiOverlayStyle من أي widget بيخلي الـ bars تظهر
/// هذا الـ wrapper بيعيد فرض الـ immersive mode كل ما الـ widget يترسم
class _FullscreenEnforcer extends StatefulWidget {
  final Widget child;
  const _FullscreenEnforcer({required this.child});

  @override
  State<_FullscreenEnforcer> createState() => _FullscreenEnforcerState();
}

class _FullscreenEnforcerState extends State<_FullscreenEnforcer>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _enforceFullscreen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Re-enforce fullscreen when app comes back to foreground
    if (state == AppLifecycleState.resumed) {
      _enforceFullscreen();
    }
  }

  void _enforceFullscreen() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  Widget build(BuildContext context) {
    // Re-enforce on every build to counter any overlay style changes
    _enforceFullscreen();
    return widget.child;
  }
}

/// 🏠 معالج الشاشة الافتراضية
/// دائماً يفتح على شاشة المصحف
class _DefaultScreenHandler extends StatelessWidget {
  const _DefaultScreenHandler();

  @override
  Widget build(BuildContext context) {
    // الأدمن والمستخدم كلهم بيفتحوا المصحف.
    // لوحة التحكم بتتفتح من القائمة الجانبية (WahySideDrawer).
    return const MushafScreen();
  }
}

/// شاشة خطأ كارثي مع خيار مسح البيانات
class _FatalErrorScreen extends StatefulWidget {
  const _FatalErrorScreen({required this.error});
  final Object error;

  @override
  State<_FatalErrorScreen> createState() => _FatalErrorScreenState();
}

class _FatalErrorScreenState extends State<_FatalErrorScreen> {
  bool _isResetting = false;

  Future<void> _resetAppAndRestart() async {
    setState(() => _isResetting = true);
    try {
      // Close all open Hive boxes
      try {
        await Hive.close();
      } catch (_) {}

      // Delete all Hive box files from disk
      try {
        final dir = await platform_services.getApplicationDataPath();
        if (platformOwn == platform_services.PlatformOwn.isWindows ||
            platformOwn == platform_services.PlatformOwn.isLinux) {
          final dbDir = Directory("$dir/db");
          if (dbDir.existsSync()) {
            dbDir.deleteSync(recursive: true);
          }
        } else {
          // On Android/iOS, Hive stores in app documents dir
          final hiveDir = Directory("$dir/hive");
          if (hiveDir.existsSync()) {
            hiveDir.deleteSync(recursive: true);
          }
        }
      } catch (_) {}

      // Clear SharedPreferences too
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      } catch (_) {}

      // Restart the app
      SystemNavigator.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isResetting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("فشل المسح: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.error_outline_rounded,
                      size: 56,
                      color: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'حدث خطأ أثناء تشغيل التطبيق',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '${widget.error}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 32),
                  // Reset button — primary action
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _isResetting ? null : _resetAppAndRestart,
                      icon: _isResetting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.delete_forever_rounded),
                      label: Text(
                        _isResetting ? 'جاري المسح...' : 'مسح البيانات وإعادة التشغيل',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Close button — secondary action
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () => SystemNavigator.pop(),
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: const Text(
                        'إغلاق التطبيق',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white54,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'مسح البيانات هيحل المشكلة لكن هيشيل التفاسير والترجمات المحملة',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

