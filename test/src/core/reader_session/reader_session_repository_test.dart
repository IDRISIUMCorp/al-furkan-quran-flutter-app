import "dart:io";

import "package:al_furkan/src/core/reader_session/reader_session_repository.dart";
import "package:al_furkan/src/core/storage/app_storage.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hive_ce/hive.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() {
  late Directory tempDirectory;
  late SharedPreferences preferences;
  late LocalReaderSessionRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();

    tempDirectory = await Directory.systemTemp.createTemp(
      "reader_session_repository_test",
    );
    Hive.init(tempDirectory.path);

    final userBox = await Hive.openBox<dynamic>("user");
    final pinnedBox = await Hive.openBox<dynamic>("pinned");
    final notesBox = await Hive.openBox<dynamic>("notes");

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

  test("reader session defaults to first page when no progress exists", () {
    expect(repository.loadLastReadPage(), 1);
    expect(repository.loadLastReadAyahKey(), isNull);
  });

  test("reader session saves and reloads last read location", () async {
    await repository.saveLastReadPosition(pageNumber: 18, ayahKey: "18:10");

    expect(repository.loadLastReadPage(), 18);
    expect(repository.loadLastReadAyahKey(), "18:10");
  });
}
