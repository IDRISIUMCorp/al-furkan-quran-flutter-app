import "package:al_furkan/l10n/app_localizations.dart";
import "package:al_furkan/src/core/audio/cubit/segmented_quran_reciter_cubit.dart";
import "package:al_furkan/src/core/audio/model/ayahkey_management.dart";
import "package:al_furkan/src/core/audio/model/recitation_info_model.dart";
import "package:al_furkan/src/core/audio/services/audio_playback_service_access.dart";
import "package:al_furkan/src/theme/controller/theme_cubit.dart";
import "package:al_furkan/src/theme/values/values.dart";
import "package:al_furkan/src/widget/audio/reciter_overview.dart";
import "package:al_furkan/src/widget/theme/theme_icon_button.dart";
import "package:flutter/material.dart";
import "package:flutter_animate/flutter_animate.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:fluttertoast/fluttertoast.dart";
import "package:gap/gap.dart";

// import "../../../widget/preview_quran_script/ayah_preview_widget.dart";
import "../../settings/cubit/quran_script_view_cubit.dart";
import "../../settings/cubit/quran_script_view_state.dart";

class QuranScriptSettings extends StatelessWidget {
  final bool asPage;

  const QuranScriptSettings({super.key, this.asPage = false});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations appLocalizations = AppLocalizations.of(context);

    final Widget bodyWidget = BlocBuilder<QuranViewCubit, QuranViewState>(
      builder: (context, quranViewState) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(10),
            BlocBuilder<QuranViewCubit, QuranViewState>(
              builder: (context, quranViewState) {
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(appLocalizations.scrollWithRecitation),
                  subtitle: Text(appLocalizations.scrollWithRecitationDesc),
                  thumbIcon: WidgetStateProperty.resolveWith<Icon?>((
                    Set<WidgetState> states,
                  ) {
                    return Icon(
                      states.contains(WidgetState.selected)
                          ? Icons.done_rounded
                          : Icons.close_rounded,
                    );
                  }),

                  value: quranViewState.scrollWithRecitation,
                  onChanged: (value) async {
                    final didUpdate = await context
                        .read<QuranViewCubit>()
                        .setViewOptions(scrollWithRecitation: value);
                    if (!didUpdate && context.mounted) {
                      Fluttertoast.showToast(
                        msg:
                            appLocalizations.quranTranslationAyahOneMustEnabled,
                      );
                    }
                  },
                );
              },
            ),
            const Gap(10),
          ],
        );
      },
    );

    return asPage
        ? Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text(appLocalizations.quranScriptSettings),
              actions: [themeIconButton(context)],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 10,
                right: 10,
                top: 10,
                bottom: 60,
              ),
              child: SafeArea(child: bodyWidget),
            ),
          )
        : bodyWidget;
  }

  Widget buildReciterOverViewWidget(
    BuildContext context,
    ReciterInfoModel reciter,
    AyahKeyManagement ayahState,
  ) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return BlocBuilder<SegmentedQuranReciterCubit, ReciterInfoModel>(
      builder: (context, state) {
        final Widget toReturn = getReciterWidget(
          context: context,
          audioTabScreenState: reciter,
          ayahKeyState: ayahState,
          isWordByWord: true,
          onReciterChanged: (reciterInfoModel) async {
            Navigator.pop(context);
            final bool isSuccess = await context
                .read<SegmentedQuranReciterCubit>()
                .changeReciter(context, reciterInfoModel);

            if (!isSuccess) {
              Fluttertoast.showToast(msg: l10n.unableToDownloadResources);
              return;
            } else {
              Fluttertoast.showToast(msg: l10n.success);
            }

            if (audioPlaybackService.isPlaying) {
              if (audioPlaybackService.sourceCount > 1) {
                await audioPlaybackService.playPlaylist(
                  startAyahKey: ayahState.start,
                  endAyahKey: ayahState.end,
                  isInsideQuran: true,
                  reciterInfoModel: reciterInfoModel,
                );
              } else {
                audioPlaybackService.playSingleAyah(
                  ayahKey: ayahState.current,
                  reciterInfoModel: reciterInfoModel,
                  isInsideQuran: true,
                );
              }
            }
          },
        );
        if (state.isDownloading) {
          return Container(
                decoration: BoxDecoration(
                  color: context.read<ThemeCubit>().state.primaryShade300,
                  borderRadius: BorderRadius.circular(roundedRadius),
                ),
                child: toReturn,
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1200.ms, color: const Color(0x80000000))
              .animate()
              .fadeIn(duration: 1200.ms, curve: Curves.easeOutQuad);
        }
        return toReturn;
      },
    );
  }
}
