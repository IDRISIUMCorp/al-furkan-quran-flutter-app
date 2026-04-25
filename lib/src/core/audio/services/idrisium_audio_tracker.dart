import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:al_furkan/src/core/audio/cubit/ayah_key_cubit.dart';
import 'package:al_furkan/src/core/audio/cubit/player_position_cubit.dart';
import 'package:al_furkan/src/core/audio/cubit/player_state_cubit.dart';
import 'package:al_furkan/src/core/audio/cubit/segmented_quran_reciter_cubit.dart';
import 'package:al_furkan/src/core/audio/model/audio_player_position_model.dart';
import 'package:al_furkan/src/utils/quran_resources/quran_script_function.dart';
import 'package:al_furkan/src/widget/quran_script/model/script_info.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

class AudioAyahHighlightState {
  final String? activeAyahKey;
  final String? activeWordKey;

  const AudioAyahHighlightState({this.activeAyahKey, this.activeWordKey});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AudioAyahHighlightState &&
          runtimeType == other.runtimeType &&
          activeAyahKey == other.activeAyahKey &&
          activeWordKey == other.activeWordKey;

  @override
  int get hashCode => activeAyahKey.hashCode ^ activeWordKey.hashCode;
}

/// Cubit to broadcast the currently highlighted word and ayah based on playback.
/// This prevents UI from listening to high-frequency position streams.
class AudioAyahHighlightCubit extends Cubit<AudioAyahHighlightState> {
  AudioAyahHighlightCubit() : super(const AudioAyahHighlightState());

  void updateHighlight(String? ayahKey, String? wordKey) {
    if (state.activeAyahKey != ayahKey || state.activeWordKey != wordKey) {
      emit(AudioAyahHighlightState(
          activeAyahKey: ayahKey, activeWordKey: wordKey));
    }
  }

  void clearHighlight() {
    if (state.activeAyahKey != null || state.activeWordKey != null) {
      emit(const AudioAyahHighlightState());
    }
  }
}

/// The Idrisium tracking engine that maps audio position to word segments.
/// It uses `SegmentedQuranReciterCubit` to read segments, ensuring
/// consistency with the active reciter.
///
/// يدعم:
/// - تحديث التظليل فوراً عند بدء التشغيل
/// - Periodic fallback كل 300ms لضمان عدم انقطاع التظليل أثناء Buffering
/// - تنظيف التظليل فقط عند التوقف الفعلي (completed/idle)
class IdrisiumAudioTracker {
  final PlayerPositionCubit positionCubit;
  final PlayerStateCubit stateCubit;
  final AyahKeyCubit ayahCubit;
  final SegmentedQuranReciterCubit reciterCubit;
  final AudioAyahHighlightCubit highlightCubit;

  StreamSubscription? _positionSub;
  StreamSubscription? _stateSub;
  StreamSubscription? _ayahSub;
  Timer? _fallbackTimer;

  String? _currentAyahKey;
  List<List>? _currentAyahSegments;

  /// Optional callback invoked when playback stops (pause/stop/complete)
  /// so that external manual-highlight cubits can be cleared.
  VoidCallback? onPlaybackStopped;

  IdrisiumAudioTracker({
    required this.positionCubit,
    required this.stateCubit,
    required this.ayahCubit,
    required this.reciterCubit,
    required this.highlightCubit,
    this.onPlaybackStopped,
  }) {
    _init();
  }

  void _init() {
    // Process initial state immediately
    _currentAyahKey = ayahCubit.state.current;
    _loadSegmentsForAyah(_currentAyahKey);

    // If audio is already playing, start highlighting immediately
    if (stateCubit.state.isPlaying && _currentAyahKey != null) {
      highlightCubit.updateHighlight(_currentAyahKey, null);
      _startFallbackTimer();
    }

    _ayahSub = ayahCubit.stream.listen((ayahState) {
      if (_currentAyahKey != ayahState.current) {
        _currentAyahKey = ayahState.current;
        _loadSegmentsForAyah(_currentAyahKey);
        // Immediately update highlight with ayah key even if no word match yet
        if (_isEffectivelyPlaying) {
          highlightCubit.updateHighlight(_currentAyahKey, null);
        }
      }
    });

    _stateSub = stateCubit.stream.listen((state) {
      final pState = state.state;

      if (pState == ProcessingState.idle) {
        // Idle = no source loaded = user stopped playback → clear highlight
        highlightCubit.clearHighlight();
        _stopFallbackTimer();
        onPlaybackStopped?.call();
      } else if (pState == ProcessingState.completed) {
        // Completed = finished all items in playlist → clear highlight
        highlightCubit.clearHighlight();
        _stopFallbackTimer();
        onPlaybackStopped?.call();
      } else if (state.isPlaying) {
        // Actively playing → highlight the current ayah + start word tracking
        highlightCubit.updateHighlight(_currentAyahKey, null);
        _startFallbackTimer();
      } else if (!state.isPlaying) {
        // Not playing (paused, ready but not playing, or between tracks).
        // DON'T clear highlight here — only clear on true stop (idle/completed).
        // Clearing here caused a race: during the brief gap between ayahs in a
        // playlist, activeAyahKey becomes null, so the isAudioPlaying guard in
        // tap handlers fails and allows manual highlight to override the audio.
        _stopFallbackTimer();
      }
    });

    _positionSub = positionCubit.stream.listen((posState) {
      if (!_isEffectivelyPlaying) return;
      // Retry loading segments if the box wasn't ready on first attempt.
      _retrySegmentsIfNeeded();
      _calculateHighlight(posState);
    });
  }

