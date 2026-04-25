import "dart:developer";

import "package:al_furkan/l10n/app_localizations.dart";
import "package:al_furkan/src/resources/quran_resources/meta/meta_data_sajda.dart"
    show metaDataSajda;
import "package:al_furkan/src/resources/quran_resources/meta/meta_data_surah.dart";
import "package:al_furkan/src/core/audio/cubit/audio_ui_cubit.dart";
import "package:al_furkan/src/core/unified_quran_settings/cubit/quran_settings_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/ayah_key_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/player_state_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/segmented_quran_reciter_cubit.dart";
import "package:al_furkan/src/core/audio/model/ayahkey_management.dart";
import "package:al_furkan/src/core/audio/services/audio_playback_service_access.dart";
import "package:al_furkan/src/resources/quran_resources/language_resources.dart";
import "package:al_furkan/src/resources/quran_resources/models/tafsir_book_model.dart";
import "package:al_furkan/src/resources/quran_resources/models/translation_book_model.dart";
import "package:al_furkan/src/screen/quran_script_view/cubit/ayah_to_highlight.dart";
import "package:al_furkan/src/core/audio/services/idrisium_audio_tracker.dart";
import "package:al_furkan/src/utils/number_localization.dart";
import "package:al_furkan/src/utils/quran_resources/get_translation.dart";
import "package:al_furkan/src/utils/quran_resources/quran_tafsir_function.dart";
import "package:al_furkan/src/utils/quran_resources/quran_script_function.dart";
import "package:al_furkan/src/widget/add_collection_popup/add_note_popup.dart";
import "package:al_furkan/src/resources/quran_resources/meaning_of_surah.dart";
import "package:al_furkan/src/screen/quran_script_view/cubit/ayah_by_ayah_in_scroll_info_cubit.dart";
import "package:al_furkan/src/screen/settings/cubit/quran_script_view_cubit.dart";
import "package:al_furkan/src/screen/settings/cubit/quran_script_view_state.dart";
import "package:al_furkan/src/screen/surah_list_view/model/surah_info_model.dart";
import "package:al_furkan/src/screen/tafsir_view/tafsir_view.dart";
import "package:al_furkan/src/theme/controller/theme_cubit.dart";
import "package:al_furkan/src/theme/controller/theme_state.dart";
import "package:al_furkan/src/theme/values/values.dart";
import "package:al_furkan/src/widget/history/cubit/quran_history_cubit.dart";
import "package:al_furkan/src/widget/quran_script/model/script_info.dart";
import "package:al_furkan/src/widget/quran_script/script_processor.dart";
import "package:dartx/dartx.dart";
import "package:fluentui_system_icons/fluentui_system_icons.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:al_furkan/src/core/navigation/wahy_page_route.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter_html/flutter_html.dart";
import "package:gap/gap.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:just_audio/just_audio.dart" as just_audio;
import "package:qcf_quran/qcf_quran.dart" as qcf;
import "package:visibility_detector/visibility_detector.dart";

import "package:al_furkan/src/screen/quran_reader/widgets/ayah_options_sheet.dart";
import "package:al_furkan/src/widget/share/unified_share_bottom_sheet.dart";

const String _kWahyBookmarks = "wahy_bookmarks";
const String _kWahyNotes = "wahy_notes";

Future<void> _setWahyBookmarkColorForAyahKey({
  required String ayahKey,
  required String colorId,
}) async {
  final box = Hive.box("user");
  final raw = box.get(_kWahyBookmarks, defaultValue: const []) as List?;
  final list = (raw ?? const [])
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
  final now = DateTime.now().toIso8601String();
  final idx = list.indexWhere((e) => (e["ayahKey"] as String?) == ayahKey);
  final entry = <String, dynamic>{
    "ayahKey": ayahKey,
    "color": colorId,
    "updatedAt": now,
    "createdAt": idx == -1 ? now : (list[idx]["createdAt"] ?? now),
  };
  if (idx == -1) {
    list.insert(0, entry);
  } else {
    list[idx] = entry;
  }
  await box.put(_kWahyBookmarks, list);
}

