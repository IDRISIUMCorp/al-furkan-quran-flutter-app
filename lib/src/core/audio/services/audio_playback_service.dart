import "package:al_furkan/src/core/audio/model/recitation_info_model.dart";
import "package:al_furkan/src/core/audio/player/audio_player_manager.dart";
import "package:just_audio/just_audio.dart";

abstract class AudioPlaybackService {
  Future<void> playSingleAyah({
    required String ayahKey,
    required ReciterInfoModel reciterInfoModel,
    required bool isInsideQuran,
    bool instantPlay = true,
  });

  Future<void> playPlaylist({
    required String startAyahKey,
    required String endAyahKey,
    required bool isInsideQuran,
    required ReciterInfoModel reciterInfoModel,
    int initialIndex = 0,
    bool instantPlay = true,
  });

  Future<void> playWord(String wordKey);
  Future<void> playWordsSequence(
    List<String> wordKeys, {
    void Function(int index, String wordKey)? onWordStart,
  });

  bool get isPlaying;
  bool get hasSource;
  int get sourceCount;
  Duration get currentPosition;
  Duration? get totalDuration;
  ProcessingState get processingState;
  LoopMode get loopMode;

  Future<void> pause();
  Future<void> resume();
  Future<void> seek(Duration position, {int? index});
  Future<void> seekToPrevious();
  Future<void> seekToNext();
  Future<void> setLoopMode(LoopMode loopMode);
  Future<void> stopPlaybackKeepUi();
}

class LocalAudioPlaybackService implements AudioPlaybackService {
  @override
  Future<void> playSingleAyah({
    required String ayahKey,
    required ReciterInfoModel reciterInfoModel,
    required bool isInsideQuran,
    bool instantPlay = true,
  }) {
    return AudioPlayerManager.playSingleAyah(
      ayahKey: ayahKey,
      reciterInfoModel: reciterInfoModel,
      isInsideQuran: isInsideQuran,
      instantPlay: instantPlay,
    );
  }

  @override
  Future<void> playPlaylist({
    required String startAyahKey,
    required String endAyahKey,
    required bool isInsideQuran,
    required ReciterInfoModel reciterInfoModel,
    int initialIndex = 0,
    bool instantPlay = true,
  }) {
    return AudioPlayerManager.playMultipleAyahAsPlaylist(
      startAyahKey: startAyahKey,
      endAyahKey: endAyahKey,
      isInsideQuran: isInsideQuran,
      reciterInfoModel: reciterInfoModel,
      initialIndex: initialIndex,
      instantPlay: instantPlay,
    );
  }

  @override
  Future<void> playWord(String wordKey) {
    return AudioPlayerManager.playWord(wordKey);
  }

  @override
  Future<void> playWordsSequence(
    List<String> wordKeys, {
    void Function(int index, String wordKey)? onWordStart,
  }) {
    return AudioPlayerManager.playWordsSequence(
      wordKeys,
      onWordStart: onWordStart,
    );
  }

  @override
  bool get isPlaying => AudioPlayerManager.audioPlayer.playing;

  @override
  bool get hasSource => AudioPlayerManager.audioPlayer.audioSource != null;

  @override
  int get sourceCount => AudioPlayerManager.audioPlayer.audioSources.length;

  @override
  Duration get currentPosition => AudioPlayerManager.audioPlayer.position;

  @override
  Duration? get totalDuration => AudioPlayerManager.audioPlayer.duration;

  @override
  ProcessingState get processingState =>
      AudioPlayerManager.audioPlayer.processingState;

  @override
  LoopMode get loopMode => AudioPlayerManager.audioPlayer.loopMode;

  @override
  Future<void> pause() {
    return AudioPlayerManager.audioPlayer.pause();
  }

  @override
  Future<void> resume() {
    return AudioPlayerManager.audioPlayer.play();
  }

  @override
  Future<void> seek(Duration position, {int? index}) {
    return AudioPlayerManager.audioPlayer.seek(position, index: index);
  }

  @override
  Future<void> seekToPrevious() {
    return AudioPlayerManager.audioPlayer.seekToPrevious();
  }

  @override
  Future<void> seekToNext() {
    return AudioPlayerManager.audioPlayer.seekToNext();
  }

  @override
  Future<void> setLoopMode(LoopMode loopMode) {
    return AudioPlayerManager.audioPlayer.setLoopMode(loopMode);
  }

  @override
  Future<void> stopPlaybackKeepUi() {
    return AudioPlayerManager.stopPlaybackKeepUi();
  }
}
