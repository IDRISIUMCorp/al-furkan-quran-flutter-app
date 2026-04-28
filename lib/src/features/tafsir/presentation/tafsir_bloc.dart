import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/tafsir.dart';
import '../domain/repositories/tafsir_repository.dart';

// ── States ──

enum TafsirStatus { initial, loading, loaded, error }

class TafsirState {
  final TafsirStatus status;
  final List<Tafsir> tafsirs;
  final Tafsir? selectedTafsir;
  final List<TafsirEntry> currentEntries;
  final String? errorMessage;

  const TafsirState({
    this.status = TafsirStatus.initial,
    this.tafsirs = const [],
    this.selectedTafsir,
    this.currentEntries = const [],
    this.errorMessage,
  });

  TafsirState copyWith({
    TafsirStatus? status,
    List<Tafsir>? tafsirs,
    Tafsir? selectedTafsir,
    List<TafsirEntry>? currentEntries,
    String? errorMessage,
  }) =>
      TafsirState(
        status: status ?? this.status,
        tafsirs: tafsirs ?? this.tafsirs,
        selectedTafsir: selectedTafsir ?? this.selectedTafsir,
        currentEntries: currentEntries ?? this.currentEntries,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ── Events ──

sealed class TafsirEvent {
  const TafsirEvent();
}

final class LoadAllTafsirs extends TafsirEvent {
  const LoadAllTafsirs();
}

final class SelectTafsir extends TafsirEvent {
  final int tafsirId;
  const SelectTafsir(this.tafsirId);
}

final class LoadTafsirForAyah extends TafsirEvent {
  final int tafsirId;
  final String ayahKey;
  const LoadTafsirForAyah({
    required this.tafsirId,
    required this.ayahKey,
  });
}

final class LoadTafsirForSurah extends TafsirEvent {
  final int tafsirId;
  final int surahId;
  const LoadTafsirForSurah({
    required this.tafsirId,
    required this.surahId,
  });
}

// ── BLoC ──

class TafsirBloc extends Bloc<TafsirEvent, TafsirState> {
  final TafsirRepository _tafsirRepository;

  TafsirBloc({required TafsirRepository tafsirRepository})
      : _tafsirRepository = tafsirRepository,
        super(const TafsirState()) {
    on<LoadAllTafsirs>(_onLoadAllTafsirs);
    on<SelectTafsir>(_onSelectTafsir);
    on<LoadTafsirForAyah>(_onLoadTafsirForAyah);
    on<LoadTafsirForSurah>(_onLoadTafsirForSurah);
  }

  Future<void> _onLoadAllTafsirs(
    LoadAllTafsirs event,
    Emitter<TafsirState> emit,
  ) async {
    emit(state.copyWith(status: TafsirStatus.loading));
    final result = await _tafsirRepository.getAllTafsirs();
    result.fold(
      (failure) => emit(state.copyWith(
        status: TafsirStatus.error,
        errorMessage: failure.message,
      )),
      (tafsirs) => emit(state.copyWith(
        status: TafsirStatus.loaded,
        tafsirs: tafsirs,
      )),
    );
  }

  Future<void> _onSelectTafsir(
    SelectTafsir event,
    Emitter<TafsirState> emit,
  ) async {
    final result = await _tafsirRepository.getTafsir(event.tafsirId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: TafsirStatus.error,
        errorMessage: failure.message,
      )),
      (tafsir) {
        emit(state.copyWith(selectedTafsir: tafsir));
        // Persist selection
        _tafsirRepository.saveSelectedTafsir(event.tafsirId);
      },
    );
  }

  Future<void> _onLoadTafsirForAyah(
    LoadTafsirForAyah event,
    Emitter<TafsirState> emit,
  ) async {
    final result = await _tafsirRepository.getTafsirEntry(
      tafsirId: event.tafsirId,
      ayahKey: event.ayahKey,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: TafsirStatus.error,
        errorMessage: failure.message,
      )),
      (entry) => emit(state.copyWith(
        status: TafsirStatus.loaded,
        currentEntries: [entry],
      )),
    );
  }

  Future<void> _onLoadTafsirForSurah(
    LoadTafsirForSurah event,
    Emitter<TafsirState> emit,
  ) async {
    emit(state.copyWith(status: TafsirStatus.loading));
    final result = await _tafsirRepository.getTafsirForSurah(
      tafsirId: event.tafsirId,
      surahId: event.surahId,
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: TafsirStatus.error,
        errorMessage: failure.message,
      )),
      (entries) => emit(state.copyWith(
        status: TafsirStatus.loaded,
        currentEntries: entries,
      )),
    );
  }
}