Future<void> _showWahyBookmarkColorSheet({
  required BuildContext context,
  required ThemeState themeState,
  required String ayahKey,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bg = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF7F1E6);
  final card = isDark ? const Color(0xFF252525) : const Color(0xFFFFF9F2);
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
            color: bg,
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
                      color: isDark
                          ? Colors.white24
                          : Colors.black.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isDark
                            ? Colors.white10
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      children: colors.entries.map((entry) {
                        return ListTile(
                          onTap: () async {
                            Navigator.pop(sheet);
                            await _setWahyBookmarkColorForAyahKey(
                              ayahKey: ayahKey,
                              colorId: entry.key,
                            );
                          },
                          title: Text(
                            entry.value.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : null,
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

Future<void> _showWahyAddNoteSheet({
  required BuildContext context,
  required ThemeState themeState,
  required String ayahKey,
}) async {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final bg = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF7F1E6);
  final controller = TextEditingController();

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
              color: bg,
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
                        fillColor: isDark
                            ? const Color(0xFF252525)
                            : const Color(0xFFFFF9F2),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white12
                                : Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: isDark
                                ? Colors.white12
                                : Colors.black.withValues(alpha: 0.08),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                            color: themeState.primary,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: themeState.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(ctx, controller.text.trim());
                        },
                        child: const Text(
                          "حفظ الملاحظة",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
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
  final box = Hive.box("user");
  final raw = box.get(_kWahyNotes, defaultValue: const []) as List?;
  final list = (raw ?? const [])
      .map((e) => Map<String, dynamic>.from(e as Map))
      .toList();
  list.insert(0, {
    "ayahKey": ayahKey,
    "text": text,
    "createdAt": DateTime.now().toIso8601String(),
  });
  await box.put(_kWahyNotes, list);
}

final Map<String, Future<String?>> _defaultTafsirFutureCache =
    <String, Future<String?>>{};
final Map<String, String?> _defaultTafsirTextCache = <String, String?>{};
final Map<String, String> _defaultTafsirBookNameCache = <String, String>{};

/// Parses tafsir text and builds a RichText widget where:
/// - ﴿...﴾ / ﴁ...ﴂ → Uthmani font + primary color (Quran ayah)
/// - {...} → Uthmani font + primary color (curly brackets)
/// - [...] → primary color only (square brackets)
Widget _buildTafsirRichText(String text, Color baseColor, ThemeState themeState, {bool isDark = false, String quranFontFamily = "QPC_Hafs"}) {
  // {} → golden yellow, [] → warm amber
  final curlyColor = isDark ? const Color(0xFFE6B422) : const Color(0xFF9E7C0A);
  final squareColor = isDark ? const Color(0xFFCD853F) : const Color(0xFF8B5E3C);
  final quranColor = isDark ? themeState.primary : curlyColor;
  final baseTextStyle = TextStyle(
    fontSize: 16,
    height: 1.9,
    fontWeight: FontWeight.w600,
    color: baseColor,
  );

  // Collect all bracket matches with their kind
  final quranPattern = RegExp(r'[﴿ﴁ][\s\S]*?[﴾ﴂ]', unicode: true);
  final curlyPattern = RegExp(r'\{[^\}]+\}');
  final squarePattern = RegExp(r'\[[^\]]+\]');

  final allMatches = <({int start, int end, String text, _TafsirBracketKind kind})>[];

  for (final m in quranPattern.allMatches(text)) {
    allMatches.add((start: m.start, end: m.end, text: m.group(0)!, kind: _TafsirBracketKind.quran));
  }
  for (final m in curlyPattern.allMatches(text)) {
    final overlaps = allMatches.any((e) => m.start < e.end && m.end > e.start);
    if (!overlaps) allMatches.add((start: m.start, end: m.end, text: m.group(0)!, kind: _TafsirBracketKind.curly));
  }
  for (final m in squarePattern.allMatches(text)) {
    final overlaps = allMatches.any((e) => m.start < e.end && m.end > e.start);
    if (!overlaps) allMatches.add((start: m.start, end: m.end, text: m.group(0)!, kind: _TafsirBracketKind.square));
  }
  allMatches.sort((a, b) => a.start.compareTo(b.start));

  if (allMatches.isEmpty) {
    return RichText(
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      text: TextSpan(text: text, style: baseTextStyle),
    );
  }

  final spans = <TextSpan>[];
  int lastEnd = 0;

  for (final match in allMatches) {
    if (match.start > lastEnd) {
      final before = text.substring(lastEnd, match.start);
      if (before.isNotEmpty) spans.add(TextSpan(text: before, style: baseTextStyle));
    }

    switch (match.kind) {
      case _TafsirBracketKind.quran:
        spans.add(TextSpan(
          text: match.text,
          style: TextStyle(fontSize: 16.5, height: 1.9, fontWeight: FontWeight.w500, fontFamily: quranFontFamily, color: quranColor),
        ));
      case _TafsirBracketKind.curly:
        spans.add(TextSpan(
          text: match.text,
          style: TextStyle(fontSize: 16, height: 1.9, fontWeight: FontWeight.w500, fontFamily: quranFontFamily, color: curlyColor),
        ));
      case _TafsirBracketKind.square:
        spans.add(TextSpan(
          text: match.text,
          style: baseTextStyle.copyWith(color: squareColor, fontWeight: FontWeight.w700),
        ));
    }
    lastEnd = match.end;
  }

  if (lastEnd < text.length) {
    final remaining = text.substring(lastEnd);
    if (remaining.isNotEmpty) spans.add(TextSpan(text: remaining, style: baseTextStyle));
  }

  return RichText(
    textDirection: TextDirection.rtl,
    textAlign: TextAlign.right,
    text: TextSpan(children: spans),
  );
}

enum _TafsirBracketKind { quran, curly, square }

Widget getAyahByAyahTafsirCard({
  dynamic key,
  required String ayahKey,
  required BuildContext context,
  bool showTopOptions = true,
  bool keepMargin = true,
}) {
  final l10n = AppLocalizations.of(context);
  final surahNumber = int.parse(ayahKey.split(":")[0]);
  final ayahNumber = int.parse(ayahKey.split(":")[1]);
  final surahInfoModel = SurahInfoModel.fromMap(metaDataSurah["$surahNumber"]!);
  final bool showSurahBanner = ayahNumber == 1;

  String? sanitizeTafsirTextLocal(String? text) {
    if (text == null) return null;
    var t = text;
    t = t.replaceAll(RegExp(r"```[\s\S]*?```"), "");
    t = t.replaceAll(RegExp(r"<[^>]*>"), " ");
    t = t.replaceAll("&nbsp;", " ");
    t = t.replaceAll("&quot;", '"');
    t = t.replaceAll("&amp;", "&");
    t = t.replaceAll(RegExp(r"\s+"), " ").trim();
    return t;
  }

  Future<String?> cachedLoadDefaultTafsir(String key) {
    final cached = _defaultTafsirTextCache[key];
    if (cached != null && cached.trim().isNotEmpty) {
      return Future.value(cached);
    }

    return _defaultTafsirFutureCache.putIfAbsent(key, () async {
      final selected = await QuranTafsirFunction.getTafsirSelections() ?? [];
      if (selected.isEmpty) return null;

      TafsirBookModel? book;
      for (final b in selected) {
        if (b.name.contains("السعدي")) {
          book = b;
          break;
        }
      }
      for (final b in selected) {
        if (book != null) break;
        if (b.name.contains("الميسر")) {
          book = b;
          break;
        }
      }
      book ??= selected.first;

      _defaultTafsirBookNameCache[key] = book.name;
      final t = await QuranTafsirFunction.getResolvedTafsirTextForBook(
        book,
        key,
      );
      final sanitized = sanitizeTafsirTextLocal(t);
      _defaultTafsirTextCache[key] = sanitized;
      return sanitized;
    });
  }

  return BlocBuilder<ThemeCubit, ThemeState>(
    builder: (context, themeState) {
      return BlocBuilder<QuranViewCubit, QuranViewState>(
        buildWhen: (previous, current) => current != previous,
        builder: (context, quranViewState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final bg = isDark ? const Color(0xFF1A1A1A) : const Color(0xFFF7F1E6);
          final card = isDark
              ? const Color(0xFF252525)
              : const Color(0xFFEFE3D2);
          final onBg = isDark ? Colors.white : const Color(0xFF1B1B1B);

          final qcfTheme = qcf.QcfThemeData.sepia().copyWith(
            pageBackgroundColor: bg,
            headerBackgroundColor: card,
            headerTextColor: onBg,
            verseTextColor: onBg,
            verseNumberColor: onBg,
          );

          return VisibilityDetector(
            key: Key("tafsir_$ayahKey"),
            onVisibilityChanged: (info) {
              if (!context.mounted) return;
              context.read<QuranHistoryCubit>().addHistory(ayahKey: ayahKey);
              try {
                context.read<AyahByAyahInScrollInfoCubit>().setData(
                  surahInfoModel: surahInfoModel,
                  dropdownAyahKey: ayahKey,
                );
              } catch (_) {}
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              key: key,
              margin: keepMargin
                  ? const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 12,
                      bottom: 12,
                    )
                  : null,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    if (showSurahBanner) ...[
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.92,
                          child: Transform.scale(
                            scale: 1.05,
                            child: qcf.HeaderWidget(
                              suraNumber: surahNumber,
                              theme: qcfTheme,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                    ],
                    Center(
                      child: ScriptProcessor(
                        scriptInfo: ScriptInfo(
                          surahNumber: surahNumber,
                          ayahNumber: ayahNumber,
                          quranScriptType: quranViewState.quranScriptType,
                          showWordHighlights: false,
                          skipWordTap: false,
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(
                            fontSize: (quranViewState.fontSize - 2).clamp(
                              18,
                              32,
                            ),
                            height: 2.05,
                            color: onBg,
                          ),
                        ),
                        themeState: themeState,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _defaultTafsirBookNameCache[ayahKey] ?? "التفسير",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: onBg.withValues(alpha: 0.70),
                              ),
                            ),
                          ),
                          // Share tafsir
                          GestureDetector(
                            onTap: () {
                              final text = _defaultTafsirTextCache[ayahKey];
                              if (text != null && text.isNotEmpty) {
                                Clipboard.setData(ClipboardData(text: text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: const Text("تم نسخ التفسير"),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.share_outlined,
                                size: 18,
                                color: onBg.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          // More options
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => TafsirView(ayahKey: ayahKey),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(6),
                              child: Icon(
                                Icons.more_vert_rounded,
                                size: 18,
                                color: onBg.withValues(alpha: 0.4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: card,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: FutureBuilder<String?>(
                          future: cachedLoadDefaultTafsir(ayahKey),
                          builder: (context, snapshot) {
                            final t = snapshot.data?.trim();
                            if (t == null || t.isEmpty) {
                              return Text(
                                l10n.tafsirNotAvailable(ayahKey),
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.center,
                                style: const TextStyle(height: 1.7),
                              );
                            }
                            return _buildTafsirRichText(t, onBg, themeState, isDark: isDark, quranFontFamily: context.read<QuranSettingsCubit>().state.fontFamily.flutterFontFamily);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Widget getAyahByAyahCard({
  dynamic key,
  required String ayahKey,
  required BuildContext context,
  bool? showFullKey,
  bool showTopOptions = true,
  bool showOnlyAyah = false,
  bool keepMargin = true,
  required List<TranslationOfAyah> translationListWithInfo,
  required List wordByWord,
}) {
  AppLocalizations? l10n = AppLocalizations.of(context);

  int surahNumber = int.parse(ayahKey.toString().split(":")[0]);
  int ayahNumber = int.parse(ayahKey.toString().split(":")[1]);
  List<TranslationBookModel?> translationBookInfoList = translationListWithInfo
      .map<TranslationBookModel?>((e) => e.bookInfo)
      .toList();
  List<String> translationList = translationListWithInfo
      .map<String>((e) => e.translation?["t"] ?? "Translation Not Found")
      .toList();
  translationList = translationList
      .map((e) => e.replaceAll(">", "> "))
      .toList();
  List<Map> footNoteList = translationListWithInfo
      .map<Map>((e) => e.translation?["f"] ?? {})
      .toList();
  List<Map<int, String>> footNoteAsStringMap = [];
  for (int index = 0; index < footNoteList.length; index++) {
    Map footNote = footNoteList[index];
    String footNoteAsString = "\n";
    if (footNote.isNotEmpty) {
      footNote.forEach((key, value) {
        footNoteAsString += "$key. $value\n";
      });
    }
    if (footNote.isNotEmpty) {
      footNoteAsStringMap.add({index: footNoteAsString});
    } else {
      footNoteAsStringMap.add({});
    }
  }

  SurahInfoModel surahInfoModel = SurahInfoModel.fromMap(
    metaDataSurah["$surahNumber"]!,
  );

  bool isSajdaAyah = false;
  bool isSajdaRequired = false;
  for (Map sajdaAyah in metaDataSajda) {
    if (sajdaAyah["verse_key"] == ayahKey) {
      isSajdaAyah = true;
      isSajdaRequired = sajdaAyah["required"];
      break;
    }
  }

  return BlocBuilder<ThemeCubit, ThemeState>(
    builder: (context, themeState) {
      return BlocBuilder<QuranViewCubit, QuranViewState>(
        buildWhen: (previous, current) {
          return current != previous;
        },
        builder: (context, quranViewState) {
          return VisibilityDetector(
            key: Key(ayahKey),
            onVisibilityChanged: (info) {
              if (!context.mounted) {
                return;
              }
              context.read<QuranHistoryCubit>().addHistory(ayahKey: ayahKey);
              try {
                SurahInfoModel surahInfoModel = SurahInfoModel.fromMap(
                  metaDataSurah[ayahKey.split(":").first]!,
                );

                context.read<AyahByAyahInScrollInfoCubit>().setData(
                  surahInfoModel: surahInfoModel,
                  dropdownAyahKey: ayahKey,
                );
              } catch (e) {
                log(e.toString());
              }
            },
            child: BlocBuilder<AudioAyahHighlightCubit, AudioAyahHighlightState>(
              buildWhen: (p, c) => p.activeAyahKey != c.activeAyahKey,
              builder: (context, audioHighlight) {
                return BlocBuilder<AyahToHighlight, String?>(
                  buildWhen: (previous, current) {
                    return current != previous;
                  },
                  builder: (context, ayahToHighlightState) {
                    // Audio highlight takes priority over manual highlight
                    final effectiveHighlight = audioHighlight.activeAyahKey ?? ayahToHighlightState;
                    final bool isHighlighted = effectiveHighlight == ayahKey;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onLongPress: () {
                      final words = QuranScriptFunction.getWordListOfAyah(
                        quranViewState.quranScriptType,
                        surahNumber.toString(),
                        ayahNumber.toString(),
                      );
                      final stripped = words
                          .join(" ")
                          .replaceAll(RegExp(r"<[^>]+>"), "")
                          .replaceAll(RegExp(r"\s+"), " ")
                          .trim();
                      final overlayContext =
                          Navigator.of(context).overlay?.context ?? context;
                      Future<void> openUnifiedShareSheet() {
                        return UnifiedShareBottomSheet.show(
                          context: overlayContext,
                          surahNumber: surahNumber,
                          verseNumber: ayahNumber,
                          getAyahText: (surah, verse) {
                            final ayahWords =
                                QuranScriptFunction.getWordListOfAyah(
                                  quranViewState.quranScriptType,
                                  surah.toString(),
                                  verse.toString(),
                                );
                            return ayahWords
                                .join(" ")
                                .replaceAll(RegExp(r"<[^>]+>"), "")
                                .replaceAll(RegExp(r"\s+"), " ")
                                .trim();
                          },
                        );
                      }

                      AyahOptionsSheet.show(
                        context: overlayContext,
                        ayahKey: ayahKey,
                        ayahText: stripped,
                        onShareAsImage: () {
                          openUnifiedShareSheet();
                        },
                        onShareAsText: () {
                          openUnifiedShareSheet();
                        },
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      key: key,
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width < 360
                            ? 14
                            : 24,
                        vertical: MediaQuery.of(context).size.width < 360
                            ? 16
                            : 24,
                      ),
                      margin: EdgeInsets.only(
                        left: MediaQuery.of(context).size.width < 360 ? 10 : 20,
                        right: MediaQuery.of(context).size.width < 360
                            ? 10
                            : 20,
                        bottom: 24,
                      ),
                      decoration: BoxDecoration(
                        color: isHighlighted
                            ? themeState.primary.withValues(
                                alpha:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? 0.14
                                    : 0.08,
                              )
                            : Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1E2121)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isHighlighted
                              ? themeState.primary.withValues(alpha: 0.22)
                              : Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: isHighlighted ? 0.04 : 0.05,
                            ),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          if (!(showTopOptions == false) &&
                              !quranViewState.hideToolbar)
                            getToolbarWidget(
                              showFullKey,
                              surahInfoModel,
                              ayahKey,
                              ayahNumber,
                              context,
                              surahNumber,
                              translationList,
                              footNoteAsStringMap,
                              translationBookInfoList,
                              themeState,
                            ),
                          if (!quranViewState.hideQuranAyah) const Gap(10),
                          if (!quranViewState.hideQuranAyah)
                            quranAyahWidget(
                              surahNumber,
                              ayahNumber,
                              quranViewState,
                              themeState,
                            ),
                          if (!showOnlyAyah && !quranViewState.hideTranslation)
                            const Gap(5),
                          if (isSajdaAyah)
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.red),
                                borderRadius: BorderRadius.circular(
                                  roundedRadius,
                                ),
                              ),
                              height: 35,

                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Image(
                                    height: 25,
                                    width: 25,
                                    image: const AssetImage(
                                      "assets/img/sajadah.png",
                                    ),
                                    color:
                                        Theme.of(context).brightness ==
                                            Brightness.light
                                        ? Colors.grey.shade900
                                        : Colors.white,
                                    colorBlendMode: BlendMode.srcIn,
                                  ),
                                  const Gap(10),
                                  Text(
                                    l10n.sajdaAyah,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Gap(8),
                                  const Text("-"),
                                  const Gap(8),
                                  Text(
                                    isSajdaRequired
                                        ? l10n.required
                                        : l10n.optional,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (isSajdaAyah) const Gap(5),

                          // ─── Per-Ayah Play / Menu Row ───
                          const Gap(10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Play this ayah
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(999),
                                    onTap: () {
                                      final reciter = context
                                          .read<SegmentedQuranReciterCubit>()
                                          .state;
                                      audioPlaybackService.playSingleAyah(
                                        ayahKey: ayahKey,
                                        reciterInfoModel: reciter,
                                        isInsideQuran: true,
                                        instantPlay: true,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: themeState.primary.withValues(
                                          alpha: 0.1,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.play_arrow_rounded,
                                        color: themeState.primary,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ),
                                const Gap(8),
                                // Menu button
                                Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(999),
                                    onTap: () {
                                      final words =
                                          QuranScriptFunction.getWordListOfAyah(
                                            quranViewState.quranScriptType,
                                            surahNumber.toString(),
                                            ayahNumber.toString(),
                                          );
                                      final stripped = words
                                          .join(" ")
                                          .replaceAll(RegExp(r"<[^>]+>"), "")
                                          .replaceAll(RegExp(r"\s+"), " ")
                                          .trim();
                                      final overlayContext =
                                          Navigator.of(
                                            context,
                                          ).overlay?.context ??
                                          context;
                                      Future<void> openUnifiedShareSheet() {
                                        return UnifiedShareBottomSheet.show(
                                          context: overlayContext,
                                          surahNumber: surahNumber,
                                          verseNumber: ayahNumber,
                                          getAyahText: (surah, verse) {
                                            final ayahWords =
                                                QuranScriptFunction.getWordListOfAyah(
                                                  quranViewState
                                                      .quranScriptType,
                                                  surah.toString(),
                                                  verse.toString(),
                                                );
                                            return ayahWords
                                                .join(" ")
                                                .replaceAll(
                                                  RegExp(r"<[^>]+>"),
                                                  "",
                                                )
                                                .replaceAll(RegExp(r"\s+"), " ")
                                                .trim();
                                          },
                                        );
                                      }

                                      AyahOptionsSheet.show(
                                        context: overlayContext,
                                        ayahKey: ayahKey,
                                        ayahText: stripped,
                                        onShareAsImage: () {
                                          openUnifiedShareSheet();
                                        },
                                        onShareAsText: () {
                                          openUnifiedShareSheet();
                                        },
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color:
                                            (Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black)
                                                .withValues(alpha: 0.06),
                                      ),
                                      child: Icon(
                                        Icons.menu_rounded,
                                        color:
                                            Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white70
                                            : Colors.black54,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Gap(6),

                          if (!showOnlyAyah && !quranViewState.hideTranslation)
                            const Gap(5),
                          if (!showOnlyAyah && !quranViewState.hideTranslation)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: themeState.primary.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  l10n.translationTitle,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: themeState.primary,
                                  ),
                                ),
                              ),
                            ),
                          if (!showOnlyAyah && !quranViewState.hideTranslation)
                            const Gap(5),
                          if (!showOnlyAyah && !quranViewState.hideTranslation)
                            getTranslationWithFootNoteWidget(
                              context,
                              translationList,
                              footNoteAsStringMap,
                              translationBookInfoList,
                              quranViewState,
                              showOnlyAyah,
                              l10n,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
                  },
                );
              },
            ),
          );
        },
      );
    },
  );
}

class _AyahStatusIndicators extends StatelessWidget {
  final String ayahKey;
  final ThemeState themeState;

  const _AyahStatusIndicators({
    required this.ayahKey,
    required this.themeState,
  });

  bool _isAyahBookmarked(List<Map<String, dynamic>> list) {
    return list.any((e) => (e["ayahKey"] as String?) == ayahKey);
  }

  bool _isAyahNoted(List<Map<String, dynamic>> list) {
    return list.any((e) => (e["ayahKey"] as String?) == ayahKey);
  }

  bool _isAyahStarred(List<String> list) {
    return list.contains(ayahKey);
  }

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box("user");

    return ValueListenableBuilder(
      valueListenable: userBox.listenable(),
      builder: (context, _, __) {
        final rawBookmarks =
            userBox.get(_kWahyBookmarks, defaultValue: const []) as List?;
        final rawNotes =
            userBox.get(_kWahyNotes, defaultValue: const []) as List?;
        final rawStarred =
            userBox.get("wahy_starred", defaultValue: const []) as List?;

        final bookmarks = (rawBookmarks ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        final notes = (rawNotes ?? const [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        final starred = List<String>.from(rawStarred ?? const []);

        final isBookmarked = _isAyahBookmarked(bookmarks);
        final isNoted = _isAyahNoted(notes);
        final isStarred = _isAyahStarred(starred);

        if (!isBookmarked && !isNoted && !isStarred) {
          return const SizedBox.shrink();
        }

        Widget dot(Color c) {
          return Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: c,
              borderRadius: BorderRadius.circular(99),
            ),
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isStarred) dot(const Color(0xFFF4B400)),
            if (isStarred && isBookmarked) const Gap(6),
            if (isBookmarked) dot(themeState.primary),
            if ((isStarred || isBookmarked) && isNoted) const Gap(6),
            if (isNoted) dot(const Color(0xFF2962FF)),
          ],
        );
      },
    );
  }
}

Align getFootNoteWidget(
  Map<dynamic, dynamic> footNote,
  BuildContext context,
  QuranViewState quranViewState,
  ) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Column(
      children: List.generate(footNote.length, (index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: context.read<ThemeCubit>().state.primaryShade300,
              child: Text(
                localizedNumber(context, index + 1),
                style: const TextStyle(fontSize: 12),
              ),
            ),
            const Gap(5),
            Container(
              decoration: const BoxDecoration(),
              padding: const EdgeInsets.only(bottom: 5),
              width: MediaQuery.of(context).size.width * 0.85,

              child: Html(
                data: footNote.values.elementAt(index).toString().capitalize(),
                style: {
                  "*": Style(
                    fontSize: FontSize(quranViewState.translationFontSize),
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),
                },
              ),
            ),
          ],
        );
      }),
    ),
  );
}

Widget getTranslationWithFootNoteWidget(
  BuildContext context,
  List<String> translationList,
  List<Map<int, String>> footNoteAsStringMap,
  List<TranslationBookModel?> translationBookInfoList,
  QuranViewState quranViewState,
  bool showOnlyAyah,
  AppLocalizations l10n,
) {
  return Column(
    children: List.generate(translationBookInfoList.length, (index) {
      String translation = translationList[index];
      Map<int, String> footNote = footNoteAsStringMap[index];
      TranslationBookModel? bookModel = translationBookInfoList[index];

      return Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Html(
              data: translation.capitalize(),
              style: {
                "*": Style(
                  fontSize: FontSize(quranViewState.translationFontSize),
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
              },
            ),
          ),

          if (footNote.keys.isNotEmpty &&
              !showOnlyAyah &&
              !quranViewState.hideFootnote)
            const Gap(8),
          if (footNote.keys.isNotEmpty &&
              !showOnlyAyah &&
              !quranViewState.hideFootnote)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.footNoteTitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
            ),
          if (footNote.keys.isNotEmpty &&
              !showOnlyAyah &&
              !quranViewState.hideFootnote)
            const Gap(5),

          if (footNote.isNotEmpty &&
              !showOnlyAyah &&
              !quranViewState.hideFootnote)
            getFootNoteWidget(footNote, context, quranViewState),
          const Gap(5),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(height: 1, width: 25, color: Colors.grey),
              const Gap(7),
              Text(
                bookModel?.name ?? bookModel?.fileName.split("/").last ?? "",
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
              ),
              if (bookModel?.language != null)
                Text(
                  " (${languageNativeNames[bookModel!.language.toLowerCase()] ?? ""})",
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
            ],
          ),
          const Gap(5),
        ],
      );
    }),
  );
}

Align quranAyahWidget(
  int surahNumber,
  int ayahNumber,
  QuranViewState quranViewState,
  ThemeState themeState,
) {
  return Align(
    alignment: Alignment.centerRight,
    child: ScriptProcessor(
      scriptInfo: ScriptInfo(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        quranScriptType: quranViewState.quranScriptType,
        showWordHighlights: quranViewState.enableWordByWordHighlight == true,
        textStyle: TextStyle(
          fontSize: quranViewState.fontSize,
          height: quranViewState.lineHeight,
        ),
      ),
      themeState: themeState,
    ),
  );
}

Widget getToolbarWidget(
  bool? showFullKey,
  SurahInfoModel surahInfoModel,
  String ayahKey,
  int ayahNumber,
  BuildContext context,
  int surahNumber,
  List<String> translation,
  List<Map<int, String>> footNoteAsStringMap,
  List<TranslationBookModel?> translationBookInfoList,
  ThemeState themeState,
) {
  final l10n = AppLocalizations.of(context);
  final btnSize = MediaQuery.of(context).size.width < 360 ? 24.0 : 28.0;
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: themeState.primary.withValues(alpha: 0.05),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: themeState.primary.withValues(alpha: 0.10)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: themeState.primaryShade300,
                borderRadius: BorderRadius.circular(roundedRadius - 4),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                showFullKey == true
                    ? "${getSurahName(context, surahInfoModel.id)}\nالآية ${localizedNumber(context, ayahNumber)}"
                    : localizedNumber(context, ayahNumber),
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            const Gap(6),
            _AyahStatusIndicators(ayahKey: ayahKey, themeState: themeState),
            const Spacer(),
            SizedBox(
              height: 30,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    WahyPageRoute(page: TafsirView(ayahKey: ayahKey)),
                  );
                },
                child: Text(l10n.tafsirButton),
              ),
            ),
            const Gap(4),
            SizedBox(
              height: btnSize,
              width: btnSize,
              child: BlocBuilder<QuranViewCubit, QuranViewState>(
                builder: (context, quranViewState) {
                  return IconButton(
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: themeState.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: BorderSide(color: themeState.primary),
                      ),
                    ),
                    onPressed: () {
                      UnifiedShareBottomSheet.show(
                        context: context,
                        surahNumber: surahInfoModel.id,
                        verseNumber: ayahNumber,
                        getAyahText: (surah, verse) {
                          final ayahWords =
                              QuranScriptFunction.getWordListOfAyah(
                                quranViewState.quranScriptType,
                                surah.toString(),
                                verse.toString(),
                              );
                          return ayahWords
                              .join(" ")
                              .replaceAll(RegExp(r"<[^>]+>"), "")
                              .replaceAll(RegExp(r"\s+"), " ")
                              .trim();
                        },
                      );
                    },
                    tooltip: l10n.shareButton,
                    icon: Icon(
                      FluentIcons.share_24_filled,
                      size: btnSize * 0.6,
                    ),
                  );
                },
              ),
            ),
            const Gap(4),
            SizedBox(
              height: btnSize,
              width: btnSize,
              child: IconButton(
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: themeState.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: BorderSide(color: themeState.primary),
                  ),
                ),
                onPressed: () async {
                  await showAddNotePopup(context, ayahKey);
                },
                tooltip: l10n.addNoteButton,
                icon: Icon(FluentIcons.note_add_24_filled, size: btnSize * 0.6),
              ),
            ),
            const Gap(4),
            SizedBox(
              height: btnSize,
              width: btnSize,
              child: IconButton(
                style: IconButton.styleFrom(
                  padding: EdgeInsets.zero,
                  foregroundColor: themeState.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100),
                    side: BorderSide(color: themeState.primary),
                  ),
                ),
                onPressed: () {
                  _showWahyBookmarkColorSheet(
                    context: context,
                    themeState: themeState,
                    ayahKey: ayahKey,
                  );
                },
                tooltip: l10n.pinToCollectionButton,
                icon: Icon(FluentIcons.pin_24_filled, size: btnSize * 0.6),
              ),
            ),
            const Gap(4),
            SizedBox(
              height: btnSize,
              width: btnSize,
              child: ValueListenableBuilder(
                valueListenable: Hive.box(
                  "user",
                ).listenable(keys: ["wahy_starred"]),
                builder: (context, box, _) {
                  final starred = List<String>.from(
                    box.get("wahy_starred", defaultValue: const []) as List? ??
                        [],
                  );
                  final isStarred = starred.contains(ayahKey);

                  return IconButton(
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      foregroundColor: isStarred
                          ? const Color(0xFFF4B400)
                          : themeState.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                        side: BorderSide(
                          color: isStarred
                              ? const Color(0xFFF4B400)
                              : themeState.primary,
                        ),
                      ),
                    ),
                    onPressed: () async {
                      final list = List<String>.from(starred);
                      if (isStarred) {
                        list.remove(ayahKey);
                      } else {
                        list.add(ayahKey);
                      }
                      await box.put("wahy_starred", list);
                    },
                    tooltip: isStarred ? "إزالة من المفضلة" : "إضافة للمفضلة",
                    icon: Icon(
                      isStarred
                          ? FluentIcons.star_24_filled
                          : FluentIcons.star_24_regular,
                      size: btnSize * 0.6,
                    ),
                  );
                },
              ),
            ),
            const Gap(4),
            SizedBox(
              height: btnSize,
              width: btnSize,
              child: BlocBuilder<PlayerStateCubit, PlayerState>(
                builder: (context, playerState) {
                  return BlocBuilder<AyahKeyCubit, AyahKeyManagement>(
                    builder: (context, ayahKeyManagement) {
                      bool isPlaying = playerState.isPlaying;
                      bool isCurrent =
                          ayahKeyManagement.current == ayahKey &&
                          context
                                  .read<AudioUiCubit>()
                                  .state
                                  .isInsideQuranPlayer ==
                              true;

                      return getPlayButtonWidget(
                        context,
                        ayahKey,
                        isCurrent,
                        isPlaying,
                        ayahKeyManagement,
                        playerState,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

IconButton getPlayButtonWidget(
  BuildContext context,
  String ayahKey,
  bool isCurrent,
  bool isPlaying,
  AyahKeyManagement ayahKeyManagement,
  PlayerState playerState,
) {
  ThemeState themeState = context.read<ThemeCubit>().state;
  return IconButton(
    style: IconButton.styleFrom(
      padding: EdgeInsets.zero,
      foregroundColor: themeState.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(color: themeState.primary),
      ),
    ),
    onPressed: () async {
      if (context.read<AudioUiCubit>().state.isInsideQuranPlayer == false) {
        audioPlaybackService.playSingleAyah(
          ayahKey: ayahKey,
          reciterInfoModel: context.read<SegmentedQuranReciterCubit>().state,
          instantPlay: true,
          isInsideQuran: true,
        );
      } else if (isCurrent && isPlaying) {
        audioPlaybackService.pause();
      } else if (isCurrent) {
        audioPlaybackService.resume();
      } else {
        log("Current Ayah: $ayahKey");
        bool isPlayList = context.read<AudioUiCubit>().state.isPlayList;
        if (isPlayList &&
            ayahKeyManagement.current.split(":").first ==
                ayahKey.split(":").first) {
          await audioPlaybackService.seek(
            Duration.zero,
            index: ayahKeyManagement.ayahList.indexOf(ayahKey),
          );
          await audioPlaybackService.resume();
        } else {
          audioPlaybackService.playSingleAyah(
            ayahKey: ayahKey,
            reciterInfoModel: context.read<SegmentedQuranReciterCubit>().state,
            instantPlay: true,
            isInsideQuran: true,
          );
        }
      }
    },
    icon: (isCurrent && playerState.state == just_audio.ProcessingState.loading)
        ? Padding(
            padding: const EdgeInsets.all(3.0),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              backgroundColor: context.read<ThemeCubit>().state.primaryShade100,
            ),
          )
        : Icon(
            isPlaying && isCurrent
                ? Icons.pause_rounded
                : Icons.play_arrow_rounded,
            size: 18,
          ),
  );
}
