import "dart:async";
import "dart:ui";
import 'package:al_furkan/src/screen/mushaf/widgets/wahy_feedback_dialog.dart';
import "package:al_furkan/src/screen/mushaf/widgets/wahy_mushaf_top_header.dart";
import 'package:al_furkan/src/screen/mushaf/widgets/mushaf_layout_widgets.dart';
import "package:al_furkan/src/screen/mushaf/wahy_library_store.dart";
import 'widgets/library_sheet.dart';
import "package:al_furkan/src/screen/mushaf/widgets/listen_range_sheet.dart";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:qcf_quran/qcf_quran.dart" hide getPageNumber;

import "package:al_furkan/src/core/audio/cubit/player_position_cubit.dart";
import "package:al_furkan/src/core/audio/model/audio_player_position_model.dart";
import "package:al_furkan/src/utils/quran_resources/segmented_resources_manager.dart";

import "package:al_furkan/main.dart";
import "package:al_furkan/src/core/audio/cubit/audio_ui_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/ayah_key_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/player_state_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/segmented_quran_reciter_cubit.dart";
import "package:al_furkan/src/core/audio/player/audio_player_manager.dart";
import "package:al_furkan/src/core/audio/services/audio_playback_service_access.dart";
import "package:al_furkan/src/core/notifications/khatma_notification_service.dart";
import "package:al_furkan/src/core/reading_stats/reading_stats_cubit.dart";
import "package:al_furkan/src/core/hifz/hifz_cubit.dart";
import "package:al_furkan/src/core/night_mode/night_reading_cubit.dart";
import "package:al_furkan/src/screen/quran_reader/widgets/ayah_options_sheet.dart";
import "package:al_furkan/src/screen/quran_resources/quran_resources_view.dart";
import "package:al_furkan/src/screen/offline_player/offline_player_screen.dart";
import "package:al_furkan/src/widget/audio/audio_controller_ui.dart";
import "package:al_furkan/src/core/audio/services/idrisium_audio_tracker.dart";
import "package:al_furkan/src/screen/quran_script_view/cubit/ayah_to_highlight.dart";
import "package:al_furkan/src/screen/quran_script_view/quran_script_view.dart";
import "package:al_furkan/src/screen/search/search_screen.dart";
import "package:al_furkan/src/screen/settings/cubit/quran_script_view_cubit.dart";
import "package:al_furkan/src/utils/quran_resources/quran_script_function.dart";
import "package:al_furkan/src/utils/quran_word/show_popup_word_function.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:al_furkan/src/utils/number_localization.dart";
import "package:al_furkan/src/widget/quran_script/model/script_info.dart";
import "package:al_furkan/src/widget/quran_script_words/cubit/word_playing_state_cubit.dart";
import "package:al_furkan/src/screen/settings/settings_page.dart";
import "package:al_furkan/src/core/unified_quran_settings/quran_settings_bottom_sheet.dart";
import "package:al_furkan/src/core/unified_quran_settings/cubit/quran_settings_cubit.dart";
import "package:al_furkan/src/screen/prayer_time/prayer_time_page.dart";
import "package:al_furkan/src/screen/qibla/qibla_direction.dart";
import "package:al_furkan/src/screen/mushaf/index/aya_index_page.dart";
// Removed audio_page.dart import
import "package:al_furkan/src/widget/add_collection_popup/add_note_popup.dart";
import "package:al_furkan/src/screen/about/about_the_app.dart";
import "package:al_furkan/src/screen/mushaf/widgets/khatma_sheet.dart";
import "package:al_furkan/src/screen/azkar/azkar_categories_screen.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:al_furkan/src/theme/controller/theme_cubit.dart";
import "package:al_furkan/src/theme/controller/theme_state.dart";
import "package:qcf_quran/qcf_quran.dart" as qcf;
import "package:al_furkan/src/resources/quran_resources/quran_pages_info.dart";
import "package:al_furkan/src/utils/basic_functions.dart";
import "package:al_furkan/src/theme/app_colors.dart";
import "package:al_furkan/src/widget/share/unified_share_bottom_sheet.dart";
part 'mushaf_share_extension.dart';
part 'mushaf_pronunciation_extension.dart';

class MushafScreen extends StatelessWidget {
  const MushafScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MushafRoot();
  }
}

class _MushafRoot extends StatefulWidget {
  const _MushafRoot();

  @override
  State<_MushafRoot> createState() => _MushafRootState();
}

class _MushafRootState extends State<_MushafRoot> {
  // ignore: prefer_final_fields
  bool _isMushafMode = true;
  bool _showHeader = true;

  final PageController _mushafPageController = PageController(
    initialPage: (() {
      final box = Hive.box("user");
      final savedPage = box.get("wahy_last_page", defaultValue: 1) as int;
      return (savedPage - 1).clamp(0, 603);
    })(),
  );

  bool _quranScriptReady = false;
  Future<void>? _quranScriptInitFuture;

