import "package:al_quran_v3/l10n/app_localizations.dart";
import "package:al_quran_v3/src/core/audio/cubit/audio_ui_cubit.dart";
import "package:al_quran_v3/src/core/audio/cubit/ayah_key_cubit.dart";
import "package:al_quran_v3/src/core/audio/cubit/player_position_cubit.dart";
import "package:al_quran_v3/src/core/audio/cubit/player_state_cubit.dart";
import "package:al_quran_v3/src/core/audio/model/ayahkey_management.dart";
import "package:al_quran_v3/src/resources/quran_resources/meaning_of_surah.dart";
import "package:al_quran_v3/src/screen/settings/cubit/quran_script_view_cubit.dart";
import "package:al_quran_v3/src/widget/quran_script_words/cubit/word_playing_state_cubit.dart";
import "package:flutter/material.dart";
import "package:just_audio/just_audio.dart";

abstract class AudioPlayerUiBridge {
  Duration? get currentPosition;
  Duration? get totalDuration;
  Duration? get bufferedPosition;
  List<String> get ayahList;
  double get playbackSpeed;
  bool get useAudioStream;

  void setCurrentPosition(Duration? position);
  void setTotalDuration(Duration? duration);
  void setBufferPosition(Duration? position);
  void setPlayerState({ProcessingState? processingState, bool? isPlaying});
  void setExpanded(bool isExpanded);
  void setShowUi(bool showUi);
  void setIsPlayList(bool isPlayList);
  void setIsInsideQuran(bool isInsideQuran);
  void setAyahData(AyahKeyManagement ayahData);
  void setCurrentAyahKey(String ayahKey);
  void setWordPlaying(String? wordKey);
  String localizedSurahName(int surahIndex);
  Future<void> showPlayerError(String message);
  Future<void> showOfflineAudioAlert({
    required int missingCount,
    required int totalCount,
  });
}

class BlocAudioPlayerUiBridge implements AudioPlayerUiBridge {
  BlocAudioPlayerUiBridge({
    required BuildContext context,
    required AudioUiCubit audioUiCubit,
    required PlayerPositionCubit playerPositionCubit,
    required PlayerStateCubit playerStateCubit,
    required AyahKeyCubit ayahKeyCubit,
    required QuranViewCubit quranViewCubit,
    required WordPlayingStateCubit wordPlayingStateCubit,
  }) : _context = context,
       _audioUiCubit = audioUiCubit,
       _playerPositionCubit = playerPositionCubit,
       _playerStateCubit = playerStateCubit,
       _ayahKeyCubit = ayahKeyCubit,
       _quranViewCubit = quranViewCubit,
       _wordPlayingStateCubit = wordPlayingStateCubit;

  final BuildContext _context;
  final AudioUiCubit _audioUiCubit;
  final PlayerPositionCubit _playerPositionCubit;
  final PlayerStateCubit _playerStateCubit;
  final AyahKeyCubit _ayahKeyCubit;
  final QuranViewCubit _quranViewCubit;
  final WordPlayingStateCubit _wordPlayingStateCubit;

  @override
  Duration? get currentPosition => _playerPositionCubit.state.currentDuration;

  @override
  Duration? get totalDuration => _playerPositionCubit.state.totalDuration;

  @override
  Duration? get bufferedPosition => _playerPositionCubit.state.bufferDuration;

  @override
  List<String> get ayahList => _ayahKeyCubit.state.ayahList;

  @override
  double get playbackSpeed => _quranViewCubit.state.playbackSpeed;

  @override
  bool get useAudioStream => _quranViewCubit.state.useAudioStream;

  @override
  void setCurrentPosition(Duration? position) {
    _playerPositionCubit.changeCurrentPosition(position);
  }

  @override
  void setTotalDuration(Duration? duration) {
    _playerPositionCubit.changeTotalDuration(duration);
  }

  @override
  void setBufferPosition(Duration? position) {
    _playerPositionCubit.changeBufferPosition(position);
  }

  @override
  void setPlayerState({ProcessingState? processingState, bool? isPlaying}) {
    _playerStateCubit.changeState(
      processingState: processingState,
      isPlaying: isPlaying,
    );
  }

  @override
  void setExpanded(bool isExpanded) {
    _audioUiCubit.expand(isExpanded);
  }

  @override
  void setShowUi(bool showUi) {
    _audioUiCubit.showUI(showUi);
  }

  @override
  void setIsPlayList(bool isPlayList) {
    _audioUiCubit.isPlayList(isPlayList);
  }

  @override
  void setIsInsideQuran(bool isInsideQuran) {
    _audioUiCubit.changeIsInsideQuran(isInsideQuran);
  }

  @override
  void setAyahData(AyahKeyManagement ayahData) {
    _ayahKeyCubit.changeData(ayahData);
  }

  @override
  void setCurrentAyahKey(String ayahKey) {
    _ayahKeyCubit.changeCurrentAyahKey(ayahKey);
  }

  @override
  void setWordPlaying(String? wordKey) {
    _wordPlayingStateCubit.changeState(wordKey);
  }

  @override
  String localizedSurahName(int surahIndex) {
    return getSurahName(_context, surahIndex);
  }

  @override
  Future<void> showPlayerError(String message) {
    return showDialog<void>(
      context: _context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Audio Player Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Ok"),
            ),
          ],
        );
      },
    );
  }

  @override
  Future<void> showOfflineAudioAlert({
    required int missingCount,
    required int totalCount,
  }) {
    final l10n = AppLocalizations.of(_context);
    return showDialog<void>(
      context: _context,
      builder: (dialogContext) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(10),
          title: Text(l10n.audioDownloadAlert(missingCount, totalCount)),
          actions: [
            TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(Icons.close),
              label: Text(l10n.cancel),
            ),
          ],
        );
      },
    );
  }
}
