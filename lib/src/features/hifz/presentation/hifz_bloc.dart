import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/hifz.dart';
import '../domain/repositories/hifz_repository.dart';

// ── States ──

enum HifzStatus { initial, loading, loaded, error }

class HifzState {
  final HifzStatus status;
  final List<HifzProgress> allProgress;
  final HifzProgress? currentProgress;
  final List<HifzSession> recentSessions;
  final List<HifzProgress> dueForReview;
  final HifzStats? stats;
  final String? errorMessage;

  const HifzState({
    this.status = HifzStatus.initial,
    this.allProgress = const [],
    this.currentProgress,
    this.recentSessions = const [],
    this.dueForReview = const [],
    this.stats,
    this.errorMessage,
  });

  HifzState copyWith({
    HifzStatus? status,
    List<HifzProgress>? allProgress,
    HifzProgress? currentProgress,
    List<HifzSession>? recentSessions,
    List<HifzProgress>? dueForReview,
    HifzStats? stats,
    String? errorMessage,
  }) =>
      HifzState(
        status: status ?? this.status,
        allProgress: allProgress ?? this.allProgress,
        currentProgress: currentProgress ?? this.currentProgress,
        recentSessions: recentSessions ?? this.recentSessions,
        dueForReview: dueForReview ?? this.dueForReview,
        stats: stats ?? this.stats,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ── Events ──

sealed class HifzEvent {
  const HifzEvent();
}

final class LoadAllProgress extends HifzEvent {
  const LoadAllProgress();
}

final class LoadProgressForSurah extends HifzEvent {
  final int surahId;
  const LoadProgressForSurah(this.surahId);
}

final class SaveProgress extends HifzEvent {
  final HifzProgress progress;
  const SaveProgress(this.progress);
}

final class RecordSession extends HifzEvent {
  final HifzSession session;
  const RecordSession(this.session);
}

final class LoadDueForReview extends HifzEvent {
  const LoadDueForReview();
}

final class LoadStats extends HifzEvent {
  const LoadStats();
}

final class DeleteProgress extends HifzEvent {
  final int surahId;
  const DeleteProgress(this.surahId);
}

// ── BLoC ──

class HifzBloc extends Bloc<HifzEvent, HifzState> {
  final HifzRepository _hifzRepository;

  HifzBloc({required HifzRepository hifzRepository})
      : _hifzRepository = hifzRepository,
        super(const HifzState()) {
    on<LoadAllProgress>(_onLoadAllProgress);
    on<LoadProgressForSurah>(_onLoadProgressForSurah);
    on<SaveProgress>(_onSaveProgress);
    on<RecordSession>(_onRecordSession);
    on<LoadDueForReview>(_onLoadDueForReview);
    on<LoadStats>(_onLoadStats);
    on<DeleteProgress>(_onDeleteProgress);
  }

  Future<void> _onLoadAllProgress(
    LoadAllProgress event,
    Emitter<HifzState> emit,
  ) async {
    emit(state.copyWith(status: HifzStatus.loading));
    final result = await _hifzRepository.getAllProgress();
    result.fold(
      (failure) => emit(state.copyWith(
        status: HifzStatus.error,
        errorMessage: failure.message,
      )),
      (progress) => emit(state.copyWith(
        status: HifzStatus.loaded,
        allProgress: progress,
      )),
    );
  }

  Future<void> _onLoadProgressForSurah(
    LoadProgressForSurah event,
    Emitter<HifzState> emit,
  ) async {
    final result = await _hifzRepository.getProgress(event.surahId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: HifzStatus.error,
        errorMessage: failure.message,
      )),
      (progress) => emit(state.copyWith(
        status: HifzStatus.loaded,
        currentProgress: progress,
      )),
    );
  }

  Future<void> _onSaveProgress(
    SaveProgress event,
    Emitter<HifzState> emit,
  ) async {
    final result = await _hifzRepository.saveProgress(event.progress);
    result.fold(
      (failure) => emit(state.copyWith(
        status: HifzStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        // Refresh all progress after save
        add(const LoadAllProgress());
      },
    );
  }

  Future<void> _onRecordSession(
    RecordSession event,
    Emitter<HifzState> emit,
  ) async {
    final result = await _hifzRepository.recordSession(event.session);
    result.fold(
      (failure) => emit(state.copyWith(
        status: HifzStatus.error,
        errorMessage: failure.message,
      )),
      (_) {
        // Refresh sessions after recording
        add(const LoadAllProgress());
      },
    );
  }

  Future<void> _onLoadDueForReview(
    LoadDueForReview event,
    Emitter<HifzState> emit,
  ) async {
    emit(state.copyWith(status: HifzStatus.loading));
    final result = await _hifzRepository.getDueForReview();
    result.fold(
      (failure) => emit(state.copyWith(
        status: HifzStatus.error,
        errorMessage: failure.message,
      )),
      (due) => emit(state.copyWith(
        status: HifzStatus.loaded,
        dueForReview: due,
      )),
    );
  }

  Future<void> _onLoadStats(
    LoadStats event,
    Emitter<HifzState> emit,
  ) async {
    final result = await _hifzRepository.getStats();
    result.fold(
      (failure) => emit(state.copyWith(
        status: HifzStatus.error,
        errorMessage: failure.message,
      )),
      (stats) => emit(state.copyWith(
        status: HifzStatus.loaded,
        stats: stats,
      )),
    );
  }

  Future<void> _onDeleteProgress(
    DeleteProgress event,
    Emitter<HifzState> emit,
  ) async {
    final result = await _hifzRepository.deleteProgress(event.surahId);
    result.fold(
      (failure) => emit(state.copyWith(
        status: HifzStatus.error,
        errorMessage: failure.message,
      )),
      (_) => add(const LoadAllProgress()),
    );
  }
}
