import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/prayer_time.dart';
import '../domain/usecases/get_today_prayer_times.dart';

// ── States ──

enum PrayerStatus { initial, loading, loaded, error }

class PrayerState {
  final PrayerStatus status;
  final DailyPrayerSchedule? schedule;
  final String? errorMessage;

  const PrayerState({
    this.status = PrayerStatus.initial,
    this.schedule,
    this.errorMessage,
  });

  PrayerState copyWith({
    PrayerStatus? status,
    DailyPrayerSchedule? schedule,
    String? errorMessage,
  }) =>
      PrayerState(
        status: status ?? this.status,
        schedule: schedule ?? this.schedule,
        errorMessage: errorMessage ?? this.errorMessage,
      );
}

// ── Events ──

sealed class PrayerEvent {
  const PrayerEvent();
}

final class LoadTodayPrayerTimes extends PrayerEvent {
  const LoadTodayPrayerTimes();
}

final class RefreshPrayerTimes extends PrayerEvent {
  const RefreshPrayerTimes();
}

// ── BLoC ──

class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  final GetTodayPrayerTimesUseCase _getTodayPrayerTimes;

  PrayerBloc({required GetTodayPrayerTimesUseCase getTodayPrayerTimes})
      : _getTodayPrayerTimes = getTodayPrayerTimes,
        super(const PrayerState()) {
    on<LoadTodayPrayerTimes>(_onLoadTodayPrayerTimes);
    on<RefreshPrayerTimes>(_onRefreshPrayerTimes);
  }

  Future<void> _onLoadTodayPrayerTimes(
    LoadTodayPrayerTimes event,
    Emitter<PrayerState> emit,
  ) async {
    emit(state.copyWith(status: PrayerStatus.loading));
    final result = await _getTodayPrayerTimes();
    result.fold(
      (failure) => emit(state.copyWith(
        status: PrayerStatus.error,
        errorMessage: failure.message,
      )),
      (schedule) => emit(state.copyWith(
        status: PrayerStatus.loaded,
        schedule: schedule,
      )),
    );
  }

  Future<void> _onRefreshPrayerTimes(
    RefreshPrayerTimes event,
    Emitter<PrayerState> emit,
  ) async {
    final result = await _getTodayPrayerTimes();
    result.fold(
      (failure) => emit(state.copyWith(
        status: PrayerStatus.error,
        errorMessage: failure.message,
      )),
      (schedule) => emit(state.copyWith(
        status: PrayerStatus.loaded,
        schedule: schedule,
      )),
    );
  }
}
