import "dart:async";
import "dart:developer";
import "dart:ui";

import "package:al_furkan/l10n/app_localizations.dart";
import "package:al_furkan/src/core/audio/cubit/audio_ui_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/ayah_key_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/player_position_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/player_state_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/segmented_quran_reciter_cubit.dart";
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
import "package:al_furkan/src/theme/app_theme.dart";
import "package:al_furkan/src/theme/controller/theme_cubit.dart";
import "package:al_furkan/src/theme/controller/theme_state.dart";
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

String? applicationDataPath;
platform_services.PlatformOwn platformOwn = platform_services.getPlatform();

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

    final bootstrapCoordinator = getIt<AppBootstrapCoordinator>();
    final bootstrapSnapshot = await bootstrapCoordinator.prepareApp(
      loadLocationState: LocationQiblaPrayerDataCubit.getSavedState,
    );
    await bootstrapCoordinator.prepareLaunch();

    log(bootstrapSnapshot.locationState.madhab.toString(), name: "Madhab");

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
    
    // في حالة الخطأ الكارثي، نعرض شاشة خطأ بسيطة
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'حدث خطأ أثناء تشغيل التطبيق',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'الرجاء إعادة تشغيل التطبيق',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // محاولة إعادة التشغيل
                      SystemNavigator.pop();
                    },
                    child: const Text('إغلاق'),
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
    });
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
          
          context.read<AyahToHighlight>().changeAyah("$surah:$verse");
          
          Future.delayed(const Duration(seconds: 5), () {
            if (context.mounted) {
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

/// 🏠 معالج الشاشة الافتراضية
/// دائماً يفتح على شاشة المصحف
class _DefaultScreenHandler extends StatelessWidget {
  const _DefaultScreenHandler();

  @override
  Widget build(BuildContext context) {
    return const MushafScreen();
  }
}

