import "package:al_furkan/src/core/audio/cubit/audio_ui_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/segmented_quran_reciter_cubit.dart";
import "package:al_furkan/src/core/audio/model/audio_controller_ui.dart";
import "package:al_furkan/src/core/audio/model/ayahkey_management.dart";
import "package:al_furkan/src/core/audio/model/recitation_info_model.dart";
import "package:al_furkan/src/theme/controller/theme_cubit.dart";
import "package:al_furkan/src/widget/audio/reciter_overview.dart";
import "package:fluentui_system_icons/fluentui_system_icons.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

Widget getReciterViewWidget(
  BuildContext context,
  AyahKeyManagement ayahKeyState,
  int currentIndex, {
  bool showSettingsIconButton = true,
  bool showDownloadIconButton = kIsWeb ? false : true,
}) {
  return Stack(
    children: [
      BlocBuilder<AudioUiCubit, AudioControllerUiState>(
        builder: (context, audioUIState) {
          return BlocBuilder<SegmentedQuranReciterCubit, ReciterInfoModel>(
            builder: (context, quranInsideReciter) {
              return getReciterWidget(
                context: context,
                audioTabScreenState: quranInsideReciter,
                ayahKeyState: ayahKeyState,
                currentIndex: currentIndex,
              );
            },
          );
        },
      ),
      if (showDownloadIconButton || showSettingsIconButton)
        Align(
          alignment: Alignment.topRight,
          child: Column(
            children: [
              if (showSettingsIconButton)
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? context.read<ThemeCubit>().state.primary.withValues(alpha: 0.15)
                        : context.read<ThemeCubit>().state.primaryShade100,
                  ),
                  onPressed: () {
                    // Removed settings route
                  },
                  icon: const Icon(FluentIcons.settings_24_filled),
                ),
              if (showDownloadIconButton)
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                        ? context.read<ThemeCubit>().state.primary.withValues(alpha: 0.15)
                        : context.read<ThemeCubit>().state.primaryShade100,
                  ),
                  onPressed: () {
                    // Removed download route
                  },
                  icon: const Icon(FluentIcons.arrow_download_24_filled),
                ),
            ],
          ),
        ),
    ],
  );
}
