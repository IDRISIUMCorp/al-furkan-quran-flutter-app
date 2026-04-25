import "package:flutter_bloc/flutter_bloc.dart";

// ═══════════════════════════════════════════════════════════════════
//  IDRISIUM Ayah Repeat Cubit — تكرار الآية أو النطاق
// ═══════════════════════════════════════════════════════════════════

enum AyahRepeatMode {
  /// No repeat
  off,
  /// Repeat current ayah N times
  singleAyah,
  /// Repeat a range of ayahs N times
  range,
}

class AyahRepeatState {
  final AyahRepeatMode mode;
  /// How many times to repeat (0 = infinite)
  final int repeatCount;
  /// Current repetition index (1-based)
  final int currentRepetition;
  /// For range mode: start ayah key
  final String? rangeStart;
  /// For range mode: end ayah key
  final String? rangeEnd;
  /// Whether repeat is active
  final bool isActive;

  const AyahRepeatState({
    this.mode = AyahRepeatMode.off,
    this.repeatCount = 3,
    this.currentRepetition = 0,
    this.rangeStart,
    this.rangeEnd,
    this.isActive = false,
  });

  AyahRepeatState copyWith({
    AyahRepeatMode? mode,
    int? repeatCount,
    int? currentRepetition,
    String? rangeStart,
    String? rangeEnd,
    bool? isActive,
  }) =>
      AyahRepeatState(
        mode: mode ?? this.mode,
        repeatCount: repeatCount ?? this.repeatCount,
        currentRepetition: currentRepetition ?? this.currentRepetition,
        rangeStart: rangeStart ?? this.rangeStart,
        rangeEnd: rangeEnd ?? this.rangeEnd,
        isActive: isActive ?? this.isActive,
      );

  /// Whether we should stop after this repetition
  bool get shouldStop =>
      isActive && repeatCount > 0 && currentRepetition >= repeatCount;

  /// 0 means infinite
  bool get isInfinite => repeatCount == 0;

  String get label {
    if (!isActive) return "إيقاف";
    switch (mode) {
      case AyahRepeatMode.off:
        return "إيقاف";
      case AyahRepeatMode.singleAyah:
        return isInfinite
            ? "تكرار الآية ∞"
            : "تكرار الآية $currentRepetition/$repeatCount";
      case AyahRepeatMode.range:
        return isInfinite
            ? "تكرار النطاق ∞"
            : "تكرار النطاق $currentRepetition/$repeatCount";
    }
  }
}

class AyahRepeatCubit extends Cubit<AyahRepeatState> {
  AyahRepeatCubit() : super(const AyahRepeatState());

  /// Start repeating a single ayah
  void startSingleAyah({int count = 3}) {
    emit(AyahRepeatState(
      mode: AyahRepeatMode.singleAyah,
      repeatCount: count,
      currentRepetition: 1,
      isActive: true,
    ));
  }

  /// Start repeating a range
  void startRange({
    required String start,
    required String end,
    int count = 3,
  }) {
    emit(AyahRepeatState(
      mode: AyahRepeatMode.range,
      repeatCount: count,
      currentRepetition: 1,
      rangeStart: start,
      rangeEnd: end,
      isActive: true,
    ));
  }

  /// Called when one repetition cycle completes
  void onRepetitionCompleted() {
    if (!state.isActive) return;
    final next = state.currentRepetition + 1;
    if (state.repeatCount > 0 && next > state.repeatCount) {
      // All repetitions done
      stop();
    } else {
      emit(state.copyWith(currentRepetition: next));
    }
  }

  /// Stop repeating
  void stop() {
    emit(const AyahRepeatState());
  }
}