  static Color _bg(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
      ? Color(0xFF141414)
      : Color(0xFFEDE4D4);
  static Color _onBg(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
      ? Colors.white
      : Color(0xFF1B1B1B);
  static const _headerHeight = 56.0;


  Future<void> _ensureQuranScriptReady() async {
    if (_quranScriptReady) return;
    _quranScriptInitFuture ??= () async {
      await QuranScriptFunction.initQuranScript(QuranScriptType.uthmani);
      _quranScriptReady = true;
    }();
    await _quranScriptInitFuture;
  }


  @override
  void initState() {
    super.initState();
    _ensureQuranScriptReady();

    // Restore last-read ayah key
    final box = Hive.box("user");
    final lastAyahKey = box.get("wahy_last_ayah_key") as String?;
    if (lastAyahKey != null && lastAyahKey.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        context.read<AyahKeyCubit>().changeCurrentAyahKey(lastAyahKey);
      });
    }

    // Save page on scroll
    _mushafPageController.addListener(_onPageChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final audioUi = context.read<AudioUiCubit>();
      audioUi.changeIsInsideQuran(true);
      audioUi.showUI(true);
      audioUi.expand(false);
    });
  }

  void _onPageChanged() {
    if (!_mushafPageController.hasClients) return;
    final page = _mushafPageController.page?.round();
    if (page != null) {
      Hive.box("user").put("wahy_last_page", page + 1);
      KhatmaNotificationService.instance.updateReminderTextIfNeeded();
    }
  }

  @override
  void dispose() {
    // Save last ayah key before leaving
    try {
      final lastKey = context.read<AyahKeyCubit>().state.current;
      if (lastKey.isNotEmpty) {
        Hive.box("user").put("wahy_last_ayah_key", lastKey);
      }
    } catch (_) {}
    _mushafPageController.removeListener(_onPageChanged);
    _mushafPageController.dispose();
    super.dispose();
  }

  void _navigateToMushafPage(int targetPage) {
    if (!_isMushafMode || !_mushafPageController.hasClients) return;
    final int currentPage = _mushafPageController.page?.round() ?? 0;
    if ((targetPage - currentPage).abs() > 2) {
      _mushafPageController.jumpToPage(targetPage);
    } else {
      _mushafPageController.animateToPage(
        targetPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _openIndexOverlay(Color backgroundColor) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "إغلاق الفهرس",
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 380),
      pageBuilder: (ctx, anim1, anim2) => Align(
        alignment: Alignment.centerRight,
        child: SizedBox(
          width: 340,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
            ),
            padding: EdgeInsets.zero,
            child: AyaIndexPage(
              isEmbedded: true,
              onOpenLocation: (page, ayahKey) {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).popUntil((route) => route.isFirst);
                context.read<AyahKeyCubit>().changeLastScrolledPage(page);
                final isAudioPlaying = context.read<AudioAyahHighlightCubit>().state.activeAyahKey != null;
                if (!isAudioPlaying) {
                  context.read<AyahKeyCubit>().changeCurrentAyahKey(ayahKey);
                  context.read<AyahToHighlight>().changeAyah(ayahKey);
                }
                _navigateToMushafPage(page - 1);
              },
            ),
          ),
        ),
      ),
      transitionBuilder: (ctx, anim1, anim2, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  Future<void> _openSearchScreen() async {
    final result = await showGeneralDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      barrierLabel: "Search",
      transitionDuration: const Duration(milliseconds: 650),
      pageBuilder: (ctx, anim1, anim2) => const SearchScreen(),
      transitionBuilder: (ctx, anim1, anim2, child) {
        final curved = CurvedAnimation(
          parent: anim1,
          curve: Curves.easeOutQuart,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        );
      },
    );
    if (result is! Map) return;
    if (!_isMushafMode || !_mushafPageController.hasClients) return;

    final page = result["page"] as int?;
    if (page != null) {
      _navigateToMushafPage(page - 1);
    }
  }

  void _handleTopMenuSelection(WahyMushafMenuAction action) {
    final primaryColor = context.read<ThemeCubit>().state.primary;
    switch (action) {
      case WahyMushafMenuAction.quranSettings:
        QuranSettingsBottomSheet.show(context);
        return;
      case WahyMushafMenuAction.azkar:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AzkarCategoriesScreen()),
        );
        return;
      case WahyMushafMenuAction.prayerTimes:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PrayerTimePage()),
        );
        return;
      case WahyMushafMenuAction.qibla:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QiblaDirection()),
        );
        return;
      case WahyMushafMenuAction.library:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QuranResourcesView()),
        );
        return;
      case WahyMushafMenuAction.offlinePlayer:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OfflinePlayerScreen()),
        );
        return;
      case WahyMushafMenuAction.settings:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsPage()),
        );
        return;
      case WahyMushafMenuAction.about:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AboutAppPage()),
        );
        return;
      case WahyMushafMenuAction.feedback:
        showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: "إغلاق الملاحظة",
          transitionDuration: const Duration(milliseconds: 320),
          pageBuilder: (ctx, anim1, anim2) =>
              WahyFeedbackDialog(primary: primaryColor),
          transitionBuilder: (ctx, anim1, anim2, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
                  ),
              child: FadeTransition(opacity: anim1, child: child),
            );
          },
        );
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.read<ThemeCubit>().state;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Theme.of(context).colorScheme.surface : AppColors.lightBackground;
    final topBarColor = isDark
        ? Theme.of(context).colorScheme.surface.withValues(alpha: 0.85)
        : AppColors.lightSurface.withValues(alpha: 0.85);
    final topBarBorderColor = isDark
        ? Colors.white10
        : AppColors.lightBorder.withValues(alpha: 0.5);

    final media = MediaQuery.of(context);
    final screenH = media.size.height;
    final safeH = (screenH - _headerHeight).clamp(1.0, screenH);
    final availableRatio = safeH / screenH;
    final mushafScale = (availableRatio + 0.12).clamp(0.84, 0.92);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      body: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setState(() => _showHeader = !_showHeader),
                child: Container(
                  color: _bg(context),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeOutCubic,
                    child: _isMushafMode
                        ? MushafView(
                            key: const ValueKey("mushaf"),
                            useDefaultAppBar: false,
                            initialPageNumber: context
                                .read<AyahKeyCubit>()
                                .state
                                .lastScrolledPageNumber,
                            controller: _mushafPageController,
                            spOverride: mushafScale,
                            hOverride: mushafScale,
                            onToggleHeader: () =>
                                setState(() => _showHeader = !_showHeader),
                          )
                        : QuranScriptView(
                            key: const ValueKey("ayah_by_ayah"),
                            startKey: "1:1",
                            endKey: "114:6",
                            toScrollKey: context
                                .read<AyahKeyCubit>()
                                .state
                                .current,
                            embedded: true,
                            topPaddingOverride: 0,
                            showAudioController: false,
                          ),
                  ),
                ),
              ),
            ),
            // Night Reading overlay
            BlocBuilder<NightReadingCubit, NightReadingState>(
              builder: (context, nightState) {
                if (!nightState.isActive) return const SizedBox.shrink();
                return Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      color: Color(nightState.overlayColorValue),
                    ),
                  ),
                );
              },
            ),
            // Top header (Beige)
            WahyMushafTopHeader(
              showHeader: _showHeader,
              headerHeight: _headerHeight,
              topInset: MediaQuery.of(context).padding.top,
              topBarColor: topBarColor,
              topBarBorderColor: topBarBorderColor,
              isMushafMode: _isMushafMode,
              iconPrimaryColor: AppColors.lightPrimary,
              menuPrimaryColor: themeState.primary,
              isDark: isDark,
              onOpenIndex: () => _openIndexOverlay(bgColor),
              onOpenSearch: _openSearchScreen,
              onToggleViewMode: () {
                setState(() => _isMushafMode = !_isMushafMode);
              },
              onOpenKhatma: () {
                showKhatmaSheet(
                  context: context,
                  bg: _bg(context),
                  onBg: _onBg(context),
                );
              },
              onMenuSelected: _handleTopMenuSelection,
            ),

            // Bottom mini audio controller (overlay)
            SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: const SizedBox.shrink(),
              ),
            ),

            SafeArea(
              top: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: const SizedBox.shrink(),
              ),
            ),

            // Audio Controller UI
            Positioned(
              left: 0,
              right: 0,
              bottom: 25,
              child: AnimatedSlide(
                duration: Duration(milliseconds: _showHeader ? 320 : 520),
                curve: Curves.easeInOutCubic,
                offset: _showHeader ? Offset.zero : const Offset(0, 1.15),
                child: AnimatedOpacity(
                  duration: Duration(milliseconds: _showHeader ? 240 : 420),
                  opacity: _showHeader ? 1 : 0,
                  child: const AudioControllerUi(),
                ),
              ),
            ),
          ],
      ),
    );
  }
}

