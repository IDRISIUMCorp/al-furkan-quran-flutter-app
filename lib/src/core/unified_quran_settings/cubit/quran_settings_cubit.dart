import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

part 'quran_settings_state.dart';

enum QuranSettingsPreset { minimal, balanced, immersive }

class QuranSettingsCubit extends Cubit<QuranSettingsState> {
  static const String _boxName = 'quran_settings';
  static const String _kFontSize = 'font_size';
  static const String _kTheme = 'quran_theme';
  static const String _kCustomBgTheme = 'custom_bg_theme';
  static const String _kCustomTextTheme = 'custom_text_theme';
  static const String _kHighlightColorValue = 'highlight_color';
  static const String _kShowVerseNumbers = 'show_verse_numbers';
  static const String _kShowPageInfo = 'show_page_info';
  static const String _kShowBasmala = 'show_basmala';
  static const String _kShowSurahHeader = 'show_surah_header';
  static const String _kTajweedEnabled = 'tajweed_enabled';
  static const String _kCustomBackgroundColors = 'custom_background_colors';
  static const String _kLayoutMode = 'layout_mode';
  static const String _kFontFamily = 'font_family';

  late Box _box;

  QuranSettingsCubit() : super(const QuranSettingsState()) {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox(_boxName);

    final fontSize = _box.get(_kFontSize, defaultValue: 23.0) as double;
    final themeString =
        _box.get(_kTheme, defaultValue: QuranTheme.oled.name) as String;
    final customBg =
        _box.get(_kCustomBgTheme, defaultValue: 0xFF111318) as int;
    final customText =
        _box.get(_kCustomTextTheme, defaultValue: 0xFFFFFFFF) as int;
    final highlightColorValue =
        _box.get(_kHighlightColorValue, defaultValue: Colors.amber.toARGB32())
            as int;
    final showVerseNumbers =
        _box.get(_kShowVerseNumbers, defaultValue: true) as bool;
    final showPageInfo = _box.get(_kShowPageInfo, defaultValue: true) as bool;
    final showBasmala = _box.get(_kShowBasmala, defaultValue: true) as bool;
    final showSurahHeader =
        _box.get(_kShowSurahHeader, defaultValue: true) as bool;
    final tajweedEnabled =
        _box.get(_kTajweedEnabled, defaultValue: false) as bool;
    
    final customColorsData = _box.get(_kCustomBackgroundColors, defaultValue: <int>[]) as List;
    final customBackgroundColors = customColorsData.map((e) => Color(e as int)).toList();
    final layoutModeString = _box.get(_kLayoutMode, defaultValue: MushafLayoutMode.singlePage.name) as String;
    final layoutMode = MushafLayoutMode.values.firstWhere(
      (e) => e.name == layoutModeString,
      orElse: () => MushafLayoutMode.singlePage,
    );
    final fontFamilyString = _box.get(_kFontFamily, defaultValue: QuranFontFamily.qpcHafs.name) as String;
    final fontFamily = QuranFontFamily.values.firstWhere(
      (e) => e.name == fontFamilyString,
      orElse: () => QuranFontFamily.qpcHafs,
    );

    emit(
      QuranSettingsState(
        fontSize: fontSize,
        theme: QuranTheme.values.firstWhere(
          (e) => e.name == themeString,
          orElse: () => QuranTheme.charcoal,
        ),
        customBackgroundColor: Color(customBg),
        customTextColor: Color(customText),
        highlightColor: Color(highlightColorValue),
        showVerseNumbers: showVerseNumbers,
        showPageInfo: showPageInfo,
        showBasmala: showBasmala,
        showSurahHeader: showSurahHeader,
        tajweedEnabled: tajweedEnabled,
        customBackgroundColors: customBackgroundColors,
        layoutMode: layoutMode,
        fontFamily: fontFamily,
        isInitialized: true,
      ),
    );
  }

  Future<void> _persistState(QuranSettingsState next) async {
    await _box.put(_kFontSize, next.fontSize);
    await _box.put(_kTheme, next.theme.name);
    await _box.put(_kCustomBgTheme, next.customBackgroundColor.toARGB32());
    await _box.put(_kCustomTextTheme, next.customTextColor.toARGB32());
    await _box.put(_kHighlightColorValue, next.highlightColor.toARGB32());
    await _box.put(_kShowVerseNumbers, next.showVerseNumbers);
    await _box.put(_kShowPageInfo, next.showPageInfo);
    await _box.put(_kShowBasmala, next.showBasmala);
    await _box.put(_kShowSurahHeader, next.showSurahHeader);
    await _box.put(_kTajweedEnabled, next.tajweedEnabled);
    await _box.put(_kCustomBackgroundColors, next.customBackgroundColors.map((c) => c.toARGB32()).toList());
    await _box.put(_kLayoutMode, next.layoutMode.name);
    await _box.put(_kFontFamily, next.fontFamily.name);
  }

