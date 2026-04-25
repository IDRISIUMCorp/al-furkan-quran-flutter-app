import "dart:async";
import "dart:developer";
import "dart:io";

import "package:al_furkan/main.dart";
import "package:al_furkan/src/core/audio/model/ayahkey_management.dart";
import "package:al_furkan/src/core/audio/model/recitation_info_model.dart";
import "package:al_furkan/src/core/audio/services/audio_player_ui_bridge.dart";
import "package:al_furkan/src/platform_services.dart";
import "package:al_furkan/src/resources/quran_resources/meta/meta_data_surah.dart";
import "package:al_furkan/src/screen/surah_list_view/model/surah_info_model.dart";
import "package:al_furkan/src/utils/quran_ayahs_function/gen_ayahs_key.dart";
import "package:dio/dio.dart";
import "package:just_audio/just_audio.dart";
import "package:just_audio_background/just_audio_background.dart";
import "package:path/path.dart";
import "package:permission_handler/permission_handler.dart";
import "package:flutter/foundation.dart";

class AudioPlayerManager {
  static bool isListening = false;
  static bool isWordPlaying = false;

  static AudioPlayer audioPlayer = AudioPlayer();
  static CancelToken? _downloadCancelToken;

  /// Callback when playback completes — used by SleepTimer & Repeat
  static void Function()? onPlaybackCompleted;
  /// Callback when sleep timer expires — stops playback
  static void Function()? onSleepTimerExpired;

  static StreamSubscription<Duration>? positionStream;
  static StreamSubscription<PlayerException>? errorStream;
  static StreamSubscription<PlayerEvent>? playerEventStream;
  static StreamSubscription<ProcessingState>? processingStateStream;
  static StreamSubscription<Duration?>? durationStream;
  static StreamSubscription<Duration>? bufferedPositionStream;
  static StreamSubscription<int?>? currentIndexStream;
  static StreamSubscription<PlayerState>? _wordCompletionStream;

  static AudioPlayerUiBridge? _uiBridge;

  static Future<void> _waitForPlaybackCompletion({
    required String debugKey,
  }) async {
    // Guard against stale `completed` from a previous source.
    if (audioPlayer.processingState == ProcessingState.completed) {
      try {
        await audioPlayer.processingStateStream
            .firstWhere((state) => state != ProcessingState.completed)
            .timeout(const Duration(seconds: 1));
      } catch (_) {}
    }

    Duration? duration = audioPlayer.duration;
    if (duration == null) {
      try {
        duration = await audioPlayer.durationStream
            .where((d) => d != null && d.inMilliseconds > 0)
            .cast<Duration>()
            .first
            .timeout(const Duration(milliseconds: 350));
      } catch (_) {}
    }

    final dynamicTimeout = duration == null
        ? const Duration(milliseconds: 900)
        : Duration(
            milliseconds: (duration.inMilliseconds + 180).clamp(450, 950),
          );

    final completedFuture = audioPlayer.playerStateStream.firstWhere(
      (s) =>
          s.processingState == ProcessingState.completed &&
          s.playing == false,
    );

    Future<void>? positionFuture;
    if (duration != null && duration.inMilliseconds > 200) {
      final targetMs =
          (duration.inMilliseconds - 260).clamp(0, duration.inMilliseconds);
      positionFuture = audioPlayer.positionStream.firstWhere(
        (pos) => pos.inMilliseconds >= targetMs,
      );
    }

    try {
      await Future.any(
        <Future<void>>[
          completedFuture,
          ?positionFuture,
        ],
      ).timeout(dynamicTimeout);
    } catch (_) {
      // Treat timeout/stream issues as completion to avoid UI lingering.
      return;
    }
  }

  static void bindUiBridge(AudioPlayerUiBridge? bridge) {
    // Dispose old bridge's tracker to prevent duplicate subscriptions.
    final oldBridge = _uiBridge;
    if (oldBridge is BlocAudioPlayerUiBridge) {
      oldBridge.disposeTracker();
    }
    _uiBridge = bridge;
  }

