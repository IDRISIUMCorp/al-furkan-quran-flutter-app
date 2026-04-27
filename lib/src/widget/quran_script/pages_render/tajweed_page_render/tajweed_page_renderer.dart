import "package:al_furkan/src/core/unified_quran_settings/cubit/quran_settings_cubit.dart";
import "package:al_furkan/src/screen/quran_script_view/cubit/ayah_to_highlight.dart";
import "package:al_furkan/src/core/audio/services/idrisium_audio_tracker.dart";
import "package:al_furkan/src/utils/quran_resources/quran_script_function.dart";
import "package:al_furkan/src/widget/quran_script/model/script_info.dart";
import "package:al_furkan/src/screen/collections/collection_page.dart";
import "package:al_furkan/src/screen/collections/models/note_collection_model.dart";
import "package:al_furkan/src/screen/collections/models/pinned_collection_model.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:fluentui_system_icons/fluentui_system_icons.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:qcf_quran/qcf_quran.dart";

import "../../../../theme/controller/theme_cubit.dart";
import "../../../../theme/controller/theme_state.dart";

class TajweedPageRenderer extends StatelessWidget {
  final List<String> ayahsKey;
  final TextStyle? baseTextStyle;
  final bool? enableWordByWordHighlight;

  const TajweedPageRenderer({
    super.key,
    required this.ayahsKey,
    this.baseTextStyle,
    this.enableWordByWordHighlight,
  });

  @override
  Widget build(BuildContext context) {
    ThemeState themeState = context.read<ThemeCubit>().state;

    String? highlightingWord;

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: BlocBuilder<AudioAyahHighlightCubit, AudioAyahHighlightState>(
        buildWhen: (previous, current) {
          bool wasInScope = previous.activeAyahKey != null && ayahsKey.contains(previous.activeAyahKey);
          bool isInScope = current.activeAyahKey != null && ayahsKey.contains(current.activeAyahKey);
          
          if (wasInScope || isInScope) {
            highlightingWord = current.activeWordKey;
            return previous.activeWordKey != current.activeWordKey || previous.activeAyahKey != current.activeAyahKey;
          }
          return false;
        },
        builder: (context, highlightState) {
          final audioAyahKey = highlightState.activeAyahKey;
          final manualAyahKey = context.watch<AyahToHighlight>().state;
          
          return Text.rich(
                TextSpan(
                  children:
                      ayahsKey.map((ayahKey) {
                        List words = QuranScriptFunction.getWordListOfAyah(
                          QuranScriptType.tajweed,
                          ayahKey.split(":").first,
                          ayahKey.split(":").last,
                        );
                        return TextSpan(
                          style: TextStyle(
                            backgroundColor: audioAyahKey == ayahKey
                                ? (isDark
                                    ? Colors.white.withValues(alpha: 0.08)
                                    : Colors.black.withValues(alpha: 0.08))
                                : (manualAyahKey == ayahKey
                                    ? (isDark
                                        ? themeState.primary.withValues(alpha: 0.15)
                                        : themeState.primary.withValues(alpha: 0.15))
                                    : null),
                          ),
                          children:
                              List.generate(words.length, (index) {
                                final span = parseTajweedWord(
                                  wordWithTajweed: words[index],
                                  wordIndex: index,
                                  isLight: !isDark,
                                  enableTajweed: context.watch<QuranSettingsCubit>().state.tajweedEnabled,
                                  baseStyle: TextStyle(
                                    fontSize: baseTextStyle?.fontSize ?? 24,
                                    fontFamily:
                                        baseTextStyle?.fontFamily ?? context.watch<QuranSettingsCubit>().state.fontFamily.flutterFontFamily,
                                    height: baseTextStyle?.height,
                                    backgroundColor:
                                        (highlightingWord ==
                                                    "$ayahKey:${index + 1}" &&
                                                enableWordByWordHighlight ==
                                                    true)
                                            ? themeState.primaryShade300
                                            : null,
                                  ),
                                  highlights: (highlightingWord == "$ayahKey:${index + 1}" && enableWordByWordHighlight == true) ? [HighlightRange(wordIndex: index, color: themeState.primaryShade300)] : null,
                                  onTap: () {},
                                );

                                final bool isLast = index == (words.length - 1);
                                if (!isLast) return span;

                                return TextSpan(
                                  children: [
                                    span,
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.top,
                                      child: _AyahInlineStatusIndicator(
                                        ayahKey: ayahKey,
                                        color: themeState.primary,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                        );
                      }).toList(),
                ),
                style: TextStyle(
                  fontSize: baseTextStyle?.fontSize ?? 24,
                  fontFamily: baseTextStyle?.fontFamily ?? context.watch<QuranSettingsCubit>().state.fontFamily.flutterFontFamily,
                  fontWeight: baseTextStyle?.fontWeight,
                  letterSpacing: 0,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              );
            },
          ),
    );
  }
}

class _AyahInlineStatusIndicator extends StatelessWidget {
  final String ayahKey;
  final Color color;

  const _AyahInlineStatusIndicator({required this.ayahKey, required this.color});

  bool _isPinned(Iterable<dynamic> boxValues) {
    for (final value in boxValues) {
      try {
        final model = PinnedCollectionModel.fromJson(
          Map<String, dynamic>.from(value),
        );
        if (model.pinned.any((p) => p.ayahKey == ayahKey)) {
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  bool _isNoted(Iterable<dynamic> boxValues) {
    for (final value in boxValues) {
      try {
        final model = NoteCollectionModel.fromJson(
          Map<String, dynamic>.from(value),
        );
        for (final note in model.notes) {
          if (note.ayahKey.contains(ayahKey)) {
            return true;
          }
        }
      } catch (_) {}
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final pinnedBox = Hive.box(CollectionType.pinned.name);
    final notesBox = Hive.box(CollectionType.notes.name);

    return ValueListenableBuilder(
      valueListenable: pinnedBox.listenable(),
      builder: (context, _, __) {
        final isPinned = _isPinned(pinnedBox.values);
        return ValueListenableBuilder(
          valueListenable: notesBox.listenable(),
          builder: (context, __, ___) {
            final isNoted = _isNoted(notesBox.values);
            if (!isPinned && !isNoted) return const SizedBox.shrink();
            return Transform.translate(
              offset: const Offset(0, -6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPinned)
                    Icon(
                      FluentIcons.pin_24_filled,
                      size: 12,
                      color: color,
                    ),
                  if (isPinned && isNoted) const SizedBox(width: 4),
                  if (isNoted)
                    Icon(
                      FluentIcons.note_add_24_filled,
                      size: 12,
                      color: color,
                    ),
                  const SizedBox(width: 2),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
