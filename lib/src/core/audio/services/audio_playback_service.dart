import "package:al_quran_v3/src/core/audio/model/recitation_info_model.dart";
import "package:al_quran_v3/src/core/audio/player/audio_player_manager.dart";

abstract class AudioPlaybackService {
  Future<void> playSingleAyah({
    required String ayahKey,
    required ReciterInfoModel reciterInfoModel,
    required bool isInsideQuran,
  });

  Future<void> playPlaylist({
    required String startAyahKey,
    required String endAyahKey,
    required bool isInsideQuran,
    required ReciterInfoModel reciterInfoModel,
  });

  Future<void> stopPlaybackKeepUi();
}

class LocalAudioPlaybackService implements AudioPlaybackService {
  @override
  Future<void> playSingleAyah({
    required String ayahKey,
    required ReciterInfoModel reciterInfoModel,
    required bool isInsideQuran,
  }) {
    return AudioPlayerManager.playSingleAyah(
      ayahKey: ayahKey,
      reciterInfoModel: reciterInfoModel,
      isInsideQuran: isInsideQuran,
    );
  }

  @override
  Future<void> playPlaylist({
    required String startAyahKey,
    required String endAyahKey,
    required bool isInsideQuran,
    required ReciterInfoModel reciterInfoModel,
  }) {
    return AudioPlayerManager.playMultipleAyahAsPlaylist(
      startAyahKey: startAyahKey,
      endAyahKey: endAyahKey,
      isInsideQuran: isInsideQuran,
      reciterInfoModel: reciterInfoModel,
    );
  }

  @override
  Future<void> stopPlaybackKeepUi() {
    return AudioPlayerManager.stopPlaybackKeepUi();
  }
}