  static void startListeningAudioPlayerState() {
    if (isListening) {
      return;
    }

    isListening = true;
    final bridge = _uiBridge;

    positionStream = audioPlayer.positionStream.listen((event) {
      if (durationToDecSec(bridge?.currentPosition) !=
          durationToDecSec(event)) {
        bridge?.setCurrentPosition(event);
      }
    });

    errorStream = audioPlayer.errorStream.listen((event) {
      unawaited(
        bridge?.showPlayerError(event.message ?? "Something went wrong") ??
            Future<void>.value(),
      );
    });

    playerEventStream = audioPlayer.playerEventStream.listen((event) {
      bridge?.setPlayerState(isPlaying: event.playing);
    });

    processingStateStream = audioPlayer.processingStateStream.listen((
      event,
    ) async {
      if (event == ProcessingState.completed) {
        // Notify sleep timer (end-of-surah mode)
        onPlaybackCompleted?.call();

        await audioPlayer.pause();
        // Only reset to beginning in single-ayah mode (not playlist)
        if (!(_uiBridge?.isPlayListState ?? false)) {
          await audioPlayer.seek(Duration.zero, index: 0);
        }
        bridge?.setExpanded(false);
        // Keep UI visible so user can replay — don't hide
      }

      bridge?.setPlayerState(processingState: event);
      if (event == ProcessingState.completed) {
        bridge?.setCurrentPosition(Duration.zero);
        bridge?.setPlayerState(isPlaying: false);
      }
    });

    durationStream = audioPlayer.durationStream.listen((event) {
      if (durationToDecSec(bridge?.totalDuration) != durationToDecSec(event)) {
        bridge?.setTotalDuration(event);
      }
    });

    bufferedPositionStream = audioPlayer.bufferedPositionStream.listen((event) {
      if (durationToDecSec(bridge?.bufferedPosition) !=
          durationToDecSec(event)) {
        bridge?.setBufferPosition(event);
      }
    });

    currentIndexStream = audioPlayer.currentIndexStream.listen((event) {
      if (event == null) {
        return;
      }

      try {
        final sequence = audioPlayer.sequenceState.sequence;
        final tag = event >= 0 && event < sequence.length
            ? sequence[event].tag
            : null;
        if (tag is MediaItem && tag.id.isNotEmpty) {
          bridge?.setCurrentAyahKey(tag.id);
          return;
        }
      } catch (_) {}

      final ayahList = bridge?.ayahList ?? const <String>[];
      if (event >= 0 && event < ayahList.length) {
        bridge?.setCurrentAyahKey(ayahList[event]);
      }
    });
  }

  static Future<void> stopListeningAudioPlayerState() async {
    log(isListening.toString());
    if (!isListening) {
      return;
    }

    isListening = false;
    await positionStream?.cancel();
    await errorStream?.cancel();
    await playerEventStream?.cancel();
    await processingStateStream?.cancel();
    await durationStream?.cancel();
    await bufferedPositionStream?.cancel();
    await currentIndexStream?.cancel();

    _uiBridge?.setExpanded(false);
    _uiBridge?.setShowUi(false);
    _uiBridge?.setIsPlayList(false);
    _uiBridge?.setIsInsideQuran(false);
    _uiBridge?.setCurrentPosition(Duration.zero);
    _uiBridge?.setBufferPosition(Duration.zero);
    _uiBridge?.setTotalDuration(Duration.zero);
    _uiBridge?.setPlayerState(isPlaying: false);

    await audioPlayer.stop();
    await audioPlayer.clearAudioSources();
    await audioPlayer.dispose();
    audioPlayer = AudioPlayer();
  }

  static Future<void> stopPlaybackKeepUi() async {
    await positionStream?.cancel();
    await errorStream?.cancel();
    await playerEventStream?.cancel();
    await processingStateStream?.cancel();
    await durationStream?.cancel();
    await bufferedPositionStream?.cancel();
    await currentIndexStream?.cancel();
    await _wordCompletionStream?.cancel();
    _wordCompletionStream = null;

    isListening = false;

    try {
      await audioPlayer.stop();
      await audioPlayer.clearAudioSources();
    } catch (_) {}

    _uiBridge?.setCurrentPosition(Duration.zero);
    _uiBridge?.setBufferPosition(Duration.zero);
    _uiBridge?.setTotalDuration(Duration.zero);
    _uiBridge?.setPlayerState(isPlaying: false);
    _uiBridge?.setWordPlaying(null);
    _uiBridge?.setExpanded(false);

    try {
      await audioPlayer.dispose();
    } catch (_) {}
    audioPlayer = AudioPlayer();
  }