  /// Returns true if the player is effectively playing (playing, buffering, or loading).
  /// This ensures highlighting persists through temporary buffering states.
  /// Note: ProcessingState.ready is NOT included because it means the player is
  /// paused (source loaded but not playing) — highlighting should be cleared on pause.
  bool get _isEffectivelyPlaying {
    final s = stateCubit.state;
    if (s.isPlaying) return true;
    final pState = s.state;
    return pState == ProcessingState.buffering ||
        pState == ProcessingState.loading;
  }

  void _startFallbackTimer() {
    _stopFallbackTimer();
    _fallbackTimer = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (!_isEffectivelyPlaying) {
        _stopFallbackTimer();
        return;
      }
      // Retry loading segments if the box wasn't ready on first attempt.
      _retrySegmentsIfNeeded();
      // Re-calculate based on current position
      _calculateHighlight(positionCubit.state);
    });
  }

  void _stopFallbackTimer() {
    _fallbackTimer?.cancel();
    _fallbackTimer = null;
  }

  /// Whether the last segment load returned null (box may not have been open).
  bool _segmentsLoadFailed = false;
  int _retryCount = 0;

  void _loadSegmentsForAyah(String? ayahKey) {
    if (ayahKey == null || ayahKey.isEmpty) {
      _currentAyahSegments = null;
      _segmentsLoadFailed = false;
      return;
    }
    _currentAyahSegments = reciterCubit.getAyahSegments(ayahKey);
    _segmentsLoadFailed = _currentAyahSegments == null;
    _retryCount = 0;
  }

  /// Retry loading segments if the previous attempt failed
  /// (e.g. the Hive box wasn't open yet during deferred warmup).
  /// Limits retries to avoid excessive calls when no segments exist.
  void _retrySegmentsIfNeeded() {
    if (_segmentsLoadFailed && _currentAyahKey != null && _retryCount < 5) {
      _retryCount++;
      final segments = reciterCubit.getAyahSegments(_currentAyahKey!);
      if (segments != null) {
        _currentAyahSegments = segments;
        _segmentsLoadFailed = false;
      }
    }
  }

  /// Cache for word count per ayah (fallback tracking)
  static final Map<String, int> _ayahWordCountCache = {};

  /// Get the number of words in an ayah (for fallback tracking)
  int _getAyahWordCount(String ayahKey) {
    final cached = _ayahWordCountCache[ayahKey];
    if (cached != null) return cached;
    try {
      final parts = ayahKey.split(':');
      if (parts.length != 2) return 0;
      final words = QuranScriptFunction.getWordListOfAyah(
        QuranScriptType.uthmani,
        parts[0],
        parts[1],
      );
      final count = words.length;
      _ayahWordCountCache[ayahKey] = count;
      return count;
    } catch (_) {
      return 0;
    }
  }

  void _calculateHighlight(AudioPlayerPositionModel posState) {
    final posMs = posState.currentDuration?.inMilliseconds ?? 0;
    final totalMs = posState.totalDuration?.inMilliseconds ?? 0;

    if (_currentAyahKey == null || _currentAyahKey!.isEmpty) {
      return;
    }

    // If segments are available, use precise word tracking
    if (_currentAyahSegments != null && _currentAyahSegments!.isNotEmpty) {
      String? foundWordKey;
      for (final word in _currentAyahSegments!) {
        if (word.length >= 3) {
          final startMs = (word[1] as num).toInt();
          if (posMs >= startMs) {
            foundWordKey = "$_currentAyahKey:${(word[0] as num).toInt()}";
          } else {
            break; // Segments are sorted, so we can stop searching.
          }
        }
      }
      highlightCubit.updateHighlight(_currentAyahKey, foundWordKey);
      return;
    }

    // Fallback: no segments available — estimate word position by dividing
    // the ayah duration evenly across all words.
    if (totalMs <= 0) {
      highlightCubit.updateHighlight(_currentAyahKey, null);
      return;
    }

    final wordCount = _getAyahWordCount(_currentAyahKey!);
    if (wordCount <= 0) {
      highlightCubit.updateHighlight(_currentAyahKey, null);
      return;
    }

    final msPerWord = totalMs / wordCount;
    // Find which word we're currently at
    final wordIndex = (posMs / msPerWord).floor().clamp(0, wordCount - 1);
    final foundWordKey = "$_currentAyahKey:${wordIndex + 1}";

    highlightCubit.updateHighlight(_currentAyahKey, foundWordKey);
  }

  void dispose() {
    _positionSub?.cancel();
    _stateSub?.cancel();
    _ayahSub?.cancel();
    _stopFallbackTimer();
  }
}