class MushafView extends StatefulWidget {
  final bool useDefaultAppBar;
  final int? initialPageNumber;
  final PageController? controller;
  final double? spOverride;
  final double? hOverride;
  final VoidCallback? onToggleHeader;
  const MushafView({
    super.key,
    this.useDefaultAppBar = true,
    this.initialPageNumber,
    this.controller,
    this.spOverride,
    this.hOverride,
    this.onToggleHeader,
  });

  @override
  State<MushafView> createState() => _MushafViewState();
}

class _MushafViewState extends State<MushafView> {
  /// Word Info Repository instance for Qiraat/Sarf/Irab

  Timer? _menuTimer;
  bool _isSheetOpen = false;

  StreamSubscription? _ayahKeySub;
  PageController? _internalPageController;

  /// Tracks whether the user is manually dragging the page.
  /// While dragging, auto-scroll from audio playback is suppressed to avoid conflicts.
  bool _isUserDragging = false;
  Timer? _dragCooldownTimer;

  PageController get _pageController =>
      widget.controller ?? _internalPageController!;

  bool get _ownsController => widget.controller == null;

  void _animateToPage(int pageNumber) {
    if (!_pageController.hasClients) return;
    // Don't auto-scroll while user is manually dragging
    if (_isUserDragging) return;
    final targetIndex = (pageNumber - 1).clamp(0, 603);
    final currentIndex = (_pageController.page ?? targetIndex.toDouble())
        .round();
    if (currentIndex == targetIndex) return;
    _pageController.animateToPage(
      targetIndex,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
    );
  }

  bool _hasAnyWahyMarker({
    required String ayahKey,
    required Set<String> starred,
    required Set<String> notes,
    required Set<String> bookmarks,
  }) {
    return starred.contains(ayahKey) ||
        notes.contains(ayahKey) ||
        bookmarks.contains(ayahKey);
  }

  Future<void> _setBookmarkColorForAyahKey(
    String ayahKey,
    String colorId,
  ) async {
    await WahyLibraryStore.upsertBookmarkColor(ayahKey, colorId);
  }

