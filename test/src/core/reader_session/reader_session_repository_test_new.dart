import 'dart:io';

import 'package:al_furkan/src/core/reader_session/reader_session_repository.dart';
import 'package:al_furkan/src/core/storage/app_boxes.dart';
import 'package:al_furkan/src/core/storage/app_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late Directory tempDirectory;
  late SharedPreferences preferences;
  late Box<dynamic> userBox;
  late Box<dynamic> pinnedBox;
  late Box<dynamic> notesBox;
  late LocalReaderSessionRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();

    tempDirectory = await Directory.systemTemp.createTemp('reader_session_test');
    Hive.init(tempDirectory.path);

    userBox = await Hive.openBox<dynamic>(AppBoxes.user);
    pinnedBox = await Hive.openBox<dynamic>(AppBoxes.pinned);
    notesBox = await Hive.openBox<dynamic>(AppBoxes.notes);

    repository = LocalReaderSessionRepository(
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

  group('LocalReaderSessionRepository', () {
    test('loadLastReadPage returns 1 when no page saved', () {
      expect(repository.loadLastReadPage(), 1);
    });

    test('loadLastReadAyahKey returns null when no key saved', () {
      expect(repository.loadLastReadAyahKey(), isNull);
    });

    test('saveLastReadPosition persists page and ayahKey', () async {
      await repository.saveLastReadPosition(pageNumber: 42, ayahKey: '2:255');

      expect(repository.loadLastReadPage(), 42);
      expect(repository.loadLastReadAyahKey(), '2:255');
    });

    test('saveLastReadPosition overwrites previous values', () async {
      await repository.saveLastReadPosition(pageNumber: 10, ayahKey: '1:1');
      await repository.saveLastReadPosition(pageNumber: 300, ayahKey: '114:6');

      expect(repository.loadLastReadPage(), 300);
      expect(repository.loadLastReadAyahKey(), '114:6');
    });

    test('saveLastReadPosition with page 1 and ayahKey 1:1', () async {
      await repository.saveLastReadPosition(pageNumber: 1, ayahKey: '1:1');

      expect(repository.loadLastReadPage(), 1);
      expect(repository.loadLastReadAyahKey(), '1:1');
    });
  });
}
