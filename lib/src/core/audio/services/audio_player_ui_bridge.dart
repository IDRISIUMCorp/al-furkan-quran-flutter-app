import "package:al_furkan/l10n/app_localizations.dart";
import "package:al_furkan/main.dart" show navigatorKey;
import "package:al_furkan/src/core/audio/cubit/audio_ui_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/ayah_key_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/player_position_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/player_state_cubit.dart";
import "package:al_furkan/src/core/audio/model/ayahkey_management.dart";
import "package:al_furkan/src/resources/quran_resources/meaning_of_surah.dart";
import "package:al_furkan/src/screen/quran_script_view/cubit/ayah_to_highlight.dart";
import "package:al_furkan/src/screen/settings/cubit/quran_script_view_cubit.dart";
import "package:al_furkan/src/widget/quran_script_words/cubit/word_playing_state_cubit.dart";
import "package:al_furkan/src/core/audio/cubit/segmented_quran_reciter_cubit.dart";
import "package:al_furkan/src/core/audio/services/idrisium_audio_tracker.dart";
import "package:flutter/material.dart";
import "package:just_audio/just_audio.dart";

abstract class AudioPlayerUiBridge {
  Duration? get currentPosition;
  Duration? get totalDuration;
  Duration? get bufferedPosition;
  List<String> get ayahList;
  double get playbackSpeed;
  bool get useAudioStream;
  bool get isPlayListState;

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
    required AudioAyahHighlightCubit highlightCubit,
    required SegmentedQuranReciterCubit reciterCubit,
    required AyahToHighlight ayahToHighlight,
  }) : _context = context,
       _audioUiCubit = audioUiCubit,
       _playerPositionCubit = playerPositionCubit,
       _playerStateCubit = playerStateCubit,
       _ayahKeyCubit = ayahKeyCubit,
       _quranViewCubit = quranViewCubit,
       _wordPlayingStateCubit = wordPlayingStateCubit,
       _highlightCubit = highlightCubit,
       _reciterCubit = reciterCubit,
       _ayahToHighlight = ayahToHighlight {
    _tracker = IdrisiumAudioTracker(
      positionCubit: _playerPositionCubit,
      stateCubit: _playerStateCubit,
      ayahCubit: _ayahKeyCubit,
      reciterCubit: _reciterCubit,
      highlightCubit: _highlightCubit,
      onPlaybackStopped: () {
        _ayahToHighlight.changeAyah(null);
      },
    );
  }

  final BuildContext _context;
  final AudioUiCubit _audioUiCubit;
  final PlayerPositionCubit _playerPositionCubit;
  final PlayerStateCubit _playerStateCubit;
  final AyahKeyCubit _ayahKeyCubit;
  final QuranViewCubit _quranViewCubit;
  final WordPlayingStateCubit _wordPlayingStateCubit;
  final AudioAyahHighlightCubit _highlightCubit;
  final SegmentedQuranReciterCubit _reciterCubit;
  final AyahToHighlight _ayahToHighlight;
  late IdrisiumAudioTracker _tracker;

  /// Dispose the tracker to cancel all stream subscriptions.
  /// Called by [AudioPlayerManager.bindUiBridge] when replacing the bridge.
  void disposeTracker() {
    _tracker.dispose();
  }

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
  bool get isPlayListState => _audioUiCubit.state.isPlayList;

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
    final navContext = navigatorKey.currentContext ?? _context;
    if (!navContext.mounted) return Future.value();
    return showDialog<void>(
      context: navContext,
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
    final navContext = navigatorKey.currentContext ?? _context;
    if (!navContext.mounted) return Future.value();
    final l10n = AppLocalizations.of(navContext);
    return showDialog<void>(
      context: navContext,
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
