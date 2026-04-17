import "dart:io";

import "package:al_furkan/src/core/settings/settings_repository.dart";
import "package:al_furkan/src/core/storage/app_storage.dart";
import "package:al_furkan/src/screen/prayer_time/cubit/prayer_time_state.dart";
import "package:al_furkan/src/screen/prayer_time/models/prayer_enum.dart";
import "package:al_furkan/src/screen/prayer_time/models/reminder_type.dart";
import "package:al_furkan/src/screen/prayer_time/models/reminder_type_with_pray_model.dart";
import "package:al_furkan/src/screen/settings/cubit/quran_script_view_state.dart";
import "package:al_furkan/src/widget/quran_script/model/script_info.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hive_ce/hive.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() {
  late Directory tempDirectory;
  late SharedPreferences preferences;
  late Box<dynamic> userBox;
  late Box<dynamic> pinnedBox;
  late Box<dynamic> notesBox;
  late LocalSettingsRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();

    tempDirectory = await Directory.systemTemp.createTemp(
      "settings_repository_test",
    );
    Hive.init(tempDirectory.path);

    userBox = await Hive.openBox<dynamic>("user");
    pinnedBox = await Hive.openBox<dynamic>("pinned");
    notesBox = await Hive.openBox<dynamic>("notes");

    repository = LocalSettingsRepository(
      AppStorage(
        preferences: preferences,
        userBox: userBox,
        pinnedBox: pinnedBox,
        notesBox: notesBox,
      ),
    );
  });

  tearDown(() async {
    await Hive.close();
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  test("applyFirstRunDefaults seeds stable app defaults once", () async {
    await repository.applyFirstRunDefaults();

    expect(preferences.getString("selectedLanguageCode"), "ar");
    expect(preferences.getString("app_theme_mode"), ThemeMode.light.toString());
    expect(preferences.getBool("idrisium_first_run_defaults_applied"), isTrue);
  });

  test(
    "saveQuranViewState persists and reloads reader presentation settings",
    () async {
      final expected = const QuranViewState(
        ayahKey: "2:255",
        fontSize: 24,
        lineHeight: 2.3,
        quranScriptType: QuranScriptType.indopak,
        translationFontSize: 16,
        hideFootnote: true,
        hideTranslation: true,
        hideToolbar: true,
        hideQuranAyah: false,
        enableWordByWordHighlight: false,
        scrollWithRecitation: false,
        useAudioStream: false,
        playbackSpeed: 1.25,
      );

      await repository.saveQuranViewState(expected);

      expect(repository.loadQuranViewState(), expected);
      expect(repository.selectedQuranScriptType, QuranScriptType.indopak);
    },
  );

  test(
    "savePrayerReminderState round-trips reminder settings safely",
    () async {
      final expected = PrayerReminderState(
        prayerToRemember: const [
          ReminderTypeWithPrayModel(
            reminderType: PrayerReminderType.alarm,
            prayerTimesType: Prayer.fajr,
          ),
        ],
        previousReminderModes: const {
          Prayer.fajr: PrayerReminderType.alarm,
          Prayer.asr: PrayerReminderType.notification,
        },
        reminderTimeAdjustment: const {Prayer.fajr: -10, Prayer.asr: 15},
        enforceAlarmSound: true,
        soundVolume: 0.65,
      );

      await repository.savePrayerReminderState(expected);

      expect(repository.loadPrayerReminderState(), expected);
    },
  );
}