  void updateFontSize(double size) {
    if (!state.isInitialized) return;
    final next = state.copyWith(fontSize: size);
    emit(next);
    _persistState(next);
  }

  void updateTheme(QuranTheme theme) {
    if (!state.isInitialized) return;
    final next = state.copyWith(theme: theme);
    emit(next);
    _persistState(next);
  }

  void updateHighlightColor(Color color) {
    if (!state.isInitialized) return;
    final next = state.copyWith(highlightColor: color);
    emit(next);
    _persistState(next);
  }

  void updateCustomBackgroundColor(Color color) {
    if (!state.isInitialized) return;
    final next = state.copyWith(customBackgroundColor: color);
    emit(next);
    _persistState(next);
  }

  void updateCustomTextColor(Color color) {
    if (!state.isInitialized) return;
    final next = state.copyWith(customTextColor: color);
    emit(next);
    _persistState(next);
  }

  void toggleVerseNumbers(bool enabled) {
    if (!state.isInitialized) return;
    final next = state.copyWith(showVerseNumbers: enabled);
    emit(next);
    _persistState(next);
  }

  void togglePageInfo(bool enabled) {
    if (!state.isInitialized) return;
    final next = state.copyWith(showPageInfo: enabled);
    emit(next);
    _persistState(next);
  }

  void toggleBasmala(bool enabled) {
    if (!state.isInitialized) return;
    final next = state.copyWith(showBasmala: enabled);
    emit(next);
    _persistState(next);
  }

  void toggleSurahHeader(bool enabled) {
    if (!state.isInitialized) return;
    final next = state.copyWith(showSurahHeader: enabled);
    emit(next);
    _persistState(next);
  }

  void toggleTajweed(bool enabled) {
    if (!state.isInitialized) return;
    final next = state.copyWith(tajweedEnabled: enabled);
    emit(next);
    _persistState(next);
  }

  /// Apply a custom background in a single atomic emit to avoid race conditions.
  void applyCustomBackground(Color bgColor, Color textColor) {
    if (!state.isInitialized) return;
    final next = state.copyWith(
      customBackgroundColor: bgColor,
      customTextColor: textColor,
      theme: QuranTheme.custom,
    );
    emit(next);
    _persistState(next);
  }

  void addCustomBackgroundColor(Color color) {
    if (!state.isInitialized) return;
    final updatedList = List<Color>.from(state.customBackgroundColors)..add(color);
    final next = state.copyWith(customBackgroundColors: updatedList);
    emit(next);
    _persistState(next);
  }

  void removeCustomBackgroundColor(int index) {
    if (!state.isInitialized) return;
    if (index < 0 || index >= state.customBackgroundColors.length) return;
    final updatedList = List<Color>.from(state.customBackgroundColors)..removeAt(index);
    final next = state.copyWith(customBackgroundColors: updatedList);
    emit(next);
    _persistState(next);
  }

  void reorderCustomBackgroundColors(int oldIndex, int newIndex) {
    if (!state.isInitialized) return;
    final updatedList = List<Color>.from(state.customBackgroundColors);
    var adjustedIndex = newIndex;
    if (oldIndex < newIndex) {
      adjustedIndex -= 1;
    }
    final item = updatedList.removeAt(oldIndex);
    updatedList.insert(adjustedIndex, item);
    final next = state.copyWith(customBackgroundColors: updatedList);
    emit(next);
    _persistState(next);
  }

  void updateLayoutMode(MushafLayoutMode mode) {
    if (!state.isInitialized) return;
    final next = state.copyWith(layoutMode: mode);
    emit(next);
    _persistState(next);
  }

  void updateFontFamily(QuranFontFamily font) {
    if (!state.isInitialized) return;
    final next = state.copyWith(fontFamily: font);
    emit(next);
    _persistState(next);
  }

  void resetToDefaults() {
    if (!state.isInitialized) return;
    final next = const QuranSettingsState(isInitialized: true);
    emit(next);
    _persistState(next);
  }
}
