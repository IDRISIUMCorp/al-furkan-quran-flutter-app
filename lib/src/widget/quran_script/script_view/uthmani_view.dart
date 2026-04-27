import "package:al_furkan/src/core/audio/services/idrisium_audio_tracker.dart";
import "package:al_furkan/src/core/unified_quran_settings/cubit/quran_settings_cubit.dart";
import "package:al_furkan/src/screen/settings/cubit/quran_script_view_cubit.dart";
import "package:al_furkan/src/utils/quran_resources/quran_script_function.dart";
import "package:al_furkan/src/utils/quran_word/show_popup_word_function.dart";
import "package:al_furkan/src/widget/quran_script/model/script_info.dart";
import "package:al_furkan/src/utils/quran_ayahs_function/get_page_number.dart";
import "package:qcf_quran/qcf_quran.dart" as qcf;
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../theme/controller/theme_state.dart";

class NonTajweedScriptView extends StatelessWidget {
  final bool isUthmani;
  final ScriptInfo scriptInfo;
  final ThemeState themeState;

  const NonTajweedScriptView({
    super.key,
    required this.scriptInfo,
    required this.isUthmani,
    required this.themeState,
  });

  @override
  Widget build(BuildContext context) {
    List words = QuranScriptFunction.getWordListOfAyah(
      isUthmani ? QuranScriptType.uthmani : QuranScriptType.indopak,
      scriptInfo.surahNumber.toString(),
      scriptInfo.ayahNumber.toString(),
    );
    if (scriptInfo.limitWord != null) {
      if (!(scriptInfo.limitWord! >= words.length)) {
        words = words.sublist(0, scriptInfo.limitWord);
      }
    }
    // Use the user-selected font family from settings, fallback to default per script type
    final settingsFont = context.watch<QuranSettingsCubit>().state.fontFamily;
    final effectiveFontFamily = isUthmani
        ? (settingsFont == QuranFontFamily.alQuranNeo ||
                settingsFont == QuranFontFamily.indopakNastaleeq ||
                settingsFont == QuranFontFamily.meQuranVolt
            ? settingsFont.flutterFontFamily
            : settingsFont.flutterFontFamily)
        : (settingsFont == QuranFontFamily.alQuranNeo ||
                settingsFont == QuranFontFamily.indopakNastaleeq ||
                settingsFont == QuranFontFamily.meQuranVolt
            ? settingsFont.flutterFontFamily
            : "AlQuranNeov5x1");
    final TextStyle quranStyle = TextStyle(
      fontSize: scriptInfo.textStyle?.fontSize ?? 24,
      height: scriptInfo.textStyle?.height ?? 2,
      color: scriptInfo.textStyle?.color,
      fontFamily: effectiveFontFamily,
      letterSpacing: 0,
    );

    if (words.isEmpty) {
      final ayahKey = "${scriptInfo.surahNumber}:${scriptInfo.ayahNumber}";
      final pageNumber = getPageNumber(ayahKey) ?? 1;
      final pageFont = "QCF_P${pageNumber.toString().padLeft(3, '0')}";
      return Text(
        qcf.getVerseQCF(
          scriptInfo.surahNumber,
          scriptInfo.ayahNumber,
          verseEndSymbol: false,
        ),
        textDirection: TextDirection.rtl,
        textAlign: scriptInfo.textAlign ?? TextAlign.center,
        style: TextStyle(
          fontFamily: pageFont,
          fontSize: (quranStyle.fontSize ?? 24).clamp(22, 34),
          height: quranStyle.height ?? 2.0,
          color: quranStyle.color,
        ),
      );
    }

    if (scriptInfo.wordIndex != null) {
      return Text.rich(
        style: quranStyle,
        textDirection: TextDirection.rtl,
        textAlign: scriptInfo.textAlign,
        TextSpan(
          children: [TextSpan(text: words[scriptInfo.wordIndex!] + " ")],
        ),
      );
    }

    final String ayahKey = "${scriptInfo.surahNumber}:${scriptInfo.ayahNumber}";

    if (scriptInfo.forImage == true) {
      return Text.rich(
        style: quranStyle,
        textDirection: TextDirection.rtl,
        textAlign: scriptInfo.textAlign,
        TextSpan(
          children: List<InlineSpan>.generate(words.length, (index) {
            return TextSpan(
              text: words[index] + " ",
              recognizer: scriptInfo.skipWordTap == true
                  ? null
                  : (TapGestureRecognizer()
                      ..onTap = () async {
                        final List<String> wordsKey = List.generate(
                          words.length,
                          (i) =>
                              "${scriptInfo.surahNumber}:${scriptInfo.ayahNumber}:${i + 1}",
                        );
                        showPopupWordFunction(
                          context: context,
                          wordKeys: wordsKey,
                          initWordIndex: index,
                          wordByWordList: const [],
                        );
                      }),
            );
          }),
        ),
      );
    }

    final bool enableWordByWordHighlight =
        context.read<QuranViewCubit>().state.enableWordByWordHighlight == true;

    return BlocBuilder<AudioAyahHighlightCubit, AudioAyahHighlightState>(
      buildWhen: (previous, current) {
        final bool wasInScope = previous.activeAyahKey != null && previous.activeAyahKey == ayahKey;
        final bool isInScope = current.activeAyahKey != null && current.activeAyahKey == ayahKey;
        if (wasInScope || isInScope) {
          return previous.activeAyahKey != current.activeAyahKey ||
              previous.activeWordKey != current.activeWordKey;
        }
        return false;
      },
      builder: (context, highlightState) {
        final bool isDark = Theme.of(context).brightness == Brightness.dark;
        final bool isAyahHighlighted = highlightState.activeAyahKey == ayahKey;
        final String? highlightingWordIndex = highlightState.activeWordKey;
        final highlightColor = context.watch<QuranSettingsCubit>().state.highlightColor;
        return Text.rich(
          style: quranStyle,
          textDirection: TextDirection.rtl,
          textAlign: scriptInfo.textAlign,
          TextSpan(
            style: isAyahHighlighted
                ? TextStyle(
                    backgroundColor: highlightColor.withValues(
                      alpha: isDark ? 0.26 : 0.22,
                    ),
                  )
                : null,
            children: List<InlineSpan>.generate(words.length, (index) {
              final String word = words[index];
              final bool isLastWord =
                  index == (words.length - 1) && word.length < 3;
              final bool willHighLight =
                  enableWordByWordHighlight &&
                  highlightingWordIndex == "$ayahKey:${index + 1}";

              return TextSpan(
                style: isLastWord
                    ? TextStyle(fontFamily: effectiveFontFamily)
                    : willHighLight
                        ? TextStyle(
                            backgroundColor: highlightColor.withValues(
                              alpha: 0.35,
                            ),
                          )
                        : null,

                text: "$word ",
                recognizer: scriptInfo.skipWordTap == true
                    ? null
                    : (DoubleTapGestureRecognizer()
                        ..onDoubleTap = () async {
                          final List<String> wordsKey = List.generate(
                            words.length,
                            (i) =>
                                "${scriptInfo.surahNumber}:${scriptInfo.ayahNumber}:${i + 1}",
                          );
                          showPopupWordFunction(
                            context: context,
                            wordKeys: wordsKey,
                            initWordIndex: index,
                            wordByWordList: const [],
                          );
                        }),
              );
            }),
          ),
        );
      },
    );
  }
}
