import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:al_furkan/src/core/storage/app_boxes.dart";

// ═══════════════════════════════════════════════════════════════════
//  IDRISIUM Night Reading Mode — وضع القراءة الليلية
//  ألوان كهرمانية دافئة + تقليل الإضاءة لحماية العين
// ═══════════════════════════════════════════════════════════════════

class NightReadingState {
  /// Whether night reading mode is active
  final bool isActive;
  /// Warmth level 0.0 - 1.0 (how amber the overlay is)
  final double warmth;
  /// Brightness reduction 0.0 - 1.0
  final double dimLevel;
  /// Auto-activate at sunset
  final bool autoAtSunset;

  const NightReadingState({
    this.isActive = false,
    this.warmth = 0.7,
    this.dimLevel = 0.3,
    this.autoAtSunset = false,
  });

  NightReadingState copyWith({
    bool? isActive,
    double? warmth,
    double? dimLevel,
    bool? autoAtSunset,
  }) =>
      NightReadingState(
        isActive: isActive ?? this.isActive,
        warmth: warmth ?? this.warmth,
        dimLevel: dimLevel ?? this.dimLevel,
        autoAtSunset: autoAtSunset ?? this.autoAtSunset,
      );

  /// The overlay color to apply
  int get overlayColorValue {
    final alpha = (dimLevel * 180).round().clamp(0, 180);
    final red = (255 * warmth).round().clamp(0, 255);
    final green = (140 * warmth).round().clamp(0, 140);
    final blue = (30 * warmth).round().clamp(0, 30);
    return (alpha << 24) | (red << 16) | (green << 8) | blue;
  }
}

class NightReadingCubit extends Cubit<NightReadingState> {
  NightReadingCubit() : super(const NightReadingState()) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final box = Hive.box(AppBoxes.readingStats);
    emit(NightReadingState(
      isActive: box.get("night_active", defaultValue: false) as bool,
      warmth: box.get("night_warmth", defaultValue: 0.7) as double,
      dimLevel: box.get("night_dim", defaultValue: 0.3) as double,
      autoAtSunset: box.get("night_auto_sunset", defaultValue: false) as bool,
    ));
  }

  void _saveToStorage() {
    final box = Hive.box(AppBoxes.readingStats);
    box.put("night_active", state.isActive);
    box.put("night_warmth", state.warmth);
    box.put("night_dim", state.dimLevel);
    box.put("night_auto_sunset", state.autoAtSunset);
  }

  void toggle() {
    emit(state.copyWith(isActive: !state.isActive));
    _saveToStorage();
  }

  void setWarmth(double value) {
    emit(state.copyWith(warmth: value.clamp(0.0, 1.0)));
    _saveToStorage();
  }

  void setDimLevel(double value) {
    emit(state.copyWith(dimLevel: value.clamp(0.0, 1.0)));
    _saveToStorage();
  }

  void setAutoAtSunset(bool value) {
    emit(state.copyWith(autoAtSunset: value));
    _saveToStorage();
  }
}
