import "package:flutter_bloc/flutter_bloc.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:al_furkan/src/core/storage/app_boxes.dart";

// ═══════════════════════════════════════════════════════════════════
//  IDRISIUM Hifz Mode — وضع الحفظ (إخفاء تدريجي + اختبار)
// ═══════════════════════════════════════════════════════════════════

/// Level of hiding for ayahs
enum HifzHideLevel {
  /// Show all text normally
  visible,
  /// Blur the text (semi-hidden)
  blurred,
  /// Fully hidden (blank space)
  hidden,
}

class HifzState {
  /// Whether Hifz mode is active
  final bool isActive;
  /// Current hide level
  final HifzHideLevel hideLevel;
  /// Set of ayah keys that have been "revealed" by user tap
  final Set<String> revealedAyahs;
  /// Whether test mode is active (user must type/recall)
  final bool isTestMode;
  /// Hifz progress: map of surah number → memorized ayah count
  final Map<int, int> memorizedProgress;

  const HifzState({
    this.isActive = false,
    this.hideLevel = HifzHideLevel.blurred,
    this.revealedAyahs = const {},
    this.isTestMode = false,
    this.memorizedProgress = const {},
  });

  HifzState copyWith({
    bool? isActive,
    HifzHideLevel? hideLevel,
    Set<String>? revealedAyahs,
    bool? isTestMode,
    Map<int, int>? memorizedProgress,
  }) =>
      HifzState(
        isActive: isActive ?? this.isActive,
        hideLevel: hideLevel ?? this.hideLevel,
        revealedAyahs: revealedAyahs ?? this.revealedAyahs,
        isTestMode: isTestMode ?? this.isTestMode,
        memorizedProgress: memorizedProgress ?? this.memorizedProgress,
      );
}

class HifzCubit extends Cubit<HifzState> {
  HifzCubit() : super(const HifzState()) {
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final box = Hive.box(AppBoxes.readingStats);
    final active = box.get("hifz_active", defaultValue: false) as bool;
    final levelIndex = box.get("hifz_level", defaultValue: 1) as int;
    final testMode = box.get("hifz_test_mode", defaultValue: false) as bool;
    final revealed = box.get("hifz_revealed", defaultValue: <String>[]) as List;
    final progressRaw = box.get("hifz_progress", defaultValue: <String, int>{}) as Map;

    final progress = <int, int>{};
    progressRaw.forEach((key, value) {
      final k = int.tryParse(key.toString());
      if (k != null) progress[k] = value as int;
    });

    emit(HifzState(
      isActive: active,
      hideLevel: HifzHideLevel.values[levelIndex.clamp(0, 2)],
      isTestMode: testMode,
      revealedAyahs: Set<String>.from(revealed),
      memorizedProgress: progress,
    ));
  }

  void _saveToStorage() {
    final box = Hive.box(AppBoxes.readingStats);
    box.put("hifz_active", state.isActive);
    box.put("hifz_level", state.hideLevel.index);
    box.put("hifz_test_mode", state.isTestMode);
    box.put("hifz_revealed", state.revealedAyahs.toList());
    box.put("hifz_progress", state.memorizedProgress);
  }

  /// Toggle Hifz mode on/off
  void toggleHifz() {
    emit(state.copyWith(isActive: !state.isActive));
    _saveToStorage();
  }

  /// Set the hide level
  void setHideLevel(HifzHideLevel level) {
    emit(state.copyWith(hideLevel: level, revealedAyahs: {}));
    _saveToStorage();
  }

  /// Toggle test mode
  void toggleTestMode() {
    emit(state.copyWith(isTestMode: !state.isTestMode));
    _saveToStorage();
  }

  /// Reveal a specific ayah (user tapped to see it)
  void revealAyah(String ayahKey) {
    if (!state.isActive) return;
    final newRevealed = Set<String>.from(state.revealedAyahs)..add(ayahKey);
    emit(state.copyWith(revealedAyahs: newRevealed));
    _saveToStorage();
  }

  /// Hide a previously revealed ayah
  void hideAyah(String ayahKey) {
    final newRevealed = Set<String>.from(state.revealedAyahs)..remove(ayahKey);
    emit(state.copyWith(revealedAyahs: newRevealed));
    _saveToStorage();
  }

  /// Mark an ayah as memorized
  void markAyahMemorized(int surahNumber) {
    final newProgress = Map<int, int>.from(state.memorizedProgress);
    newProgress[surahNumber] = (newProgress[surahNumber] ?? 0) + 1;
    emit(state.copyWith(memorizedProgress: newProgress));
    _saveToStorage();
  }

  /// Check if an ayah should be hidden
  bool shouldHide(String ayahKey) {
    if (!state.isActive) return false;
    if (state.revealedAyahs.contains(ayahKey)) return false;
    return true;
  }

  /// Get the visual effect for an ayah
  HifzHideLevel getEffectForAyah(String ayahKey) {
    if (!shouldHide(ayahKey)) return HifzHideLevel.visible;
    return state.hideLevel;
  }
}