  static Future<void> playWordsSequence(
    List<String> wordKeys, {
    void Function(int index, String wordKey)? onWordStart,
  }) async {
    if (wordKeys.isEmpty) {
      return;
    }

    if (isWordPlaying) {
      try {
        await stopPlaybackKeepUi();
      } catch (_) {}
      isWordPlaying = false;
      _uiBridge?.setWordPlaying(null);
    }

    isWordPlaying = true;

    try {
      await stopListeningAudioPlayerState();
      isListening = false;

      for (int i = 0; i < wordKeys.length; i++) {
        final wordKey = wordKeys[i];
        onWordStart?.call(i, wordKey);
        _uiBridge?.setWordPlaying(wordKey);

        final url =
            "https://audio.qurancdn.com/wbw/${wordKeyToAudioOfWordID(wordKey)}.mp3";
        final audioSource = AudioSource.uri(
          Uri.parse(url),
          tag: MediaItem(id: wordKey, title: wordKey),
        );

        await audioPlayer.setAudioSource(audioSource);
        await audioPlayer.play();

        await _waitForPlaybackCompletion(debugKey: wordKey);

        // Clear UI highlight immediately once the clip is considered finished.
        _uiBridge?.setWordPlaying(null);
        unawaited(audioPlayer.stop());
        unawaited(audioPlayer.seek(Duration.zero));
      }
    } catch (error, stackTrace) {
      log(
        "playWordsSequence failed: $error\n$stackTrace",
        name: "AudioPlayerManager.playWordsSequence",
      );
      try {
        await audioPlayer.stop();
      } catch (_) {}
    } finally {
      isWordPlaying = false;
      _uiBridge?.setWordPlaying(null);
    }
  }

  static void cancelDownload() {
    _downloadCancelToken?.cancel();
  }

  static Future<void> downloadSurah({
    required SurahInfoModel surahInfoModel,
    required ReciterInfoModel reciterInfoModel,
    required dynamic audioDownloadCubit,
  }) async {}

  static Future<int> getFilesCount(
    ReciterInfoModel reciter,
    SurahInfoModel surah,
  ) async {
    final path = getExpectedSurahDirectoryLocation(
      surahInfoModel: surah,
      reciterInfoModel: reciter,
    );
    if (path == null) {
      return 0;
    }

    final dir = Directory(path);
    if (await dir.exists()) {
      return dir.listSync().length;
    }
    return 0;
  }

  static String? getExpectedAudioFileLocation({
    required SurahInfoModel surahInfoModel,
    required int ayahNumber,
    required ReciterInfoModel reciterInfoModel,
  }) {
    return applicationDataPath == null
        ? null
        : join(
            applicationDataPath!,
            "recitations",
            reciterInfoModel.name,
            reciterInfoModel.style,
            surahInfoModel.id.toString().padLeft(3, "0"),
            "${ayahNumber.toString().padLeft(3, "0")}.mp3",
          );
  }

  static String? getExpectedSurahDirectoryLocation({
    required SurahInfoModel surahInfoModel,
    required ReciterInfoModel reciterInfoModel,
  }) {
    return applicationDataPath == null
        ? null
        : join(
            applicationDataPath!,
            "recitations",
            reciterInfoModel.name,
            reciterInfoModel.style,
            surahInfoModel.id.toString().padLeft(3, "0"),
          );
  }

  static Future<String?> getDownloadedPathOfSurah({
    required SurahInfoModel surahInfoModel,
    required int ayahNumber,
    required ReciterInfoModel reciterInfoModel,
  }) async {
    final expectedPath = getExpectedAudioFileLocation(
      surahInfoModel: surahInfoModel,
      ayahNumber: ayahNumber,
      reciterInfoModel: reciterInfoModel,
    );
    if (expectedPath != null && await File(expectedPath).exists()) {
      return expectedPath;
    }
    return null;
  }

