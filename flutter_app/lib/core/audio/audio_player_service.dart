import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'silent_wav_generator.dart';

/// Tag attached to each item in the AudioSource playlist for precise progress tracking
class AyahPlaybackTag {
  final int surah;
  final int ayah;
  final int loopIndex;
  final int totalLoops;
  final bool isSilence;
  final bool isGroupPhase;
  final int groupLoopIndex;
  final int totalGroupLoops;

  const AyahPlaybackTag({
    required this.surah,
    required this.ayah,
    required this.loopIndex,
    required this.totalLoops,
    required this.isSilence,
    this.isGroupPhase = false,
    this.groupLoopIndex = 1,
    this.totalGroupLoops = 1,
  });

  @override
  String toString() {
    return 'Tag(surah: $surah, ayah: $ayah, loop: $loopIndex/$totalLoops, silence: $isSilence, group: $isGroupPhase)';
  }
}

/// Repetition configuration for Zen Hifz memorization session
class HifzVerseConfig {
  final int surah;
  final int startAyah;
  final int endAyah;
  final int singleRepeatCount; // N: repeats per verse
  final int linkGroupRepeat;   // M: repeats for entire group
  final int pauseDelaySeconds; // X: silence duration for user to recite from memory
  final String reciterCdnPattern;
  final String fallbackCdnPattern;

  HifzVerseConfig({
    required this.surah,
    required this.startAyah,
    required this.endAyah,
    this.singleRepeatCount = 10,
    this.linkGroupRepeat = 3,
    this.pauseDelaySeconds = 4,
    this.reciterCdnPattern =
        'https://everyayah.com/data/Husary_Muallim_128kbps/{surah:03d}{ayah:03d}.mp3',
    this.fallbackCdnPattern =
        'https://everyayah.com/data/Alafasy_128kbps/{surah:03d}{ayah:03d}.mp3',
  });
}

enum HifzPlaybackStatus {
  idle,
  preparing,
  playing,
  paused,
  delaying,
  completed,
  error,
}

class HifzSessionState {
  final HifzPlaybackStatus status;
  final int currentSurah;
  final int currentAyah;
  final int currentLoop;
  final int totalLoops;
  final bool isGroupPhase;
  final int groupLoop;
  final int totalGroupLoops;
  final bool isDelaying;
  final int delayRemainingSeconds;
  final String? errorMessage;

  const HifzSessionState({
    this.status = HifzPlaybackStatus.idle,
    this.currentSurah = 1,
    this.currentAyah = 1,
    this.currentLoop = 1,
    this.totalLoops = 10,
    this.isGroupPhase = false,
    this.groupLoop = 1,
    this.totalGroupLoops = 1,
    this.isDelaying = false,
    this.delayRemainingSeconds = 0,
    this.errorMessage,
  });

  bool get isPlaying =>
      status == HifzPlaybackStatus.playing || status == HifzPlaybackStatus.delaying;
  bool get isPaused => status == HifzPlaybackStatus.paused;
  bool get isIdle => status == HifzPlaybackStatus.idle;

