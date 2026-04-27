import 'dart:io';

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
  late AppStorage storage;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();

    tempDirectory = await Directory.systemTemp.createTemp('app_storage_test');
    Hive.init(tempDirectory.path);

    userBox = await Hive.openBox<dynamic>(AppBoxes.user);
    pinnedBox = await Hive.openBox<dynamic>(AppBoxes.pinned);
    notesBox = await Hive.openBox<dynamic>(AppBoxes.notes);

    storage = AppStorage(
      preferences: preferences,
      userBox: userBox,
      pinnedBox: pinnedBox,
      notesBox: notesBox,
    );
  });

  tearDown(() async {
    await Hive.close();
    if (tempDirectory.existsSync()) {
      tempDirectory.deleteSync(recursive: true);
    }
  });

  group('AppStorage', () {
    test('preferences is accessible', () {
      expect(storage.preferences, isNotNull);
      expect(storage.preferences, isA<SharedPreferences>());
    });

    test('userBox is accessible and named correctly', () {
      expect(storage.userBox, isNotNull);
      expect(storage.userBox.name, AppBoxes.user);
    });

    test('pinnedBox is accessible and named correctly', () {
      expect(storage.pinnedBox, isNotNull);
      expect(storage.pinnedBox.name, AppBoxes.pinned);
    });

    test('notesBox is accessible and named correctly', () {
      expect(storage.notesBox, isNotNull);
      expect(storage.notesBox.name, AppBoxes.notes);
    });

    test('can write and read from userBox', () async {
      await storage.userBox.put('test_key', 'test_value');
      expect(storage.userBox.get('test_key'), 'test_value');
    });

    test('can write and read from pinnedBox', () async {
      await storage.pinnedBox.put('pinned_1', [1, 2, 3]);
      expect(storage.pinnedBox.get('pinned_1'), [1, 2, 3]);
    });

    test('can write and read from notesBox', () async {
      await storage.notesBox.put('note_1', {'title': 'Test', 'body': 'Hello'});
      final note = storage.notesBox.get('note_1') as Map;
      expect(note['title'], 'Test');
    });

    test('preferences can store and retrieve values', () async {
      await storage.preferences.setBool('is_dark', true);
      expect(storage.preferences.getBool('is_dark'), isTrue);

      await storage.preferences.setInt('counter', 42);
      expect(storage.preferences.getInt('counter'), 42);

      await storage.preferences.setString('name', 'Al-Furkan');
      expect(storage.preferences.getString('name'), 'Al-Furkan');
    });

    test('userBox returns null for non-existent keys', () {
      expect(storage.userBox.get('non_existent_key'), isNull);
    });

    test('userBox supports defaultValue', () {
      expect(storage.userBox.get('non_existent_key', defaultValue: 0), 0);
    });
  });
}
