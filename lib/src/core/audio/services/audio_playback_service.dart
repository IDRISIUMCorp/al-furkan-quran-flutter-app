import "package:al_quran_v3/src/core/audio/model/recitation_info_model.dart";
import "package:al_quran_v3/src/core/audio/player/audio_player_manager.dart";

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
  Future<void> stopPlaybackKeepUi() {
    return AudioPlayerManager.stopPlaybackKeepUi();
  }
}
