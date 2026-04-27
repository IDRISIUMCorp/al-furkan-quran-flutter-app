import 'dart:io';

import 'package:al_furkan/src/core/di/service_locator.dart';
import 'package:al_furkan/src/core/notifications/notification_scheduler.dart';
import 'package:al_furkan/src/core/quran_resources/quran_resources_repository.dart';
import 'package:al_furkan/src/core/reader_session/reader_session_repository.dart';
import 'package:al_furkan/src/core/settings/settings_repository.dart';
import 'package:al_furkan/src/core/storage/app_boxes.dart';
import 'package:al_furkan/src/core/storage/app_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDirectory;
  late SharedPreferences preferences;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();

    tempDirectory = await Directory.systemTemp.createTemp('service_locator_test');
    Hive.init(tempDirectory.path);

    await Hive.openBox<dynamic>(AppBoxes.user);
    await Hive.openBox<dynamic>(AppBoxes.pinned);
    await Hive.openBox<dynamic>(AppBoxes.notes);
  });

  tearDown(() async {
    await getIt.reset();
    await Hive.close();
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  group('configureDependencies', () {
    test('registers AppStorage as singleton', () async {
      await configureDependencies(preferences: preferences);

      expect(getIt.isRegistered<AppStorage>(), isTrue);
      final storage1 = getIt<AppStorage>();
      final storage2 = getIt<AppStorage>();
      expect(identical(storage1, storage2), isTrue);
    });

    test('registers SettingsRepository as lazy singleton', () async {
      await configureDependencies(preferences: preferences);

      expect(getIt.isRegistered<SettingsRepository>(), isTrue);
      final repo1 = getIt<SettingsRepository>();
      final repo2 = getIt<SettingsRepository>();
      expect(identical(repo1, repo2), isTrue);
    });

    test('registers ReaderSessionRepository as lazy singleton', () async {
      await configureDependencies(preferences: preferences);

      expect(getIt.isRegistered<ReaderSessionRepository>(), isTrue);
    });

    test('registers QuranResourcesRepository', () async {
      await configureDependencies(preferences: preferences);

      expect(getIt.isRegistered<QuranResourcesRepository>(), isTrue);
    });

    test('registers NotificationScheduler', () async {
      await configureDependencies(preferences: preferences);

      expect(getIt.isRegistered<NotificationScheduler>(), isTrue);
    });

    test('can be called multiple times without error (resets first)', () async {
      await configureDependencies(preferences: preferences);
      await configureDependencies(preferences: preferences);

      expect(getIt.isRegistered<AppStorage>(), isTrue);
    });

    test('SettingsRepository uses AppStorage from getIt', () async {
      await configureDependencies(preferences: preferences);

      final settingsRepo = getIt<SettingsRepository>();
      expect(settingsRepo, isA<LocalSettingsRepository>());
    });

    test('ReaderSessionRepository uses AppStorage from getIt', () async {
      await configureDependencies(preferences: preferences);

      final readerRepo = getIt<ReaderSessionRepository>();
      expect(readerRepo, isA<LocalReaderSessionRepository>());
    });
  });
}
