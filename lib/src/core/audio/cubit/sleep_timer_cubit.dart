import "dart:async";

import "package:flutter_bloc/flutter_bloc.dart";

// ═══════════════════════════════════════════════════════════════════
//  IDRISIUM Sleep Timer — مؤقت النوم للتلاوة
// ═══════════════════════════════════════════════════════════════════

enum SleepTimerMode {
  /// No timer active
  off,
  /// Stop after N minutes
  minutes,
  /// Stop at end of current surah
  endOfSurah,
}

class SleepTimerState {
  final SleepTimerMode mode;
  /// Remaining minutes (only meaningful when mode == minutes)
  final int remainingMinutes;
  /// Total selected minutes
  final int totalMinutes;
  /// Whether timer is currently active (counting down)
  final bool isActive;

  const SleepTimerState({
    this.mode = SleepTimerMode.off,
    this.remainingMinutes = 0,
    this.totalMinutes = 0,
    this.isActive = false,
  });

  SleepTimerState copyWith({
    SleepTimerMode? mode,
    int? remainingMinutes,
    int? totalMinutes,
    bool? isActive,
  }) =>
      SleepTimerState(
        mode: mode ?? this.mode,
        remainingMinutes: remainingMinutes ?? this.remainingMinutes,
        totalMinutes: totalMinutes ?? this.totalMinutes,
        isActive: isActive ?? this.isActive,
      );

  /// Progress 0.0 → 1.0
  double get progress =>
      totalMinutes > 0 ? remainingMinutes / totalMinutes : 0.0;
}

class SleepTimerCubit extends Cubit<SleepTimerState> {
  SleepTimerCubit() : super(const SleepTimerState());

  Timer? _timer;

  /// Start a minute-based timer
  void startMinutesTimer(int minutes) {
    _timer?.cancel();
    emit(SleepTimerState(
      mode: SleepTimerMode.minutes,
      remainingMinutes: minutes,
      totalMinutes: minutes,
      isActive: true,
    ));
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      final remaining = state.remainingMinutes - 1;
      if (remaining <= 0) {
        _onTimerExpired();
      } else {
        emit(state.copyWith(remainingMinutes: remaining));
      }
    });
  }

  /// Start end-of-surah mode
  void startEndOfSurah() {
    _timer?.cancel();
    emit(const SleepTimerState(
      mode: SleepTimerMode.endOfSurah,
      remainingMinutes: 0,
      totalMinutes: 0,
      isActive: true,
    ));
    // No periodic timer needed — the audio system will call onSurahCompleted()
  }

  /// Called by audio system when a surah finishes playing
  void onSurahCompleted() {
    if (state.mode == SleepTimerMode.endOfSurah && state.isActive) {
      _onTimerExpired();
    }
  }

  /// Cancel the timer
  void cancelTimer() {
    _timer?.cancel();
    _timer = null;
    emit(const SleepTimerState());
  }

  void _onTimerExpired() {
    _timer?.cancel();
    _timer = null;
    emit(state.copyWith(isActive: false, remainingMinutes: 0));
    // Notify listeners that playback should stop
    _onSleepTimerExpiredController.add(true);
  }

  // Stream to notify when timer expires
  final StreamController<bool> _onSleepTimerExpiredController =
      StreamController<bool>.broadcast();

  Stream<bool> get onSleepTimerExpired => _onSleepTimerExpiredController.stream;

  @override
  Future<void> close() {
    _timer?.cancel();
    _onSleepTimerExpiredController.close();
    return super.close();
  }
}