  static Future<void> playSingleAyah({
    required String ayahKey,
    required ReciterInfoModel reciterInfoModel,
    required bool isInsideQuran,
    bool instantPlay = true,
  }) async {
    if (platformOwn == PlatformOwn.isIos ||
        platformOwn == PlatformOwn.isAndroid) {
      Permission.notification.request();
    }
    startListeningAudioPlayerState();
    if (audioPlayer.processingState == ProcessingState.loading) {
      await audioPlayer.clearAudioSources();
    }

    if (await shouldContinuePlaying(reciterInfoModel, ayahKey) == false) {
      return;
    }

    final playbackSpeed = _uiBridge?.playbackSpeed ?? 1.0;
    final surahInfoModel = SurahInfoModel.fromMap(
      metaDataSurah[ayahKey.split(":").first]!,
    );

    AudioSource audioSource;
    try {
      audioSource = await getAudioSourceFromAyahKey(
        ayahKey,
        surahInfoModel,
        reciterInfoModel,
      );
    } catch (e) {
      debugPrint("❌ Failed to get audio source for $ayahKey: $e");
      unawaited(_uiBridge?.showPlayerError("فشل تحميل الصوت لهذه الآية. تأكد من اتصال الإنترنت أو جرّب قارئ آخر.") ?? Future<void>.value());
      return;
    }

    await audioPlayer.stop();
    await audioPlayer.clearAudioSources();

    _uiBridge?.setShowUi(true);
    _uiBridge?.setIsPlayList(false);
    _uiBridge?.setIsInsideQuran(isInsideQuran);
    _uiBridge?.setAyahData(
      AyahKeyManagement(
        start: ayahKey,
        end: ayahKey,
        current: ayahKey,
        ayahList: [ayahKey],
      ),
    );

    try {
      await audioPlayer.setAudioSource(audioSource, initialIndex: 0);
      await audioPlayer.setSpeed(playbackSpeed);
      if (instantPlay) {
        await audioPlayer.play();
      }
    } catch (e) {
      debugPrint("❌ Audio playback error for $ayahKey: $e");
      unawaited(_uiBridge?.showPlayerError("فشل تشغيل الصوت. تأكد من اتصال الإنترنت أو جرّب قارئ آخر.") ?? Future<void>.value());
    }
  }

  static Future<bool> shouldContinuePlaying(
    ReciterInfoModel reciterInfoModel,
    String startAyahKey,
  ) async {
    log("Checking existing Download");
    final useAudioStream = _uiBridge?.useAudioStream ?? true;
    if (useAudioStream) {
      return true;
    }

    final surahInfoModel = SurahInfoModel.fromMap(
      Map<String, dynamic>.from(metaDataSurah[startAyahKey.split(":").first]!),
    );
    final count = await getFilesCount(reciterInfoModel, surahInfoModel);
    if (count >= surahInfoModel.versesCount) {
      log(
        "Already $count/${surahInfoModel.versesCount} ayahs downloaded",
        name: "Audio",
      );
      return true;
    }

    log("Need to download some ayahs");
    await (_uiBridge?.showOfflineAudioAlert(
          missingCount: surahInfoModel.versesCount - count,
          totalCount: surahInfoModel.versesCount,
        ) ??
        Future<void>.value());
    return false;
  }

  static Future<void> playMultipleAyahAsPlaylist({
    required String startAyahKey,
    required String endAyahKey,
    required bool isInsideQuran,
    required ReciterInfoModel reciterInfoModel,
    int initialIndex = 0,
    bool instantPlay = true,
  }) async {
    if (platformOwn == PlatformOwn.isIos ||
        platformOwn == PlatformOwn.isAndroid) {
      Permission.notification.request();
    }
    startListeningAudioPlayerState();
    if (audioPlayer.processingState == ProcessingState.loading) {
      await audioPlayer.clearAudioSources();
    }

    if (await shouldContinuePlaying(reciterInfoModel, startAyahKey) == false) {
      return;
    }

    final playbackSpeed = _uiBridge?.playbackSpeed ?? 1.0;
    List ayahList = getListOfAyahKey(
      startAyahKey: startAyahKey,
      endAyahKey: endAyahKey,
    );

    ayahList.removeWhere((element) => element.runtimeType == int);
    ayahList = List<String>.from(ayahList);

    final listOfAudioSource = <AudioSource>[];
    for (final ayahKey in ayahList) {
      final surahInfoModel = SurahInfoModel.fromMap(
        metaDataSurah[ayahKey.split(":").first]!,
      );
      listOfAudioSource.add(
        await getAudioSourceFromAyahKey(
          ayahKey,
          surahInfoModel,
          reciterInfoModel,
        ),
      );
    }

    await audioPlayer.stop();
    await audioPlayer.clearAudioSources();

    _uiBridge?.setShowUi(true);
    _uiBridge?.setIsPlayList(true);
    _uiBridge?.setIsInsideQuran(isInsideQuran);
    _uiBridge?.setAyahData(
      AyahKeyManagement(
        start: ayahList.first,
        end: ayahList.last,
        current: ayahList[initialIndex],
        ayahList: ayahList.cast<String>(),
      ),
    );

    try {
      await audioPlayer.setAudioSources(
        listOfAudioSource,
        initialIndex: initialIndex,
        shuffleOrder: DefaultShuffleOrder(),
      );

      await audioPlayer.setSpeed(playbackSpeed);
      if (instantPlay) {
        await audioPlayer.play();
      }
    } catch (e) {
      debugPrint("❌ Playlist playback error: $e");
      unawaited(_uiBridge?.showPlayerError("فشل تشغيل القائمة. تأكد من اتصال الإنترنت أو جرّب قارئ آخر.") ?? Future<void>.value());
    }
  }

