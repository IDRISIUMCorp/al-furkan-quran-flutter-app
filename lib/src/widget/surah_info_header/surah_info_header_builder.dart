import "package:al_furkan/l10n/app_localizations.dart";
import "package:al_furkan/src/core/audio/cubit/audio_ui_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/ayah_key_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/player_state_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/segmented_quran_reciter_cubit.dart";
import "package:al_furkan/src/core/audio/model/ayahkey_management.dart";
import "package:al_furkan/src/core/audio/services/audio_playback_service_access.dart";
import "package:al_furkan/src/resources/translation/language_cubit.dart";
import "package:al_furkan/src/utils/quran_resources/quran_translation_function.dart";
import "package:al_furkan/src/screen/quran_script_view/model/surah_header_info.dart";
import "package:al_furkan/src/screen/settings/cubit/quran_script_view_cubit.dart";
import "package:al_furkan/src/screen/settings/cubit/quran_script_view_state.dart";
import "package:al_furkan/src/screen/surah_info/surah_info_view.dart";
import "package:al_furkan/src/theme/values/values.dart";
import "package:al_furkan/src/widget/quran_script/model/script_info.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:gap/gap.dart";
import "package:just_audio/just_audio.dart" as just_audio;

import "../../theme/controller/theme_cubit.dart";
import "../../theme/controller/theme_state.dart";

class SurahInfoHeaderBuilder extends StatelessWidget {
  final SurahHeaderInfoModel headerInfoModel;

  const SurahInfoHeaderBuilder({super.key, required this.headerInfoModel});