  Future<void> _pickBookmarkColorForAyahKey(String ayahKey) async {
    final themeState = context.read<ThemeCubit>().state;
    const card = Color(0xFFF5EBE0);
    final colors = <String, ({String name, Color color})>{
      "red": (name: "الأحمر", color: const Color(0xFFB3261E)),
      "yellow": (name: "الأصفر", color: const Color(0xFFB68A00)),
      "green": (name: "الأخضر", color: themeState.primary),
      "blue": (name: "الأزرق", color: const Color(0xFF2962FF)),
    };

    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (sheet) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.black.withValues(alpha: 0.06),
                        ),
                      ),
                      child: Column(
                        children: colors.entries.map((entry) {
                          return ListTile(
                            onTap: () async {
                              Navigator.pop(sheet);
                              await _setBookmarkColorForAyahKey(
                                ayahKey,
                                entry.key,
                              );
                            },
                            title: Text(
                              entry.value.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            trailing: Icon(
                              Icons.bookmark_rounded,
                              color: entry.value.color,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _arabicOrdinalLocal(BuildContext context, int n) {
    const ord = [
      "الأول",
      "الثاني",
      "الثالث",
      "الرابع",
      "الخامس",
      "السادس",
      "السابع",
      "الثامن",
      "التاسع",
      "العاشر",
      "الحادي عشر",
      "الثاني عشر",
      "الثالث عشر",
      "الرابع عشر",
      "الخامس عشر",
      "السادس عشر",
      "السابع عشر",
      "الثامن عشر",
      "التاسع عشر",
      "العشرون",
      "الحادي والعشرون",
      "الثاني والعشرون",
      "الثالث والعشرون",
      "الرابع والعشرون",
      "الخامس والعشرون",
      "السادس والعشرون",
      "السابع والعشرون",
      "الثامن والعشرون",
      "التاسع والعشرون",
      "الثلاثون",
    ];
    if (n >= 1 && n <= ord.length) return ord[n - 1];
    return localizedNumber(context, n);
  }

  int _quarterNumberFor(int surahNumber, int startVerse) {
    var last = 1;
    for (var i = 0; i < quarters.length; i++) {
      final q = quarters[i];
      final s = (q["surah"] as int?) ?? 1;
      final a = (q["ayah"] as int?) ?? 1;

      if (s < surahNumber || (s == surahNumber && a <= startVerse)) {
        last = i + 1;
      } else {
        break;
      }
    }
    return last.clamp(1, quarters.length);
  }

  int _hizbNumberFor(int surahNumber, int startVerse) {
    final quarter = _quarterNumberFor(surahNumber, startVerse);
    return ((quarter - 1) ~/ 4) + 1;
  }

  bool _isHizbStart(int surahNumber, int startVerse) {
    final q = _quarterNumberFor(surahNumber, startVerse);
    final hizb = ((q - 1) ~/ 4) + 1;
    final hizbStartQuarterIndex = ((hizb - 1) * 4).clamp(
      0,
      quarters.length - 1,
    );
    final entry = quarters[hizbStartQuarterIndex];
    final s = (entry["surah"] as int?) ?? -1;
    final a = (entry["ayah"] as int?) ?? -1;
    return s == surahNumber && a == startVerse;
  }

  @override
  void initState() {
    super.initState();

    if (_ownsController) {
      _internalPageController = PageController(
        initialPage: ((widget.initialPageNumber ?? 1) - 1).clamp(0, 603),
      );
    }

    _ayahKeySub = context.read<AyahKeyCubit>().stream.listen((event) {
      if (!mounted) return;
      final isPlaying = context.read<PlayerStateCubit>().state.isPlaying;
      final inside = context.read<AudioUiCubit>().state.isInsideQuranPlayer;
      if (!isPlaying || !inside) return;

      final parts = event.current.split(":");
      if (parts.length != 2) return;
      final surah = int.tryParse(parts[0]);
      final verse = int.tryParse(parts[1]);
      if (surah == null || verse == null) return;
      final page = qcf.getPageNumber(surah, verse);
      _animateToPage(page);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        // Don't override AyahKeyCubit if audio is playing —
        // the tracker already manages the current ayah key during playback
        final isPlaying = context.read<PlayerStateCubit>().state.isPlaying;
        if (isPlaying) return;
        final page = (widget.initialPageNumber ?? 1).clamp(1, 604);
        final info =
            quranPagesInfo[(page - 1).clamp(0, quranPagesInfo.length - 1)];
        final ayahId = info["s"] ?? 1;
        final key = convertAyahNumberToKey(ayahId);
        if (key != null) {
          context.read<AyahKeyCubit>().changeCurrentAyahKey(key);
        }
      } catch (_) {}
    });
  }

  String _getAyahText(BuildContext context, int surah, int verse) {
    const QuranScriptType scriptType = QuranScriptType.tajweed;
    final words = QuranScriptFunction.getWordListOfAyah(
      scriptType,
      surah.toString(),
      verse.toString(),
    );
    if (words.isEmpty) return "$surah:$verse";

    final raw = words.join(" ");
    final stripped = raw.replaceAll(RegExp(r"<[^>]+>"), "");
    return stripped.replaceAll(RegExp(r"\s+"), " ").trim();
  }

  Future<void> _openUnifiedShareBottomSheet({
    required BuildContext context,
    required int surahNumber,
    required int verseNumber,
  }) {
    final overlayContext = navigatorKey.currentState?.overlay?.context;
    final shareContext = overlayContext ?? context;
    return UnifiedShareBottomSheet.show(
      context: shareContext,
      surahNumber: surahNumber,
      verseNumber: verseNumber,
      getAyahText: (surah, verse) => _getAyahText(shareContext, surah, verse),
    );
  }

  void _cancelMenuTimer() {
    _menuTimer?.cancel();
    _menuTimer = null;
  }

  void _showOptionsSheetForAyah({
    required BuildContext context,
    required int surah,
    required int verse,
  }) {
    if (_isSheetOpen) return;

    final String ayahKey = "$surah:$verse";

    final String ayahText = _getAyahText(context, surah, verse);

    final overlayContext = navigatorKey.currentState?.overlay?.context;
    final sheetContext = overlayContext ?? context;

    setState(() {
      _isSheetOpen = true;
    });

    AyahOptionsSheet.show(
      context: sheetContext,
      ayahKey: ayahKey,
      ayahText: ayahText,
      onShareAsImage: () async {
        await _openUnifiedShareBottomSheet(
          context: context,
          surahNumber: surah,
          verseNumber: verse,
        );
      },
      onWordsPronunciation: () {
        _showWordsPronunciationSheet(
          context: context,
          surah: surah,
          verse: verse,
        );
      },
      onNotes: () async {
        await showAddNotePopup(sheetContext, ayahKey);
      },
      onViewTafsir: () {
        WahyLibrarySheet.show(
          context: context,
          surahNumber: surah,
          verseNumber: verse,
        );
      },
      onBookmark: () {
        _pickBookmarkColorForAyahKey(ayahKey);
      },
      onSetBookmarkColor: (colorId) async {
        await _setBookmarkColorForAyahKey(ayahKey, colorId);
      },
      onRemoveBookmark: () async {
        await WahyLibraryStore.removeBookmark(ayahKey);
      },
      onShareAsText: () {
        _openUnifiedShareBottomSheet(
          context: context,
          surahNumber: surah,
          verseNumber: verse,
        );
      },
      onListen: () {
        final reciter = context.read<SegmentedQuranReciterCubit>().state;
        audioPlaybackService.playSingleAyah(
          ayahKey: ayahKey,
          reciterInfoModel: reciter,
          isInsideQuran: true,
        );
      },
      onListenRange: () async {
        final int total = getVerseCount(surah);
        await showListenRangeSheet(
          context: sheetContext,
          surah: surah,
          verse: verse,
          totalVerses: total,
          toArabicDigits: _toArabicDigits,
        );
      },
    ).whenComplete(() {
      if (!mounted) return;
      setState(() {
        _isSheetOpen = false;
      });
    });
  }

  @override
  void dispose() {
    _cancelMenuTimer();
    _dragCooldownTimer?.cancel();
    _ayahKeySub?.cancel();
    _ayahKeySub = null;
    if (_ownsController) {
      _internalPageController?.dispose();
      _internalPageController = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("[Mushaf] build");
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ThemeState themeState = context.read<ThemeCubit>().state;
    final qSettings = context.watch<QuranSettingsCubit>().state;

    // Graceful Auto-Switch Logic with Preference Memory
    // NOTE: We NEVER override QuranTheme.custom — the user explicitly chose
    // custom colours and we must respect that regardless of OS dark/light mode.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final cubit = context.read<QuranSettingsCubit>();
      final current = cubit.state;

      // Skip auto-switch entirely when user chose a custom theme
      if (current.theme == QuranTheme.custom) return;

      final prefs = await SharedPreferences.getInstance();
      
      if (isDark) {
        if (!current.isDarkTheme) {
          // OS is Dark, but Settings is Light -> Save Light, Restore Dark
          await prefs.setInt('wahy_pref_light_mushaf_theme', current.theme.index);
          final savedDarkIndex = prefs.getInt('wahy_pref_dark_mushaf_theme');
          final targetTheme = savedDarkIndex != null 
              ? QuranTheme.values[savedDarkIndex] 
              : QuranTheme.oled;
          
          if (current.theme != targetTheme) cubit.updateTheme(targetTheme);
        } else {
          // Update saved dark preference
          await prefs.setInt('wahy_pref_dark_mushaf_theme', current.theme.index);
        }
      } else {
        if (current.isDarkTheme) {
          // OS is Light, but Settings is Dark -> Save Dark, Restore Light
          await prefs.setInt('wahy_pref_dark_mushaf_theme', current.theme.index);
          final savedLightIndex = prefs.getInt('wahy_pref_light_mushaf_theme');
          final targetTheme = savedLightIndex != null 
              ? QuranTheme.values[savedLightIndex] 
              : QuranTheme.ayah;
              
          if (current.theme != targetTheme) cubit.updateTheme(targetTheme);
        } else {
          // Update saved light preference
          await prefs.setInt('wahy_pref_light_mushaf_theme', current.theme.index);
        }
      }
    });

    QcfThemeData baseThemeForScaffold() {
      switch (qSettings.theme) {
        case QuranTheme.oled:
          return QcfThemeData.oled();
        case QuranTheme.charcoal:
          return QcfThemeData.charcoal();
        case QuranTheme.graphite:
          return QcfThemeData.graphite();
        case QuranTheme.midnightPurple:
          return QcfThemeData.midnightPurple();
        case QuranTheme.sepia:
          return QcfThemeData.sepia();
        case QuranTheme.cream:
          return QcfThemeData.cream();
        case QuranTheme.paperWhite:
          return QcfThemeData.paperWhite();
        case QuranTheme.sand:
          return QcfThemeData.sand();
        case QuranTheme.nightBlue:
          return QcfThemeData.nightBlue();
        case QuranTheme.ayah:
          return QcfThemeData.ayah();
        case QuranTheme.beige:
          return QcfThemeData.beige();
        case QuranTheme.darkBeige:
          return QcfThemeData.darkBeige();
        case QuranTheme.creamDark:
          return QcfThemeData.creamDark();
        case QuranTheme.custom:
          return QcfThemeData(
            pageBackgroundColor: qSettings.customBackgroundColor,
            verseTextColor: qSettings.customTextColor,
            verseNumberColor: qSettings.customTextColor.withValues(alpha: 0.7),
            basmalaColor: qSettings.customTextColor,
            headerTextColor: qSettings.customTextColor,
          );
      }
    }

    // Fullscreen mode is enforced by _FullscreenEnforcer in main.dart
    // No need to set SystemUiOverlayStyle here — it would cause status bar to reappear

    final bg = baseThemeForScaffold().pageBackgroundColor;

    Widget withSystemBarBackground(Widget child) {
      final padding = MediaQuery.of(context).padding;
      if (padding.top == 0 && padding.bottom == 0) return child;
      return Stack(
        children: [
          child,
          if (padding.top > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: padding.top,
              child: ColoredBox(color: bg),
            ),
          if (padding.bottom > 0)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: padding.bottom,
              child: ColoredBox(color: bg),
            ),
        ],
      );
    }

    final bookmarksList = WahyLibraryStore.loadBookmarks();
    final bookmarkKeys = bookmarksList
        .map((e) => (e["ayahKey"] as String?) ?? "")
        .where((k) => k.isNotEmpty)
        .toSet();

    final notesKeys = WahyLibraryStore.loadNotes()
        .map((e) => (e["ayahKey"] as String?) ?? "")
        .where((k) => k.isNotEmpty)
        .toSet();

    final starredKeys = WahyLibraryStore.loadStarred().toSet();

    final body = MultiBlocListener(
      listeners: [
        BlocListener<PlayerPositionCubit, AudioPlayerPositionModel>(
          listener: (context, state) {
            if (!context.read<AudioUiCubit>().state.isInsideQuranPlayer) return;
            if (ModalRoute.of(context)?.isCurrent != true) return;
            if (AudioPlayerManager.isWordPlaying) return;

            final ayahKey = context.read<AyahKeyCubit>().state.current;

            final segments =
                SegmentedResourcesManager.getAyahSegments(ayahKey) ?? [];
            if (segments.isEmpty) {
              if (context.read<WordPlayingStateCubit>().state != null) {
                context.read<WordPlayingStateCubit>().changeState(null);
              }
              return;
            }

            final currentMs = state.currentDuration?.inMilliseconds ?? 0;
            int? activeWordIndex;
            for (final seg in segments) {
              // segment format: [wordIndex, startMs, endMs]
              if (currentMs >= seg[1] && currentMs <= seg[2]) {
                activeWordIndex = seg[0] as int;
                break;
              }
            }

            if (activeWordIndex != null) {
              final wordKey = "$ayahKey:$activeWordIndex";
              if (context.read<WordPlayingStateCubit>().state != wordKey) {
                context.read<WordPlayingStateCubit>().changeState(wordKey);
              }
            } else {
              if (context.read<WordPlayingStateCubit>().state != null) {
                context.read<WordPlayingStateCubit>().changeState(null);
              }
            }
          },
        ),
      ],
      child: BlocBuilder<QuranSettingsCubit, QuranSettingsState>(
        builder: (context, qSettings) {
          // Map unified QuranTheme enum → QcfThemeData factory
          QcfThemeData buildBaseTheme() {
            switch (qSettings.theme) {
              case QuranTheme.oled:
                return QcfThemeData.oled();
              case QuranTheme.charcoal:
                return QcfThemeData.charcoal();
              case QuranTheme.graphite:
                return QcfThemeData.graphite();
              case QuranTheme.midnightPurple:
                return QcfThemeData.midnightPurple();
              case QuranTheme.sepia:
                return QcfThemeData.sepia();
              case QuranTheme.cream:
                return QcfThemeData.cream();
              case QuranTheme.paperWhite:
                return QcfThemeData.paperWhite();
              case QuranTheme.sand:
                return QcfThemeData.sand();
              case QuranTheme.nightBlue:
                return QcfThemeData.nightBlue();
              case QuranTheme.ayah:
                return QcfThemeData.ayah();
              case QuranTheme.beige:
                return QcfThemeData.beige();
              case QuranTheme.darkBeige:
                return QcfThemeData.darkBeige();
              case QuranTheme.creamDark:
                return QcfThemeData.creamDark();
              case QuranTheme.custom:
                return QcfThemeData(
                  pageBackgroundColor: qSettings.customBackgroundColor,
                  verseTextColor: qSettings.customTextColor,
                  verseNumberColor: qSettings.customTextColor.withValues(alpha: 0.7),
                  basmalaColor: qSettings.customTextColor,
                  headerTextColor: qSettings.customTextColor,
                );
            }
          }

          return BlocBuilder<AudioAyahHighlightCubit, AudioAyahHighlightState>(
            buildWhen: (p, c) => p.activeAyahKey != c.activeAyahKey || p.activeWordKey != c.activeWordKey,
            builder: (context, audioHighlight) {
              return BlocBuilder<AyahToHighlight, String?>(
                buildWhen: (p, c) => p != c,
                builder: (context, manualAyahKey) {
                  // Audio highlight takes priority over manual highlight
                  final highlightedAyahKey = audioHighlight.activeAyahKey ?? manualAyahKey;
                  final audioWordKey = audioHighlight.activeWordKey;
                  return BlocBuilder<WordPlayingStateCubit, String?>(
                    builder: (context, highlightedWordKey) {
                      // Audio word highlight takes priority over word playing state
                      final effectiveWordKey = audioWordKey ?? highlightedWordKey;
                  final baseTheme = buildBaseTheme();
                  final pageBg = baseTheme.pageBackgroundColor;
                  final pageBgBrightness = ThemeData.estimateBrightnessForColor(
                    pageBg,
                  );
                  final bool pageBgIsDark = pageBgBrightness == Brightness.dark;
                  final verseNumberColor = pageBgIsDark
                      ? Colors.white70
                      : const Color(0xFF1B1B1B);
                  final verseNumberHeight = baseTheme.verseNumberHeight;
                  final qcfTheme = baseTheme.copyWith(
                    pageBackgroundColor: baseTheme.pageBackgroundColor,
                    headerBackgroundColor: Colors.transparent,
                    headerTextColor: baseTheme.headerTextColor,
                    verseTextColor: baseTheme.verseTextColor,
                    verseNumberColor: verseNumberColor,
                    verseNumberBuilder: (surah, verse, verseNumber) {
                      if (!qSettings.showVerseNumbers) {
                        return const TextSpan(text: "");
                      }

                      final key = "$surah:$verse";
                      final hasMarker = _hasAnyWahyMarker(
                        ayahKey: key,
                        starred: starredKeys,
                        notes: notesKeys,
                        bookmarks: bookmarkKeys,
                      );

                      final pageNumber = qcf.getPageNumber(surah, verse);
                      final pageFont =
                          "QCF_P${pageNumber.toString().padLeft(3, '0')}";

                      final base = TextSpan(
                        text: verseNumber,
                        style: TextStyle(
                          fontFamily: pageFont,
                          color: verseNumberColor,
                          height:
                              verseNumberHeight / (widget.hOverride ?? 0.86),
                        ),
                      );

                      if (!hasMarker) return base;

                      Color dotColor;
                      if (starredKeys.contains(key)) {
                        dotColor = const Color(0xFFF4B400);
                      } else if (bookmarkKeys.contains(key)) {
                        dotColor = themeState.primary;
                      } else {
                        dotColor = const Color(0xFF2962FF);
                      }

                      return TextSpan(
                        children: [
                          base,
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Padding(
                              padding: const EdgeInsets.only(right: 2),
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: dotColor,
                                  borderRadius: BorderRadius.circular(99),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final double ar = constraints.maxWidth / constraints.maxHeight;
                      double dynamicScale = 1.0;
                      if (ar > 0.5) {
                        dynamicScale = 0.5 / ar;
                      }

                      // ── Shared callbacks for all layout modes ──
                      List<HighlightRange> highlightsBuilder(int surah, int verse) {
                        final key = "$surah:$verse";
                        if (key == highlightedAyahKey) {
                          if (effectiveWordKey != null &&
                              effectiveWordKey.startsWith(key)) {
                            try {
                              final wordIndex = int.parse(
                                effectiveWordKey.split(":").last,
                              );
                              return [
                                HighlightRange(
                                  wordIndex: wordIndex,
                                  color: qSettings.highlightColor.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                              ];
                            } catch (_) {}
                          }
                        }
                        return [];
                      }

                      Color? verseBgColor(int surah, int verse) {
                        final key = "$surah:$verse";
                        // Hifz mode: hide ayahs with overlay
                        try {
                          final hifz = context.read<HifzCubit>().state;
                          if (hifz.isActive && !hifz.revealedAyahs.contains(key)) {
                            if (hifz.hideLevel == HifzHideLevel.hidden) {
                              return pageBgIsDark
                                  ? const Color(0xFF141414)
                                  : const Color(0xFFEDE4D4);
                            }
                            if (hifz.hideLevel == HifzHideLevel.blurred) {
                              return pageBgIsDark
                                  ? const Color(0xFF141414).withValues(alpha: 0.85)
                                  : const Color(0xFFEDE4D4).withValues(alpha: 0.85);
                            }
                          }
                        } catch (_) {}
                        if (highlightedAyahKey != key) return null;
                        return qSettings.highlightColor.withValues(
                          alpha: pageBgIsDark ? 0.26 : 0.22,
                        );
                      }

                      void handleTapDown(int surah, int verse, TapDownDetails details) {
                        final key = "$surah:$verse";
                        try {
                          final hifz = context.read<HifzCubit>();
                          if (hifz.state.isActive && hifz.state.isTestMode) {
                            if (hifz.state.revealedAyahs.contains(key)) {
                              hifz.hideAyah(key);
                            } else {
                              hifz.revealAyah(key);
                            }
                          }
                        } catch (_) {}
                        // Don't change AyahKeyCubit while audio is playing —
                        // the tracker listens to it and would shift highlight
                        // to the tapped ayah instead of the playing one.
                        final isAudioPlaying = context.read<AudioAyahHighlightCubit>().state.activeAyahKey != null;
                        if (!isAudioPlaying) {
                          context.read<AyahKeyCubit>().changeCurrentAyahKey(key);
                          context.read<AyahToHighlight>().changeAyah(key);
                        }
                      }

                      void handleTap(int surah, int verse) {
                        final isAudioPlaying = context.read<AudioAyahHighlightCubit>().state.activeAyahKey != null;
                        if (!isAudioPlaying) {
                          context.read<AyahToHighlight>().changeAyah(null);
                          widget.onToggleHeader?.call();
                        }
                      }

                      void handleLongPressDown(int surah, int verse, LongPressStartDetails details) {
                        _cancelMenuTimer();
                        final ayahKey = "$surah:$verse";
                        // Don't change AyahKeyCubit while audio is playing —
                        // the tracker listens to it and would shift highlight.
                        final isAudioPlaying = context.read<AudioAyahHighlightCubit>().state.activeAyahKey != null;
                        if (!isAudioPlaying) {
                          context.read<AyahKeyCubit>().changeCurrentAyahKey(ayahKey);
                          context.read<AyahToHighlight>().changeAyah(ayahKey);
                        }
                      }

                      void handleLongPress(int surah, int verse) {
                        _cancelMenuTimer();
                        HapticFeedback.selectionClick();
                        _showOptionsSheetForAyah(
                          context: context,
                          surah: surah,
                          verse: verse,
                        );
                      }

                      void handleLongPressUp(int surah, int verse) {
                        _cancelMenuTimer();
                        final isAudioPlaying = context.read<AudioAyahHighlightCubit>().state.activeAyahKey != null;
                        if (!isAudioPlaying) {
                          context.read<AyahToHighlight>().changeAyah(null);
                        }
                      }

                      void handleLongPressCancel(int surah, int verse) {
                        _cancelMenuTimer();
                        final isAudioPlaying = context.read<AudioAyahHighlightCubit>().state.activeAyahKey != null;
                        if (!isAudioPlaying) {
                          context.read<AyahToHighlight>().changeAyah(null);
                        }
                      }

                      void handleDoubleTap(int surah, int verse) async {
                        final ayahKey = "$surah:$verse";
                        // Don't change AyahKeyCubit while audio is playing —
                        // the tracker listens to it and would shift highlight
                        // to the double-tapped ayah instead of the playing one.
                        final isAudioPlaying = context.read<AudioAyahHighlightCubit>().state.activeAyahKey != null;
                        if (!isAudioPlaying) {
                          context.read<AyahKeyCubit>().changeCurrentAyahKey(ayahKey);
                        }
                        final wordsKey = List.generate(
                          QuranScriptFunction.getWordListOfAyah(
                            context.read<QuranViewCubit>().state.quranScriptType,
                            surah.toString(),
                            verse.toString(),
                          ).length,
                          (i) => "$surah:$verse:${i + 1}",
                        );
                        if (wordsKey.isEmpty) return;
                        showPopupWordFunction(
                          context: context,
                          wordKeys: wordsKey,
                          initWordIndex: 0,
                          wordByWordList: const [],
                        );
                      }

                      void handlePageChanged(int page) {
                        _cancelMenuTimer();
                        context.read<AyahKeyCubit>().changeLastScrolledPage(page);
                        try {
                          context.read<ReadingStatsCubit>().recordPages(1);
                        } catch (_) {}
                        // Don't update current ayah key during audio playback —
                        // the audio tracker owns the current ayah while playing.
                        // Updating it here would steal the highlight from the playing ayah.
                        final isAudioPlaying = context.read<AudioAyahHighlightCubit>().state.activeAyahKey != null;
                        if (isAudioPlaying) return;
                        final info =
                            quranPagesInfo[(page - 1).clamp(0, quranPagesInfo.length - 1)];
                        final ayahId = info["s"] ?? 1;
                        final key = convertAyahNumberToKey(ayahId);
                        if (key != null) {
                          context.read<AyahKeyCubit>().changeCurrentAyahKey(key);
                        }
                      }

                      // ── Page overlay builders ──
                      // Scale overlay text proportionally with mushaf content
                      // so info stays readable and coordinated at any font size.
                      final overlayScale = qSettings.overlayScale;
                      final overlayBaseFontSize = 14.0 * overlayScale;
                      final overlaySmallFontSize = 12.0 * overlayScale;
                      final overlayPadding = (16.0 * overlayScale).clamp(10.0, 24.0);
                      final overlayVPadding = (8.0 * overlayScale).clamp(4.0, 14.0);

                      Widget pageTopOverlay(int pageNumber, int surahNumber, int startVerse) {
                        if (!qSettings.showPageInfo) return const SizedBox.shrink();
                        final juzNumber = getJuzNumber(surahNumber, startVerse);
                        return IgnorePointer(
                          ignoring: true,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: overlayPadding, vertical: overlayVPadding),
                            child: DefaultTextStyle(
                              style: TextStyle(
                                fontSize: overlayBaseFontSize,
                                fontWeight: FontWeight.w900,
                                fontFamily: "Inter",
                                color: pageBgIsDark
                                    ? Colors.white.withValues(alpha: 0.90)
                                    : const Color(0xFF111111).withValues(alpha: 0.88),
                              ),
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(getSurahNameArabic(surahNumber), textDirection: TextDirection.rtl),
                                    Text("الجزء ${_arabicOrdinalLocal(context, juzNumber)}", textDirection: TextDirection.rtl),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      Widget pageBottomOverlay(int pageNumber, int surahNumber, int startVerse) {
                        if (!qSettings.showPageInfo) return const SizedBox.shrink();
                        final pageLabel = localizedNumber(context, pageNumber);
                        final hizbNumber = _hizbNumberFor(surahNumber, startVerse);
                        final hizbLabel = "الحزب ${localizedNumber(context, hizbNumber)}";
                        final showHizb = _isHizbStart(surahNumber, startVerse);
                        // ── Rub (quarter) info ──
                        final quarterNum = _quarterNumberFor(surahNumber, startVerse);
                        final rubInHizb = ((quarterNum - 1) % 4) + 1;
                        final rubLabels = ["", "الربع", "النصف", "الثلث"];
                        final rubLabel = rubInHizb >= 1 && rubInHizb <= 3
                            ? "${rubLabels[rubInHizb]} ${localizedNumber(context, hizbNumber)}"
                            : null;
                        return IgnorePointer(
                          ignoring: true,
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (showHizb) ...[
                                  Text(hizbLabel, style: TextStyle(
                                    fontSize: overlaySmallFontSize, fontWeight: FontWeight.w700,
                                    color: pageBgIsDark
                                        ? Colors.white.withValues(alpha: 0.82)
                                        : const Color(0xFF111111).withValues(alpha: 0.78),
                                  )),
                                  SizedBox(height: (2 * overlayScale).clamp(1.0, 4.0)),
                                ],
                                if (rubLabel != null && rubInHizb > 1) ...[
                                  Text(rubLabel, style: TextStyle(
                                    fontSize: overlaySmallFontSize * 0.9, fontWeight: FontWeight.w600,
                                    color: pageBgIsDark
                                        ? Colors.white.withValues(alpha: 0.65)
                                        : const Color(0xFF111111).withValues(alpha: 0.60),
                                  )),
                                  SizedBox(height: (1 * overlayScale).clamp(0.5, 3.0)),
                                ],
                                Text(pageLabel, style: TextStyle(
                                  fontSize: overlayBaseFontSize, fontWeight: FontWeight.w800,
                                  color: pageBgIsDark
                                      ? Colors.white.withValues(alpha: 0.90)
                                      : const Color(0xFF111111).withValues(alpha: 0.88),
                                )),
                              ],
                            ),
                          ),
                        );
                      }

                      // ── Shared QcfThemeData for all modes ──
                      final effectiveQcfTheme = qcfTheme.copyWith(
                        showBasmala: qSettings.showBasmala,
                        showHeader: qSettings.showSurahHeader,
                        useClassicBorder: false,
                        contentScale: qSettings.contentScale,
                        verseHeight: baseTheme.verseHeight * qSettings.verseHeightScale,
                        verseBackgroundColor: (surah, verse) {
                          final key = "$surah:$verse";
                          if (key == highlightedAyahKey) {
                            return qSettings.highlightColor.withValues(
                              alpha: pageBgIsDark ? 0.26 : 0.22,
                            );
                          }
                          return null;
                        },
                        headerScale: 1.08,
                        headerWidthSmall: 410,
                        headerWidthLarge: 290,
                        firstPagesTopSpacerFactor: 0.0,
                        pageTopOverlayBuilder: pageTopOverlay,
                        pageBottomOverlayBuilder: pageBottomOverlay,
                      );

                      // ── Layout mode switch ──
                      Widget mushafBody;

                      switch (qSettings.layoutMode) {
                        // ──────── SINGLE PAGE (default) ────────
                        case MushafLayoutMode.singlePage:
                          mushafBody = PageviewQuran(
                            controller: _pageController,
                            initialPageNumber: (widget.initialPageNumber ?? 1).clamp(1, 604),
                            sp: (widget.spOverride ?? 0.86) * dynamicScale,
                            h: (widget.hOverride ?? 0.86) * dynamicScale,
                            fontSize: qSettings.fontSize * dynamicScale,
                            physics: const ClampingScrollPhysics(),
                            showTajweed: false,
                            tajweedWordsBuilder: (surah, verse) {
                              return QuranScriptFunction.getWordListOfAyah(
                                QuranScriptType.tajweed,
                                surah.toString(),
                                verse.toString(),
                              );
                            },
                            highlightsBuilder: highlightsBuilder,
                            theme: effectiveQcfTheme,
                            verseBackgroundColor: verseBgColor,
                            onTapDown: handleTapDown,
                            onTap: handleTap,
                            onLongPressDown: handleLongPressDown,
                            onLongPress: handleLongPress,
                            onLongPressUp: handleLongPressUp,
                            onLongPressCancel: handleLongPressCancel,
                            onDoubleTap: handleDoubleTap,
                            onPageChanged: handlePageChanged,
                          );

                        // ──────── DOUBLE PAGE (side-by-side) ────────
                        case MushafLayoutMode.doublePage:
                          mushafBody = DoublePageMushaf(
                            controller: _pageController,
                            initialPageNumber: (widget.initialPageNumber ?? 1).clamp(1, 604),
                            sp: (widget.spOverride ?? 0.86) * dynamicScale,
                            h: (widget.hOverride ?? 0.86) * dynamicScale,
                            fontSize: qSettings.fontSize * dynamicScale,
                            theme: effectiveQcfTheme,
                            verseBackgroundColor: verseBgColor,
                            highlightsBuilder: highlightsBuilder,
                            onTapDown: handleTapDown,
                            onTap: handleTap,
                            onLongPressDown: handleLongPressDown,
                            onLongPress: handleLongPress,
                            onLongPressUp: handleLongPressUp,
                            onLongPressCancel: handleLongPressCancel,
                            onDoubleTap: handleDoubleTap,
                            onPageChanged: handlePageChanged,
                            pageBgIsDark: pageBgIsDark,
                          );

                        // ──────── CONTINUOUS SCROLL (vertical) ────────
                        case MushafLayoutMode.continuousScroll:
                          mushafBody = ContinuousScrollMushaf(
                            controller: _pageController,
                            initialPageNumber: (widget.initialPageNumber ?? 1).clamp(1, 604),
                            sp: (widget.spOverride ?? 0.86) * dynamicScale,
                            h: (widget.hOverride ?? 0.86) * dynamicScale,
                            fontSize: qSettings.fontSize * dynamicScale,
                            theme: effectiveQcfTheme,
                            verseBackgroundColor: verseBgColor,
                            highlightsBuilder: highlightsBuilder,
                            onTapDown: handleTapDown,
                            onTap: handleTap,
                            onLongPressDown: handleLongPressDown,
                            onLongPress: handleLongPress,
                            onLongPressUp: handleLongPressUp,
                            onLongPressCancel: handleLongPressCancel,
                            onDoubleTap: handleDoubleTap,
                            onPageChanged: handlePageChanged,
                            pageBgIsDark: pageBgIsDark,
                          );
                      }

                      return MediaQuery(
                        data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1)),
                        child: Container(
                          color: baseTheme.pageBackgroundColor,
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              if (notification is ScrollStartNotification && notification.dragDetails != null) {
                                // User started dragging manually — suppress auto-scroll
                                _isUserDragging = true;
                                _dragCooldownTimer?.cancel();
                              } else if (notification is ScrollEndNotification) {
                                // User stopped dragging — allow auto-scroll after a short cooldown
                                _dragCooldownTimer?.cancel();
                                _dragCooldownTimer = Timer(const Duration(seconds: 2), () {
                                  _isUserDragging = false;
                                });
                              }
                              return false;
                            },
                            child: mushafBody,
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    },
  ),
);

    final decoratedBody = withSystemBarBackground(body);

    if (!widget.useDefaultAppBar) return decoratedBody;

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        title: Text(
          "المصحف",
          style: TextStyle(
            color: themeState.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: decoratedBody,
    );
  }
}
