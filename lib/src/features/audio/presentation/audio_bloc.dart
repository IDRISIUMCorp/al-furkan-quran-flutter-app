import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/reciter.dart';
import '../domain/repositories/audio_repository.dart';

// ── States ──

enum AudioStatus { initial, loading, loaded, playing, paused, error }

class AudioState {
  final AudioStatus status;
  final List<Reciter> reciters;
  final Reciter? selectedReciter;
  final int? currentSurahId;
  final Duration? currentPosition;
  final Duration? totalDuration;
  final String? errorMessage;

  const AudioState({
    this.status = AudioStatus.initial,
    this.reciters = const [],
    this.selectedReciter,
    this.currentSurahId,
    this.currentPosition,
    this.totalDuration,
    this.errorMessage,
  });

  AudioState copyWith({
    AudioStatus? status,
    List<Reciter>? reciters,
    Reciter? selectedReciter,
    int? currentSurahId,
    Duration? currentPosition,
    Duration? totalDuration,
    String? errorMessage,
  }) =>
      AudioState(
        status: status ?? this.status,
        reciters: reciters ?? this.reciters,
        selectedReciter: selectedReciter ?? this.selectedReciter,
        currentSurahId: currentSurahId ?? this.currentSurahId,
        currentPosition: currentPosition ?? this.currentPosition,
        totalDuration: totalDuration ?? this.totalDuration,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ── Events ──

sealed class AudioEvent {
  const AudioEvent();
}

final class LoadReciters extends AudioEvent {
  const LoadReciters();
}

final class SelectReciter extends AudioEvent {
  final int reciterId;
  const SelectReciter(this.reciterId);
}

final class PlaySurah extends AudioEvent {
  final int surahId;
  const PlaySurah(this.surahId);
}

final class PauseAudio extends AudioEvent {
  const PauseAudio();
}

final class ResumeAudio extends AudioEvent {
  const ResumeAudio();
}

final class StopAudio extends AudioEvent {
  const StopAudio();
}

final class UpdatePlaybackPosition extends AudioEvent {
  final Duration position;
  final Duration totalDuration;
  const UpdatePlaybackPosition(this.position, this.totalDuration);
}

final class DownloadSurahAudio extends AudioEvent {
  final int reciterId;
  final int surahId;
  const DownloadSurahAudio({required this.reciterId, required this.surahId});
}

// ── BLoC ──

class AudioBloc extends Bloc<AudioEvent, AudioState> {
  final AudioRepository _audioRepository;

  AudioBloc({required AudioRepository audioRepository})
      : _audioRepository = audioRepository,
        super(const AudioState()) {
    on<LoadReciters>(_onLoadReciters);
    on<SelectReciter>(_onSelectReciter);
    on<PlaySurah>(_onPlaySurah);
    on<PauseAudio>(_onPauseAudio);
    on<ResumeAudio>(_onResumeAudio);
    on<StopAudio>(_onStopAudio);
    on<UpdatePlaybackPosition>(_onUpdatePlaybackPosition);
    on<DownloadSurahAudio>(_onDownloadSurahAudio);
  }

  Future<void> _onLoadReciters(
    LoadReciters event,
    Emitter<AudioState> emit,
  ) async {
    emit(state.copyWith(status: AudioStatus.loading));
    final result = await _audioRepository.getAllReciters();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AudioStatus.error,
        errorMessage: failure.message,
      )),
      (reciters) => emit(state.copyWith(
        status: AudioStatus.loaded,
        reciters: reciters,
      )),
    );
  }

  Future<void> _onSelectReciter(
    SelectReciter event,
    Emitter<AudioState> emit,
  ) async {
    final result = await _audioRepository.getReciter(event.reciterId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: AudioStatus.error,
        errorMessage: failure.message,
      )),
      (reciter) => emit(state.copyWith(selectedReciter: reciter)),
    );
  }

  Future<void> _onPlaySurah(
    PlaySurah event,
    Emitter<AudioState> emit,
  ) async {
    // Audio playback is handled by just_audio in the presentation layer
    // This BLoC manages state; actual player integration is in the widget layer
    emit(state.copyWith(
      status: AudioStatus.playing,
      currentSurahId: event.surahId,
    ));
  }

  Future<void> _onPauseAudio(
    PauseAudio event,
    Emitter<AudioState> emit,
  ) async {
    emit(state.copyWith(status: AudioStatus.paused));
  }

  Future<void> _onResumeAudio(
    ResumeAudio event,
    Emitter<AudioState> emit,
  ) async {
    emit(state.copyWith(status: AudioStatus.playing));
  }

  Future<void> _onStopAudio(
    StopAudio event,
    Emitter<AudioState> emit,
  ) async {
    emit(state.copyWith(status: AudioStatus.loaded));
  }

  Future<void> _onUpdatePlaybackPosition(
    UpdatePlaybackPosition event,
    Emitter<AudioState> emit,
  ) async {
    emit(state.copyWith(
      currentPosition: event.position,
      totalDuration: event.totalDuration,
    ));
  }

  Future<void> _onDownloadSurahAudio(
    DownloadSurahAudio event,
    Emitter<AudioState> emit,
  ) async {
    final result = await _audioRepository.downloadSurahAudio(
      reciterId: event.reciterId,
      surahId: event.surahId,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AudioStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith()),
    );
  }
}
