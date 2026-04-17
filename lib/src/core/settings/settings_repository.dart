import "dart:convert";

import "package:al_furkan/src/core/storage/app_storage.dart";
import "package:al_furkan/src/screen/prayer_time/cubit/prayer_time_state.dart";
import "package:al_furkan/src/screen/prayer_time/models/prayer_enum.dart";
import "package:al_furkan/src/screen/prayer_time/models/reminder_type.dart";
import "package:al_furkan/src/screen/prayer_time/models/reminder_type_with_pray_model.dart";
import "package:al_furkan/src/screen/settings/cubit/quran_script_view_state.dart";
import "package:al_furkan/src/widget/quran_script/model/script_info.dart";
import "package:flutter/material.dart";

abstract class SettingsRepository {
  Future<void> applyFirstRunDefaults();
  Future<void> ensureBootstrapDefaults();
  bool isOnboardingV2Done();
  QuranScriptType get selectedQuranScriptType;
  QuranViewState loadQuranViewState();
  Future<void> saveQuranViewState(QuranViewState state);
  PrayerReminderState loadPrayerReminderState();
  Future<void> savePrayerReminderState(PrayerReminderState state);
}

class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._storage);

  final AppStorage _storage;

  static const String _firstRunKey = "idrisium_first_run_defaults_applied";
  static const String _selectedLanguageCodeKey = "selectedLanguageCode";
  static const String _themeModeKey = "app_theme_mode";
  static const String _quickSetupDoneKey = "quick_setup_done";
  static const String _isSetupCompleteKey = "is_setup_complete";
  static const String _isAyahByAyahKey = "isAyahByAyah";
  static const String _isAyahByAyahHorizontalKey = "isAyahByAyahHorizontal";
  static const String _onboardingV2DoneKey = "onboarding_v2_done";

  static const String _previewAyahKey = "preview_quran_script_ayah";
  static const String _previewFontSizeKey = "preview_quran_script_font_size";
  static const String _previewTranslationFontSizeKey =
      "preview_translation_font_size";
  static const String _lineHeightKey = "quran_script_heigh_of_line";
  static const String _selectedScriptTypeKey = "selected_quran_script_type";
  static const String _hideFootnoteKey = "view_hideFootnote";
  static const String _hideTranslationKey = "view_hideTranslation";
  static const String _hideToolbarKey = "view_hideToolbar";
  static const String _hideQuranAyahKey = "view_hideQuranAyah";
  static const String _enableWordByWordHighlightKey =
      "view_enableWordByWordHighlight";
  static const String _scrollWithRecitationKey = "view_scrollWithRecitation";
  static const String _useAudioStreamKey = "use_audio_stream";
  static const String _playbackSpeedKey = "playback_speed";

  static const String _prayerToRememberKey = "prayer_reminder_items_v1";
  static const String _previousReminderModesKey = "prayer_previous_modes_v1";
  static const String _reminderTimeAdjustmentKey = "prayer_time_adjustments_v1";
  static const String _enforceAlarmSoundKey = "prayer_enforce_alarm_sound_v1";
  static const String _soundVolumeKey = "prayer_sound_volume_v1";

  @override
  Future<void> applyFirstRunDefaults() async {
    final prefs = _storage.preferences;
    final firstRunApplied = prefs.getBool(_firstRunKey) ?? false;
    if (firstRunApplied) {
      return;
    }

    final futures = <Future<dynamic>>[];
    if (prefs.getString(_selectedLanguageCodeKey) == null) {
      futures.add(prefs.setString(_selectedLanguageCodeKey, "ar"));
    }
    if (prefs.getString(_themeModeKey) == null) {
      futures.add(prefs.setString(_themeModeKey, ThemeMode.light.toString()));
    }
    futures.add(prefs.setBool(_firstRunKey, true));
    await Future.wait(futures);
  }

  @override
  Future<void> ensureBootstrapDefaults() async {
    final userBox = _storage.userBox;
    final futures = <Future<void>>[];
    if (!userBox.containsKey(_quickSetupDoneKey)) {
      futures.add(userBox.put(_quickSetupDoneKey, true));
    }
    if (!userBox.containsKey(_isSetupCompleteKey)) {
      futures.add(userBox.put(_isSetupCompleteKey, true));
    }
    if (!userBox.containsKey(_isAyahByAyahKey)) {
      futures.add(userBox.put(_isAyahByAyahKey, false));
    }
    if (!userBox.containsKey(_isAyahByAyahHorizontalKey)) {
      futures.add(userBox.put(_isAyahByAyahHorizontalKey, false));
    }
    await Future.wait(futures);
  }

  @override
  bool isOnboardingV2Done() {
    return (_storage.userBox.get(_onboardingV2DoneKey, defaultValue: false)
            as bool?) ??
        false;
  }

  @override
  QuranScriptType get selectedQuranScriptType {
    final scriptName = _storage.userBox.get(
      _selectedScriptTypeKey,
      defaultValue: QuranScriptType.values.first.name,
    );
    return QuranScriptType.values.firstWhere(
      (element) => element.name == scriptName,
      orElse: () => QuranScriptType.values.first,
    );
  }

  @override
  QuranViewState loadQuranViewState() {
    final userBox = _storage.userBox;
    return QuranViewState(
      ayahKey: userBox.get(_previewAyahKey, defaultValue: "1:1") as String,
      fontSize: (userBox.get(_previewFontSizeKey, defaultValue: 20.0) as num)
          .toDouble(),
      translationFontSize:
          (userBox.get(_previewTranslationFontSizeKey, defaultValue: 14.0)
                  as num)
              .toDouble(),
      lineHeight: (userBox.get(_lineHeightKey, defaultValue: 2.0) as num)
          .toDouble(),
      quranScriptType: selectedQuranScriptType,
      hideFootnote:
          userBox.get(_hideFootnoteKey, defaultValue: false) as bool? ?? false,
      hideTranslation:
          userBox.get(_hideTranslationKey, defaultValue: false) as bool? ??
          false,
      hideToolbar:
          userBox.get(_hideToolbarKey, defaultValue: false) as bool? ?? false,
      hideQuranAyah:
          userBox.get(_hideQuranAyahKey, defaultValue: false) as bool? ?? false,
      enableWordByWordHighlight:
          userBox.get(_enableWordByWordHighlightKey, defaultValue: true)
              as bool? ??
          true,
      scrollWithRecitation:
          userBox.get(_scrollWithRecitationKey, defaultValue: true) as bool? ??
          true,
      useAudioStream:
          userBox.get(_useAudioStreamKey, defaultValue: true) as bool? ?? true,
      playbackSpeed: (userBox.get(_playbackSpeedKey, defaultValue: 1.0) as num)
          .toDouble(),
    );
  }

  @override
  Future<void> saveQuranViewState(QuranViewState state) async {
    final userBox = _storage.userBox;
    await Future.wait([
      userBox.put(_previewAyahKey, state.ayahKey),
      userBox.put(_previewFontSizeKey, state.fontSize),
      userBox.put(_previewTranslationFontSizeKey, state.translationFontSize),
      userBox.put(_lineHeightKey, state.lineHeight),
      userBox.put(_selectedScriptTypeKey, state.quranScriptType.name),
      userBox.put(_hideFootnoteKey, state.hideFootnote),
      userBox.put(_hideTranslationKey, state.hideTranslation),
      userBox.put(_hideToolbarKey, state.hideToolbar),
      userBox.put(_hideQuranAyahKey, state.hideQuranAyah),
      userBox.put(
        _enableWordByWordHighlightKey,
        state.enableWordByWordHighlight,
      ),
      userBox.put(_scrollWithRecitationKey, state.scrollWithRecitation),
      userBox.put(_useAudioStreamKey, state.useAudioStream),
      userBox.put(_playbackSpeedKey, state.playbackSpeed),
    ]);
  }

  @override
  PrayerReminderState loadPrayerReminderState() {
    final prefs = _storage.preferences;
    return PrayerReminderState(
      prayerToRemember: _decodePrayerList(
        prefs.getString(_prayerToRememberKey),
      ),
      previousReminderModes: _decodePreviousModes(
        prefs.getString(_previousReminderModesKey),
      ),
      reminderTimeAdjustment: _decodeAdjustmentMap(
        prefs.getString(_reminderTimeAdjustmentKey),
      ),
      enforceAlarmSound: prefs.getBool(_enforceAlarmSoundKey) ?? false,
      soundVolume: prefs.getDouble(_soundVolumeKey) ?? 1.0,
    );
  }

  @override
  Future<void> savePrayerReminderState(PrayerReminderState state) async {
    final prefs = _storage.preferences;
    await Future.wait([
      prefs.setString(
        _prayerToRememberKey,
        jsonEncode(
          state.prayerToRemember.map((item) => item.toJson()).toList(),
        ),
      ),
      prefs.setString(
        _previousReminderModesKey,
        jsonEncode(
          state.previousReminderModes.map(
            (key, value) => MapEntry(key.name, value.name),
          ),
        ),
      ),
      prefs.setString(
        _reminderTimeAdjustmentKey,
        jsonEncode(
          state.reminderTimeAdjustment.map(
            (key, value) => MapEntry(key.name, value),
          ),
        ),
      ),
      prefs.setBool(_enforceAlarmSoundKey, state.enforceAlarmSound),
      prefs.setDouble(_soundVolumeKey, state.soundVolume),
    ]);
  }

  List<ReminderTypeWithPrayModel> _decodePrayerList(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) {
      return const [];
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! List) {
        return const [];
      }
      return decoded
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .map(ReminderTypeWithPrayModel.fromJson)
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  Map<Prayer, PrayerReminderType> _decodePreviousModes(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) {
      return const {};
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map) {
        return const {};
      }

      final result = <Prayer, PrayerReminderType>{};
      for (final entry in decoded.entries) {
        final prayer = _tryParsePrayer(entry.key);
        final reminderType = _tryParseReminderType(entry.value);
        if (prayer != null && reminderType != null) {
          result[prayer] = reminderType;
        }
      }
      return result;
    } catch (_) {
      return const {};
    }
  }

  Map<Prayer, int> _decodeAdjustmentMap(String? rawValue) {
    if (rawValue == null || rawValue.isEmpty) {
      return const {};
    }

    try {
      final decoded = jsonDecode(rawValue);
      if (decoded is! Map) {
        return const {};
      }

      final result = <Prayer, int>{};
      for (final entry in decoded.entries) {
        final prayer = _tryParsePrayer(entry.key);
        final minutes = entry.value;
        if (prayer != null && minutes is num) {
          result[prayer] = minutes.toInt();
        }
      }
      return result;
    } catch (_) {
      return const {};
    }
  }

  Prayer? _tryParsePrayer(Object? rawPrayer) {
    if (rawPrayer is! String) {
      return null;
    }
    for (final prayer in Prayer.values) {
      if (prayer.name == rawPrayer) {
        return prayer;
      }
    }
    return null;
  }

  PrayerReminderType? _tryParseReminderType(Object? rawReminderType) {
    if (rawReminderType is! String) {
      return null;
    }
    for (final reminderType in PrayerReminderType.values) {
      if (reminderType.name == rawReminderType) {
        return reminderType;
      }
    }
    return null;
  }
}
