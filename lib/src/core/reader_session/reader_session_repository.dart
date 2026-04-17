import "package:al_furkan/src/core/storage/app_storage.dart";

abstract class ReaderSessionRepository {
  int loadLastReadPage();
  String? loadLastReadAyahKey();
  Future<void> saveLastReadPosition({
    required int pageNumber,
    required String ayahKey,
  });
}

class LocalReaderSessionRepository implements ReaderSessionRepository {
  LocalReaderSessionRepository(this._storage);

  final AppStorage _storage;

  static const String _keyLastReadPage = "last_read_page";
  static const String _keyLastReadAyahKey = "last_read_ayah_key";

  @override
  int loadLastReadPage() {
    return _storage.preferences.getInt(_keyLastReadPage) ?? 1;
  }

  @override
  String? loadLastReadAyahKey() {
    return _storage.preferences.getString(_keyLastReadAyahKey);
  }

  @override
  Future<void> saveLastReadPosition({
    required int pageNumber,
    required String ayahKey,
  }) async {
    await Future.wait([
      _storage.preferences.setInt(_keyLastReadPage, pageNumber),
      _storage.preferences.setString(_keyLastReadAyahKey, ayahKey),
    ]);
  }
}