  static Future<void> playWord(String wordKey) async {
    if (isWordPlaying) {
      try {
        await stopPlaybackKeepUi();
      } catch (_) {}
      isWordPlaying = false;
      _uiBridge?.setWordPlaying(null);
    }

    if (platformOwn == PlatformOwn.isIos ||
        platformOwn == PlatformOwn.isAndroid) {
      Permission.notification.request();
    }

    isWordPlaying = true;

    try {
      _uiBridge?.setWordPlaying(wordKey);

      final url =
          "https://audio.qurancdn.com/wbw/${wordKeyToAudioOfWordID(wordKey)}.mp3";
      final audioSource = AudioSource.uri(
        Uri.parse(url),
        tag: MediaItem(id: wordKey, title: wordKey),
      );

      await stopListeningAudioPlayerState();
      isListening = false;

      await audioPlayer.setAudioSource(audioSource);
      await audioPlayer.play();

      final sw = Stopwatch()..start();
      await _waitForPlaybackCompletion(debugKey: wordKey);
      sw.stop();
      if (kDebugMode) {
        log(
          "[WordAudio] wait done key=$wordKey ms=${sw.elapsedMilliseconds} durationMs=${audioPlayer.duration?.inMilliseconds}",
          name: "AudioPlayerManager",
        );
      }

      // Clear UI highlight immediately once the clip is considered finished.
      _uiBridge?.setWordPlaying(null);

      unawaited(audioPlayer.stop());
      unawaited(audioPlayer.seek(Duration.zero));
    } catch (error, stackTrace) {
      log(
        "playWord failed: $error\n$stackTrace",
        name: "AudioPlayerManager.playWord",
      );
      try {
        await audioPlayer.stop();
      } catch (_) {}
    } finally {
      isWordPlaying = false;
      _uiBridge?.setWordPlaying(null);
    }
  }

  static String wordKeyToAudioOfWordID(String wordKey) {
    final splitString = wordKey.split(":");
    final surahNumber = splitString[0];
    final ayahNumber = splitString[1];
    final wordNumber = splitString[2];
    return "${surahNumber.padLeft(3, "0")}_${ayahNumber.padLeft(3, "0")}_${wordNumber.padLeft(3, "0")}";
  }

  static Future<AudioSource> getAudioSourceFromAyahKey(
    String ayahKey,
    SurahInfoModel surahInfoModel,
    ReciterInfoModel reciter,
  ) async {
    final audioFilePath = await getDownloadedPathOfSurah(
      surahInfoModel: surahInfoModel,
      ayahNumber: int.parse(ayahKey.split(":").last),
      reciterInfoModel: reciter,
    );
    final surahTitle =
        _uiBridge?.localizedSurahName(surahInfoModel.id) ??
        "Surah ${surahInfoModel.id}";

    final artUri = reciter.img != null ? Uri.tryParse(reciter.img!) : null;

    if (audioFilePath != null) {
      return (platformOwn == PlatformOwn.isLinux ||
              platformOwn == PlatformOwn.isWindows)
          ? AudioSource.file(audioFilePath)
          : AudioSource.file(
              audioFilePath,
              tag: MediaItem(
                id: ayahKey,
                album: reciter.name,
                title: surahTitle,
                artUri: artUri,
              ),
            );
    }

    return AudioSource.uri(
      Uri.parse(getUrlOfAudioFromAyahKey(ayahKey, reciter)),
      tag: MediaItem(
        id: ayahKey,
        album: reciter.name,
        title: surahTitle,
        artUri: artUri,
      ),
    );
  }

  static String getUrlOfAudioFromAyahKey(
    String ayahKey,
    ReciterInfoModel reciter,
  ) {
    return "${reciter.link}/${ayahKeyToAudioAyahID(ayahKey)}.mp3";
  }

  static String ayahKeyToAudioAyahID(String ayahKey) {
    final sections = ayahKey.split(":");
    return "${sections[0].padLeft(3, '0')}${sections[1].padLeft(3, '0')}";
  }

  static int? durationToDecSec(Duration? duration) {
    if (duration == null) {
      return null;
    }
    return duration.inMilliseconds ~/ 100;
  }
}