  HifzSessionState copyWith({
    HifzPlaybackStatus? status,
    int? currentSurah,
    int? currentAyah,
    int? currentLoop,
    int? totalLoops,
    bool? isGroupPhase,
    int? groupLoop,
    int? totalGroupLoops,
    bool? isDelaying,
    int? delayRemainingSeconds,
    String? errorMessage,
  }) {
    return HifzSessionState(
      status: status ?? this.status,
      currentSurah: currentSurah ?? this.currentSurah,
      currentAyah: currentAyah ?? this.currentAyah,
      currentLoop: currentLoop ?? this.currentLoop,
      totalLoops: totalLoops ?? this.totalLoops,
      isGroupPhase: isGroupPhase ?? this.isGroupPhase,
      groupLoop: groupLoop ?? this.groupLoop,
      totalGroupLoops: totalGroupLoops ?? this.totalGroupLoops,
      isDelaying: isDelaying ?? this.isDelaying,
      delayRemainingSeconds: delayRemainingSeconds ?? this.delayRemainingSeconds,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// AudioPlayerService: Core just_audio engine powering gapless repetition,
/// link verse loops, and configurable pause delays for Zen Hifz memorization.
class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get player => _player;

  final _stateController = StreamController<HifzSessionState>.broadcast();
  Stream<HifzSessionState> get sessionStateStream => _stateController.stream;

  HifzSessionState _currentState = const HifzSessionState();
  HifzSessionState get currentState => _currentState;

  StreamSubscription<SequenceState?>? _sequenceSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  Timer? _delayCountdownTimer;

  AudioPlayerService() {
    _initListeners();
  }

  void _emitState(HifzSessionState newState) {
    _currentState = newState;
    if (!_stateController.isClosed) {
      _stateController.add(newState);
    }
  }

  void _initListeners() {
    // Listen to current sequence item change
    _sequenceSubscription = _player.sequenceStateStream.listen((seqState) {
      if (seqState == null) return;
      final currentSource = seqState.currentSource;
      if (currentSource == null) return;

      final tag = currentSource.tag;
      if (tag is AyahPlaybackTag) {
        _handleTagTransition(tag);
      }
    });

    // Listen to playback state changes
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _stopDelayTimer();
        _emitState(_currentState.copyWith(
          status: HifzPlaybackStatus.completed,
          isDelaying: false,
        ));
      } else if (state.processingState == ProcessingState.ready) {
        if (state.playing) {
          if (!_currentState.isDelaying) {
            _emitState(_currentState.copyWith(status: HifzPlaybackStatus.playing));
          }
        } else {
          _emitState(_currentState.copyWith(status: HifzPlaybackStatus.paused));
        }
      }
    });
  }

  void _handleTagTransition(AyahPlaybackTag tag) {
    if (tag.isSilence) {
      _startDelayTimer();
      _emitState(_currentState.copyWith(
        status: HifzPlaybackStatus.delaying,
        currentSurah: tag.surah,
        currentAyah: tag.ayah,
        currentLoop: tag.loopIndex,
        totalLoops: tag.totalLoops,
        isGroupPhase: tag.isGroupPhase,
        groupLoop: tag.groupLoopIndex,
        totalGroupLoops: tag.totalGroupLoops,
        isDelaying: true,
      ));
    } else {
      _stopDelayTimer();
      _emitState(_currentState.copyWith(
        status: HifzPlaybackStatus.playing,
        currentSurah: tag.surah,
        currentAyah: tag.ayah,
        currentLoop: tag.loopIndex,
        totalLoops: tag.totalLoops,
        isGroupPhase: tag.isGroupPhase,
        groupLoop: tag.groupLoopIndex,
        totalGroupLoops: tag.totalGroupLoops,
        isDelaying: false,
        delayRemainingSeconds: 0,
      ));
    }
  }

  void _startDelayTimer() {
    _stopDelayTimer();
    int remaining = 4;
    _delayCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remaining > 0) {
        remaining--;
        _emitState(_currentState.copyWith(delayRemainingSeconds: remaining));
      } else {
        _stopDelayTimer();
      }
    });
  }

  void _stopDelayTimer() {
    _delayCountdownTimer?.cancel();
    _delayCountdownTimer = null;
  }

  String _formatUrl(String pattern, int surah, int ayah) {
    final sStr = surah.toString().padLeft(3, '0');
    final aStr = ayah.toString().padLeft(3, '0');
    return pattern.replaceAll('{surah:03d}', sStr).replaceAll('{ayah:03d}', aStr);
  }

  /// Builds a gapless sequence with N single repeats, M group links, and silent WAV delays
  Future<void> prepareAndPlay(HifzVerseConfig config) async {
    try {
      _stopDelayTimer();
      _emitState(_currentState.copyWith(
        status: HifzPlaybackStatus.preparing,
        currentSurah: config.surah,
        currentAyah: config.startAyah,
        currentLoop: 1,
        totalLoops: config.singleRepeatCount,
        isGroupPhase: false,
        groupLoop: 1,
        totalGroupLoops: config.linkGroupRepeat,
      ));

      final sources = <AudioSource>[];

      // Prepare silent audio file if pause delay is configured
      AudioSource? silentSource;
      if (config.pauseDelaySeconds > 0) {
        final silentFile = await SilentWavGenerator.createSilentWav(
          durationSeconds: config.pauseDelaySeconds,
        );
        silentSource = AudioSource.file(silentFile.path);
      }

      // 1. Single Verses Repetition (N times each)
      for (int a = config.startAyah; a <= config.endAyah; a++) {
        final primaryUrl = _formatUrl(config.reciterCdnPattern, config.surah, a);

        for (int loop = 1; loop <= config.singleRepeatCount; loop++) {
          final ayahTag = AyahPlaybackTag(
            surah: config.surah,
            ayah: a,
            loopIndex: loop,
            totalLoops: config.singleRepeatCount,
            isSilence: false,
            isGroupPhase: false,
          );

          sources.add(AudioSource.uri(Uri.parse(primaryUrl), tag: ayahTag));

          if (silentSource != null) {
            final silenceTag = AyahPlaybackTag(
              surah: config.surah,
              ayah: a,
              loopIndex: loop,
              totalLoops: config.singleRepeatCount,
              isSilence: true,
              isGroupPhase: false,
            );
            sources.add(AudioSource.uri(
              (silentSource as UriAudioSource).uri,
              tag: silenceTag,
            ));
          }
        }
      }

      // 2. Linked Group Repetition (M times over the whole range)
      if (config.linkGroupRepeat > 0 && config.endAyah > config.startAyah) {
        for (int gLoop = 1; gLoop <= config.linkGroupRepeat; gLoop++) {
          for (int a = config.startAyah; a <= config.endAyah; a++) {
            final url = _formatUrl(config.reciterCdnPattern, config.surah, a);
            final groupAyahTag = AyahPlaybackTag(
              surah: config.surah,
              ayah: a,
              loopIndex: 1,
              totalLoops: 1,
              isSilence: false,
              isGroupPhase: true,
              groupLoopIndex: gLoop,
              totalGroupLoops: config.linkGroupRepeat,
            );
            sources.add(AudioSource.uri(Uri.parse(url), tag: groupAyahTag));
          }

          if (silentSource != null) {
            final groupSilenceTag = AyahPlaybackTag(
              surah: config.surah,
              ayah: config.endAyah,
              loopIndex: 1,
              totalLoops: 1,
              isSilence: true,
              isGroupPhase: true,
              groupLoopIndex: gLoop,
              totalGroupLoops: config.linkGroupRepeat,
            );
            sources.add(AudioSource.uri(
              (silentSource as UriAudioSource).uri,
              tag: groupSilenceTag,
            ));
          }
        }
      }

      final playlist = ConcatenatingAudioSource(
        useLazyPreparation: true,
        children: sources,
      );

      await _player.setAudioSource(playlist, preload: true);

      // CRITICAL: Prevent UI freeze by avoiding direct await on player.play()
      unawaited(_player.play());
    } catch (e) {
      if (kDebugMode) {
        print('AudioPlayerService error preparing session: $e');
      }
      _emitState(_currentState.copyWith(
        status: HifzPlaybackStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> pause() async {
    _stopDelayTimer();
    await _player.pause();
    _emitState(_currentState.copyWith(status: HifzPlaybackStatus.paused));
  }

  Future<void> resume() async {
    unawaited(_player.play());
  }

  Future<void> stop() async {
    _stopDelayTimer();
    await _player.stop();
    _emitState(_currentState.copyWith(
      status: HifzPlaybackStatus.idle,
      isDelaying: false,
    ));
  }

  Future<void> seekToNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  Future<void> seekToPrevious() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    }
  }

  void dispose() {
    _stopDelayTimer();
    _sequenceSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _stateController.close();
    _player.dispose();
  }
}