  @override
  Widget build(BuildContext context) {
    ThemeState themeState = context.read<ThemeCubit>().state;
    AppLocalizations l10n = AppLocalizations.of(context);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = isDark ? Colors.white : const Color(0xFF1B1B1B);
    final onSurfaceMuted = onSurface.withValues(alpha: 0.65);

    Widget surahInfoHeader = Container(
      margin: const EdgeInsets.only(left: 5, top: 5, bottom: 5, right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(roundedRadius),
        color: themeState.primary.withValues(alpha: 0.05),
      ),
      height: 80,
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                height: 80,
                width: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(roundedRadius),
                  image: DecorationImage(
                    image: AssetImage(
                      headerInfoModel.surahInfoModel.revelationPlace ==
                              "madinah"
                          ? "assets/img/madina.jpeg"
                          : "assets/img/makkah.jpg",
                    ),
                  ),
                ),
              ),
              const Gap(7),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          "${headerInfoModel.surahInfoModel.id}. ",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: onSurface,
                          ),
                        ),
                        Text(
                          "surah-icon",
                          style: TextStyle(
                            fontSize: 26,
                            fontFamily: "surah-name-v1",
                            color: onSurface,
                          ),
                        ),
                        const Gap(5),
                        Text(
                          "surah${headerInfoModel.surahInfoModel.id.toString().padLeft(3, '0')}",
                          style: TextStyle(
                            fontSize: 26,
                            fontFamily: "surah-name-v1",
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                    const Gap(4),
                    Text(
                      "${l10n.verseCount} ${headerInfoModel.surahInfoModel.versesCount}",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: onSurfaceMuted,
                      ),
                    ),
                    if (QuranTranslationFunction.isInfoAvailable(
                      context.read<LanguageCubit>().state.locale,
                    ))
                      SizedBox(
                        height: 25,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            shape: const RoundedRectangleBorder(),
                          ),
                          onPressed: () async {
                            final String surahInfo =
                                await QuranTranslationFunction.getInfoOfSurah(
                                  context.read<LanguageCubit>().state.locale,
                                  headerInfoModel.surahInfoModel.id.toString(),
                                );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SurahInfoView(
                                  html: surahInfo,
                                  surahInfoModel:
                                      headerInfoModel.surahInfoModel,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            l10n.moreInfo,
                            style: TextStyle(
                              color: themeState.primary,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: BlocBuilder<PlayerStateCubit, PlayerState>(
              builder: (context, playerState) {
                return BlocBuilder<AyahKeyCubit, AyahKeyManagement>(
                  builder: (context, ayahKeyManagement) {
                    bool isPlaying = playerState.isPlaying;
                    bool isCurrentSurah =
                        int.tryParse(ayahKeyManagement.current.split(":")[0]) ==
                        headerInfoModel.surahInfoModel.id;
                    bool isCurrentPlaying =
                        isPlaying &&
                        isCurrentSurah &&
                        context
                                .read<AudioUiCubit>()
                                .state
                                .isInsideQuranPlayer ==
                            true;
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (!kIsWeb)
                          /* Download Icon Button removed */
                          IconButton(
                            style: IconButton.styleFrom(
                              padding: EdgeInsets.zero,
                              backgroundColor: themeState.primary,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () {
                              bool isPlayList = context
                                  .read<AudioUiCubit>()
                                  .state
                                  .isPlayList;
                              bool isCompleted =
                                  playerState.state ==
                                  just_audio.ProcessingState.completed;

                              if (context
                                      .read<AudioUiCubit>()
                                      .state
                                      .isInsideQuranPlayer ==
                                  false) {
                                String startAyahKey =
                                    headerInfoModel.startAyahKey;
                                String endAyahKey = headerInfoModel.endAyahKey;

                                audioPlaybackService.playPlaylist(
                                  startAyahKey: startAyahKey,
                                  endAyahKey: endAyahKey,
                                  reciterInfoModel: context
                                      .read<SegmentedQuranReciterCubit>()
                                      .state,
                                  isInsideQuran: true,
                                );
                              } else if (isCurrentPlaying &&
                                  isPlayList &&
                                  !isCompleted) {
                                audioPlaybackService.pause();
                              } else if (isCurrentSurah &&
                                  isPlayList &&
                                  !isCompleted) {
                                audioPlaybackService.resume();
                              } else {
                                String startAyahKey =
                                    headerInfoModel.startAyahKey;
                                String endAyahKey = headerInfoModel.endAyahKey;

                                audioPlaybackService.playPlaylist(
                                  startAyahKey: startAyahKey,
                                  endAyahKey: endAyahKey,
                                  reciterInfoModel: context
                                      .read<SegmentedQuranReciterCubit>()
                                      .state,
                                  isInsideQuran: true,
                                );
                              }
                            },
                            icon:
                                (playerState.state ==
                                        just_audio.ProcessingState.loading &&
                                    isCurrentSurah)
                                ? Padding(
                                    padding: const EdgeInsets.all(3.0),
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 4,
                                      backgroundColor: context
                                          .read<ThemeCubit>()
                                          .state
                                          .primaryShade100,
                                    ),
                                  )
                                : Icon(
                                    isCurrentPlaying
                                        ? Icons.pause_rounded
                                        : Icons.play_arrow_rounded,
                                  ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );

    if (!headerInfoModel.surahInfoModel.noBismillah) {
      return Column(
        children: [
          surahInfoHeader,

          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(10),
            child: BlocBuilder<QuranViewCubit, QuranViewState>(
              builder: (context, state) {
                bool isUthmani =
                    state.quranScriptType == QuranScriptType.uthmani ||
                    state.quranScriptType == QuranScriptType.tajweed;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    isUthmani
                        ? "بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ"
                        : "بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ",
                    style: TextStyle(
                      fontFamily: isUthmani ? "QPC_Hafs" : "AlQuranNeov5x1",
                      fontSize: state.fontSize.clamp(20.0, 36.0),
                      height: state.lineHeight,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : const Color(0xFF1B1B1B),
                    ),
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                  ),
                );
              },
            ),
          ),
          const Gap(10),
        ],
      );
    } else {
      return surahInfoHeader;
    }
  }
}
