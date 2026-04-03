import "dart:async";
import "dart:convert";
import "package:al_quran_v3/src/screen/mushaf/widgets/bookmarks_sheet.dart";
import "package:al_quran_v3/src/screen/mushaf/widgets/starred_sheet.dart";
import "package:al_quran_v3/src/screen/mushaf/widgets/notes_sheet.dart";
import 'package:al_quran_v3/src/screen/mushaf/widgets/wahy_feedback_dialog.dart';
import "package:al_quran_v3/src/screen/mushaf/widgets/wahy_mushaf_top_header.dart";
import 'package:al_quran_v3/src/screen/mushaf/widgets/wahy_index_sheet.dart';
import "package:al_quran_v3/src/screen/mushaf/wahy_library_store.dart";
import 'widgets/library_sheet.dart';
import "package:al_quran_v3/src/screen/mushaf/widgets/listen_range_sheet.dart";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:qcf_quran/qcf_quran.dart" hide getPageNumber;
import "package:share_plus/share_plus.dart";

import "package:al_quran_v3/src/core/audio/cubit/player_position_cubit.dart";
import "package:al_quran_v3/src/core/audio/model/audio_player_position_model.dart";
import "package:al_quran_v3/src/utils/quran_resources/segmented_resources_manager.dart";

import "package:al_quran_v3/l10n/app_localizations.dart";
import "package:al_quran_v3/main.dart";
import "package:al_quran_v3/src/core/audio/cubit/audio_ui_cubit.dart";
import "package:al_quran_v3/src/core/audio/cubit/ayah_key_cubit.dart";
import "package:al_quran_v3/src/core/audio/cubit/player_state_cubit.dart";
import "package:al_quran_v3/src/core/audio/cubit/segmented_quran_reciter_cubit.dart";
import "package:al_quran_v3/src/core/audio/model/ayahkey_management.dart";
import "package:al_quran_v3/src/core/audio/services/audio_playback_service_access.dart";
import "package:al_quran_v3/src/core/notifications/khatma_notification_service.dart";
import "package:al_quran_v3/src/screen/quran_reader/widgets/ayah_options_sheet.dart";
import "package:al_quran_v3/src/screen/quran_resources/quran_resources_view.dart";
import "package:al_quran_v3/src/widget/audio/audio_controller_ui.dart";
import "package:al_quran_v3/src/screen/quran_script_view/cubit/ayah_to_highlight.dart";
import "package:al_quran_v3/src/screen/quran_script_view/quran_script_view.dart";
import "package:al_quran_v3/src/screen/search/search_screen.dart";
import "package:al_quran_v3/src/screen/settings/cubit/quran_script_view_cubit.dart";
import "package:al_quran_v3/src/resources/quran_resources/models/tafsir_book_model.dart";
import "package:al_quran_v3/src/utils/quran_resources/quran_script_function.dart";
import "package:al_quran_v3/src/utils/quran_resources/quran_tafsir_function.dart";
import "package:al_quran_v3/src/utils/quran_resources/word_by_word_function.dart";
import "package:al_quran_v3/src/utils/quran_word/show_popup_word_function.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:al_quran_v3/src/utils/number_localization.dart";
import "package:al_quran_v3/src/widget/quran_script/model/script_info.dart";
import "package:al_quran_v3/src/widget/quran_script_words/cubit/word_playing_state_cubit.dart";
import "package:al_quran_v3/src/screen/settings/settings_page.dart";
import "package:al_quran_v3/src/core/unified_quran_settings/quran_settings_bottom_sheet.dart";
import "package:al_quran_v3/src/core/unified_quran_settings/cubit/quran_settings_cubit.dart";
import "package:al_quran_v3/src/screen/prayer_time/prayer_time_page.dart";
import "package:al_quran_v3/src/screen/qibla/qibla_direction.dart";
import "package:al_quran_v3/src/screen/mushaf/index/aya_index_page.dart";
// Removed audio_page.dart import
import "package:al_quran_v3/src/widget/add_collection_popup/add_note_popup.dart";
import "package:al_quran_v3/src/screen/about/about_the_app.dart";
import "package:al_quran_v3/src/screen/mushaf/widgets/image_share/ayah_image_generator.dart";
import "package:al_quran_v3/src/screen/mushaf/widgets/khatma_sheet.dart";
import "package:al_quran_v3/src/screen/azkar/azkar_categories_screen.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:al_quran_v3/src/theme/controller/theme_cubit.dart";
import "package:al_quran_v3/src/theme/controller/theme_state.dart";
import "package:qcf_quran/qcf_quran.dart" as qcf;
import "package:al_quran_v3/src/resources/quran_resources/tafsir_info_with_score.dart";
import "package:al_quran_v3/src/utils/quran_ayahs_function/get_page_number.dart";
import "package:al_quran_v3/src/resources/quran_resources/quran_pages_info.dart";
import "package:al_quran_v3/src/utils/basic_functions.dart";
import "package:al_quran_v3/src/theme/app_colors.dart";
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
      : Color(0xFFF7F1E6);
  static Color _onBg(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
      ? Colors.white
      : Color(0xFF1B1B1B);
  static const _headerHeight = 56.0;

  String _ayahPreviewForKey(String ayahKey) {
    final parts = ayahKey.split(":");
    final surah = parts.isNotEmpty ? int.tryParse(parts[0]) : null;
    final verse = parts.length == 2 ? int.tryParse(parts[1]) : null;
    if (surah == null || verse == null) return ayahKey;

    final QuranScriptType scriptType = context
        .read<QuranViewCubit>()
        .state
        .quranScriptType;
    final words = QuranScriptFunction.getWordListOfAyah(
      scriptType,
      surah.toString(),
      verse.toString(),
    );
    if (words.isEmpty) return ayahKey;
    final raw = words.join(" ");
    final stripped = raw.replaceAll(RegExp(r"<[^>]+>"), "");
    return stripped.replaceAll(RegExp(r"\s+"), " ").trim();
  }

  ({int surah, int verse})? _parseKey(String ayahKey) {
    final parts = ayahKey.split(":");
    if (parts.length != 2) return null;
    final s = int.tryParse(parts[0]);
    final v = int.tryParse(parts[1]);
    if (s == null || v == null) return null;
    return (surah: s, verse: v);
  }

  Future<void> _removeBookmark(String ayahKey) async {
    await WahyLibraryStore.removeBookmark(ayahKey);
  }

  Future<void> _pickBookmarkColorForAyahKey(String ayahKey) async {
    final themeState = context.read<ThemeCubit>().state;
    const card = Color(0xFFFFF9F2);
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
              color: _bg(sheet),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
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

  Future<void> _removeNoteAt(int index) async {
    await WahyLibraryStore.removeNoteAt(index);
  }

  Future<void> _addNoteForCurrentAyah() async {
    final key = context.read<AyahKeyCubit>().state.current;
    if (key.isEmpty) return;
    await _addNoteForAyahKey(key);
  }

  Future<void> _addNoteForAyahKey(String ayahKey) async {
    final controller = TextEditingController();
    final themeState = context.read<ThemeCubit>().state;

    final result = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: _bg(ctx),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "ملاحظة جديدة",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: themeState.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: controller,
                        minLines: 3,
                        maxLines: 7,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: "اكتب ملاحظتك هنا…",
                          hintStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade500
                                : Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : const Color(0xFFFFF9F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.08),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx, controller.text.trim());
                          },
                          child: const Text("حفظ"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    final text = (result ?? "").trim();
    if (text.isEmpty) return;
    await WahyLibraryStore.addNote(ayahKey, text);
  }

  Future<void> _ensureQuranScriptReady() async {
    if (_quranScriptReady) return;
    _quranScriptInitFuture ??= () async {
      await QuranScriptFunction.initQuranScript(QuranScriptType.uthmani);
      _quranScriptReady = true;
    }();
    await _quranScriptInitFuture;
  }

  List<Map<String, dynamic>> _getWahyBookmarks() {
    return WahyLibraryStore.loadBookmarks();
  }

  List<String> _getWahyStarred() {
    return WahyLibraryStore.loadStarred();
  }

  List<Map<String, dynamic>> _getWahyNotes() {
    return WahyLibraryStore.loadNotes();
  }

  Future<void> _setBookmarkColorForCurrentAyah(String colorId) async {
    final key = context.read<AyahKeyCubit>().state.current;
    if (key.isEmpty) return;
    await _setBookmarkColorForAyahKey(key, colorId);
  }

  Future<void> _setBookmarkColorForAyahKey(
    String ayahKey,
    String colorId,
  ) async {
    await WahyLibraryStore.upsertBookmarkColor(ayahKey, colorId);
  }

  Future<void> _toggleStarForCurrentAyah() async {
    final key = context.read<AyahKeyCubit>().state.current;
    if (key.isEmpty) return;
    await WahyLibraryStore.toggleStar(key);
  }

  Future<void> _openBookmarksSheet() async {
    await showBookmarksSheet(
      context: context,
      bg: _bg(context),
      onBg: _onBg(context),
      loadBookmarks: _getWahyBookmarks,
      setBookmarkColorForCurrentAyah: _setBookmarkColorForCurrentAyah,
      parseKey: _parseKey,
      removeBookmark: _removeBookmark,
      ayahPreviewForKey: _ayahPreviewForKey,
    );
  }

  Future<void> _openStarredSheet() async {
    await showStarredSheet(
      context: context,
      bg: _bg(context),
      onBg: _onBg(context),
      loadStarred: _getWahyStarred,
      parseKey: _parseKey,
      ayahPreviewForKey: _ayahPreviewForKey,
    );
  }

  Future<void> _openNotesSheet() async {
    await showNotesSheet(
      context: context,
      bg: _bg(context),
      onBg: _onBg(context),
      loadNotes: _getWahyNotes,
      removeNoteAt: _removeNoteAt,
      showAddNotePopup: (key) => showAddNotePopup(context, key),
      parseKey: _parseKey,
      ayahPreviewForKey: _ayahPreviewForKey,
      onTapNote: (page, key) {
        context.read<AyahKeyCubit>().changeLastScrolledPage(page);
        context.read<AyahKeyCubit>().changeCurrentAyahKey(key);
        context.read<AyahToHighlight>().changeAyah(key);
        if (_isMushafMode && _mushafPageController.hasClients) {
          _mushafPageController.animateToPage(
            page - 1,
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeOutCubic,
          );
        }
      },
    );
  }

  Future<void> _openIndexSheet() async {
    await showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: _bg(ctx),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                height: MediaQuery.of(ctx).size.height * 0.86,
                child: WahyIndexSheet(
                  onOpenPage: (page) async {
                    if (_isMushafMode) {
                      Navigator.pop(ctx);
                      await Future<void>.delayed(
                        const Duration(milliseconds: 80),
                      );
                      if (!_mushafPageController.hasClients) {
                        context.read<AyahKeyCubit>().changeLastScrolledPage(
                          page,
                        );
                        return;
                      }
                      _mushafPageController.animateToPage(
                        page - 1,
                        duration: const Duration(milliseconds: 520),
                        curve: Curves.easeOutCubic,
                      );
                      context.read<AyahKeyCubit>().changeLastScrolledPage(page);
                      return;
                    }

                    context.read<AyahKeyCubit>().changeLastScrolledPage(page);
                    Navigator.pop(ctx);
                  },
                  onOpenAyah: (key) async {
                    Navigator.pop(ctx);
                    await Future<void>.delayed(
                      const Duration(milliseconds: 80),
                    );

                    final page = getPageNumber(key) ?? 1;
                    context.read<AyahKeyCubit>().changeLastScrolledPage(page);
                    context.read<AyahKeyCubit>().changeCurrentAyahKey(key);
                    context.read<AyahToHighlight>().changeAyah(key);

                    if (_isMushafMode && _mushafPageController.hasClients) {
                      _mushafPageController.animateToPage(
                        page - 1,
                        duration: const Duration(milliseconds: 520),
                        curve: Curves.easeOutCubic,
                      );
                    }
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getAyahText(BuildContext context, int surah, int verse) {
    final QuranScriptType scriptType = context
        .read<QuranViewCubit>()
        .state
        .quranScriptType;
    final words = QuranScriptFunction.getWordListOfAyah(
      scriptType,
      surah.toString(),
      verse.toString(),
    );

    List<String> resolved = List<String>.from(words);
    if (resolved.isEmpty) {
      final fallback = QuranScriptFunction.getWordListOfAyah(
        QuranScriptType.uthmani,
        surah.toString(),
        verse.toString(),
      );
      resolved = List<String>.from(fallback);
    }
    if (resolved.isEmpty) return "";

    final raw = resolved.join(" ");
    final stripped = raw.replaceAll(RegExp(r"<[^>]+>"), "");
    return stripped.replaceAll(RegExp(r"\s+"), " ").trim();
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
          child: Material(
            color: backgroundColor,
            child: AyaIndexPage(
              isEmbedded: true,
              onOpenLocation: (page, ayahKey) {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).popUntil((route) => route.isFirst);
                context.read<AyahKeyCubit>().changeLastScrolledPage(page);
                context.read<AyahKeyCubit>().changeCurrentAyahKey(ayahKey);
                context.read<AyahToHighlight>().changeAyah(ayahKey);
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SearchScreen()),
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
    final bgColor = isDark ? const Color(0xFF000000) : AppColors.ayaBackground;
    final topBarColor = isDark
        ? const Color(0xFF000000).withValues(alpha: 0.85)
        : const Color(0xFFF4EAD5).withValues(alpha: 0.85);
    final topBarBorderColor = isDark
        ? Colors.white10
        : AppColors.ayaBorder.withValues(alpha: 0.5);

    final media = MediaQuery.of(context);
    final screenH = media.size.height;
    final safeH = (screenH - _headerHeight).clamp(1.0, screenH);
    final availableRatio = safeH / screenH;
    final mushafScale = (availableRatio + 0.12).clamp(0.84, 0.92);

    return Scaffold(
      backgroundColor: bgColor,
      extendBodyBehindAppBar: true,
      body: MultiBlocListener(
        listeners: [
          BlocListener<PlayerStateCubit, PlayerState>(
            listenWhen: (p, c) => p.isPlaying != c.isPlaying,
            listener: (context, state) {
              final highlighter = context.read<AyahToHighlight>();
              if (!state.isPlaying) {
                highlighter.changeAyah(null);
                return;
              }
              highlighter.changeAyah(
                context.read<AyahKeyCubit>().state.current,
              );
            },
          ),
          BlocListener<AyahKeyCubit, AyahKeyManagement>(
            listenWhen: (p, c) => p.current != c.current,
            listener: (context, ayahState) {
              if (!context.read<PlayerStateCubit>().state.isPlaying) return;
              context.read<AyahToHighlight>().changeAyah(ayahState.current);
            },
          ),
        ],
        child: Stack(
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
                                .watch<AyahKeyCubit>()
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
            // Top header (Beige)
            WahyMushafTopHeader(
              showHeader: _showHeader,
              headerHeight: _headerHeight,
              topInset: MediaQuery.of(context).padding.top,
              topBarColor: topBarColor,
              topBarBorderColor: topBarBorderColor,
              isMushafMode: _isMushafMode,
              iconPrimaryColor: AppColors.ayaPrimary,
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
  static Color _bg(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
      ? Color(0xFF000000)
      : Color(0xFFF7F1E6);

  /// Word Info Repository instance for Qiraat/Sarf/Irab

  Timer? _menuTimer;
  bool _isSheetOpen = false;

  StreamSubscription? _ayahKeySub;
  PageController? _internalPageController;

  PageController get _pageController =>
      widget.controller ?? _internalPageController!;

  bool get _ownsController => widget.controller == null;

  void _animateToPage(int pageNumber) {
    if (!_pageController.hasClients) return;
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

  Future<void> _addNoteForAyahKey(String ayahKey) async {
    final controller = TextEditingController();
    final themeState = context.read<ThemeCubit>().state;

    final result = await showModalBottomSheet<String>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: _bg(ctx),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
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
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "ملاحظة جديدة",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: themeState.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: controller,
                        minLines: 3,
                        maxLines: 7,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText: "اكتب ملاحظتك هنا…",
                          filled: true,
                          fillColor: const Color(0xFFFFF9F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.black.withValues(alpha: 0.08),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: Colors.black.withValues(alpha: 0.08),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx, controller.text.trim());
                          },
                          child: const Text("حفظ"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    final text = (result ?? "").trim();
    if (text.isEmpty) return;
    await WahyLibraryStore.addNote(ayahKey, text);
  }

  Future<void> _setBookmarkColorForAyahKey(
    String ayahKey,
    String colorId,
  ) async {
    await WahyLibraryStore.upsertBookmarkColor(ayahKey, colorId);
  }

  Future<void> _pickBookmarkColorForAyahKey(String ayahKey) async {
    final themeState = context.read<ThemeCubit>().state;
    const card = Color(0xFFFFF9F2);
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
              color: _bg(sheet),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
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

  String _stripHtml(String input) {
    // Preserve readable line breaks before stripping tags
    final normalized = input
        .replaceAll(RegExp(r"<\s*br\s*\/?>", caseSensitive: false), "\n")
        .replaceAll(RegExp(r"<\s*\/p\s*>", caseSensitive: false), "\n")
        .replaceAll(RegExp(r"<\s*p[^>]*>", caseSensitive: false), "");

    return normalized
        .replaceAll(RegExp(r"<[^>]*>"), "")
        .replaceAll("&nbsp;", " ")
        .replaceAll("&amp;", "&")
        .replaceAll("&quot;", "\"")
        .replaceAll("&#39;", "'")
        .replaceAll("\r", "")
        .trim();
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
        await _openTafsirStyleShareOptions(
          context: context,
          surahNumber: surah,
          verseNumber: verse,
          ayahText: ayahText,
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
        _openTafsirStyleShareOptions(
          context: context,
          surahNumber: surah,
          verseNumber: verse,
          ayahText: ayahText,
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

    final bool isThemeCompatibleWithMode = isDark
        ? (qSettings.theme == QuranTheme.oled ||
              qSettings.theme == QuranTheme.nightBlue ||
              qSettings.theme == QuranTheme.custom ||
              qSettings.theme == QuranTheme.graphite ||
              qSettings.theme == QuranTheme.midnightPurple)
        : (qSettings.theme == QuranTheme.sepia ||
              qSettings.theme == QuranTheme.cream ||
              qSettings.theme == QuranTheme.paperWhite ||
              qSettings.theme == QuranTheme.sand);

    if (qSettings.isInitialized && !isThemeCompatibleWithMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        context.read<QuranSettingsCubit>().updateTheme(
          isDark ? QuranTheme.nightBlue : QuranTheme.cream,
        );
      });
    }

    QcfThemeData baseThemeForScaffold() {
      switch (qSettings.theme) {
        case QuranTheme.oled:
          return QcfThemeData.oled();
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
        case QuranTheme.custom:
          return QcfThemeData.dark();
      }
    }

    final bg = baseThemeForScaffold().pageBackgroundColor;
    final bgBrightness = ThemeData.estimateBrightnessForColor(bg);
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: bg,
        statusBarIconBrightness: bgBrightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: bg,
        systemNavigationBarIconBrightness: bgBrightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarContrastEnforced: false,
        systemStatusBarContrastEnforced: false,
      ),
    );

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
              // Word index from segmented JSON is 1-indexed. QcfPage is 0-indexed.
              final wordKey = "$ayahKey:${activeWordIndex - 1}";
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
              case QuranTheme.custom:
                return QcfThemeData.dark();
            }
          }

          final bool qDark =
              qSettings.theme == QuranTheme.oled ||
              qSettings.theme == QuranTheme.nightBlue ||
              qSettings.theme == QuranTheme.custom;

          return BlocBuilder<AyahToHighlight, String?>(
            buildWhen: (p, c) => p != c,
            builder: (context, highlightedAyahKey) {
              return BlocBuilder<WordPlayingStateCubit, String?>(
                builder: (context, highlightedWordKey) {
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
                    headerTextColor: Colors.black,
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

                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: const TextScaler.linear(1)),
                    child: Container(
                      color: baseTheme.pageBackgroundColor,
                      child: PageviewQuran(
                        controller: _pageController,
                        initialPageNumber: (widget.initialPageNumber ?? 1)
                            .clamp(1, 604),
                        sp: widget.spOverride ?? 0.86,
                        h: widget.hOverride ?? 0.86,
                        fontSize: qSettings.fontSize,
                        physics: const ClampingScrollPhysics(),
                        showTajweed: qSettings.tajweedEnabled,
                        tajweedWordsBuilder: (surah, verse) {
                          return QuranScriptFunction.getWordListOfAyah(
                            QuranScriptType.tajweed,
                            surah.toString(),
                            verse.toString(),
                          );
                        },
                        highlightsBuilder: (surah, verse) {
                          final key = "$surah:$verse";

                          // Support Ayah-level Highlighting
                          if (key == highlightedAyahKey) {
                            // Support Word-level Highlighting
                            if (highlightedWordKey != null &&
                                highlightedWordKey.startsWith(key)) {
                              try {
                                final wordIndex = int.parse(
                                  highlightedWordKey.split(":").last,
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
                        },
                        theme: qcfTheme.copyWith(
                          showBasmala: qSettings.showBasmala,
                          showHeader: qSettings.showSurahHeader,
                          contentScale: qSettings.contentScale,
                          verseHeight:
                              baseTheme.verseHeight *
                              qSettings.verseHeightScale,
                          headerScale: 1.08,
                          headerWidthSmall: 410,
                          headerWidthLarge: 290,
                          firstPagesTopSpacerFactor: 0.0,
                          pageTopOverlayBuilder:
                              (pageNumber, surahNumber, startVerse) {
                                if (!qSettings.showPageInfo) {
                                  return const SizedBox.shrink();
                                }
                                final juzNumber = getJuzNumber(
                                  surahNumber,
                                  startVerse,
                                );
                                return IgnorePointer(
                                  ignoring: true,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    child: DefaultTextStyle(
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: "Inter",
                                        color: pageBgIsDark
                                            ? Colors.white.withValues(
                                                alpha: 0.90,
                                              )
                                            : const Color(
                                                0xFF111111,
                                              ).withValues(alpha: 0.88),
                                      ),
                                      child: Directionality(
                                        textDirection: TextDirection.ltr,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              getSurahNameArabic(surahNumber),
                                              textDirection: TextDirection.rtl,
                                            ),
                                            Text(
                                              "الجزء ${_arabicOrdinalLocal(context, juzNumber)}",
                                              textDirection: TextDirection.rtl,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                          pageBottomOverlayBuilder:
                              (pageNumber, surahNumber, startVerse) {
                                if (!qSettings.showPageInfo) {
                                  return const SizedBox.shrink();
                                }
                                final pageLabel = localizedNumber(
                                  context,
                                  pageNumber,
                                );
                                final hizbNumber = _hizbNumberFor(
                                  surahNumber,
                                  startVerse,
                                );
                                final hizbLabel =
                                    "الحزب ${localizedNumber(context, hizbNumber)}";
                                final showHizb = _isHizbStart(
                                  surahNumber,
                                  startVerse,
                                );

                                return IgnorePointer(
                                  ignoring: true,
                                  child: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (showHizb) ...[
                                          Text(
                                            hizbLabel,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: pageBgIsDark
                                                  ? Colors.white.withValues(
                                                      alpha: 0.82,
                                                    )
                                                  : const Color(
                                                      0xFF111111,
                                                    ).withValues(alpha: 0.78),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                        ],
                                        Text(
                                          pageLabel,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                            color: pageBgIsDark
                                                ? Colors.white.withValues(
                                                    alpha: 0.90,
                                                  )
                                                : const Color(
                                                    0xFF111111,
                                                  ).withValues(alpha: 0.88),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                        ),
                        verseBackgroundColor: (surah, verse) {
                          final key = "$surah:$verse";
                          if (highlightedAyahKey != key) return null;
                          return qSettings.highlightColor.withValues(
                            alpha: pageBgIsDark ? 0.26 : 0.22,
                          );
                        },
                        onTapDown: (surah, verse, details) {
                          final key = "$surah:$verse";
                          context.read<AyahKeyCubit>().changeCurrentAyahKey(
                            key,
                          );
                          context.read<AyahToHighlight>().changeAyah(key);
                        },
                        onTap: (surah, verse) {
                          context.read<AyahToHighlight>().changeAyah(null);
                          widget.onToggleHeader?.call();
                        },
                        onLongPressDown: (surah, verse, details) {
                          _cancelMenuTimer();
                          final ayahKey = "$surah:$verse";
                          context.read<AyahKeyCubit>().changeCurrentAyahKey(
                            ayahKey,
                          );
                          context.read<AyahToHighlight>().changeAyah(ayahKey);
                        },
                        onLongPress: (surah, verse) {
                          _cancelMenuTimer();
                          HapticFeedback.selectionClick();
                          _showOptionsSheetForAyah(
                            context: context,
                            surah: surah,
                            verse: verse,
                          );
                        },
                        onLongPressUp: (surah, verse) {
                          _cancelMenuTimer();
                          context.read<AyahToHighlight>().changeAyah(null);
                        },
                        onLongPressCancel: (surah, verse) {
                          _cancelMenuTimer();
                          context.read<AyahToHighlight>().changeAyah(null);
                        },
                        onDoubleTap: (surah, verse) async {
                          final ayahKey = "$surah:$verse";
                          context.read<AyahKeyCubit>().changeCurrentAyahKey(
                            ayahKey,
                          );

                          final wordsKey = List.generate(
                            QuranScriptFunction.getWordListOfAyah(
                              context
                                  .read<QuranViewCubit>()
                                  .state
                                  .quranScriptType,
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
                            wordByWordList:
                                await WordByWordFunction.getAyahWordByWordData(
                                  ayahKey,
                                ) ??
                                [],
                          );
                        },
                        onPageChanged: (page) {
                          _cancelMenuTimer();
                          context.read<AyahKeyCubit>().changeLastScrolledPage(
                            page,
                          );

                          final info =
                              quranPagesInfo[(page - 1).clamp(
                                0,
                                quranPagesInfo.length - 1,
                              )];
                          final ayahId = info["s"] ?? 1;
                          final key = convertAyahNumberToKey(ayahId);
                          if (key != null) {
                            context.read<AyahKeyCubit>().changeCurrentAyahKey(
                              key,
                            );
                          }
                        },
                      ),
                    ),
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
        surfaceTintColor: bg,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: bg,
          statusBarIconBrightness: bgBrightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarColor: bg,
          systemNavigationBarIconBrightness: bgBrightness == Brightness.dark
              ? Brightness.light
              : Brightness.dark,
          systemNavigationBarContrastEnforced: false,
          systemStatusBarContrastEnforced: false,
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: themeState.primary),
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
