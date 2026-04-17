import "package:al_furkan/src/screen/collections/common_function.dart";
import "package:hive_ce_flutter/hive_flutter.dart";

class WahyLibraryStore {
  static const String bookmarksKey = "wahy_bookmarks";
  static const String starredKey = "wahy_starred";
  static const String notesKey = "wahy_notes";

  static Box<dynamic> get _box => Hive.box("user");

  static List<Map<String, dynamic>> loadBookmarks() {
    final raw = _box.get(bookmarksKey, defaultValue: const []) as List?;
    return (raw ?? const [])
        .map((entry) => Map<String, dynamic>.from(entry as Map))
        .toList();
  }

  static List<String> loadStarred() {
    final raw = _box.get(starredKey, defaultValue: const []) as List?;
    return List<String>.from(raw ?? const []);
  }

  static List<Map<String, dynamic>> loadNotes() {
    final raw = _box.get(notesKey, defaultValue: const []) as List?;
    return (raw ?? const [])
        .map((entry) => Map<String, dynamic>.from(entry as Map))
        .toList();
  }

  static Future<void> removeBookmark(String ayahKey) async {
    final list = loadBookmarks();
    list.removeWhere((entry) => (entry["ayahKey"] as String?) == ayahKey);
    await _box.put(bookmarksKey, list);
  }

  static Future<void> removeNoteAt(int index) async {
    final list = loadNotes();
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    await _box.put(notesKey, list);
  }

  static Future<void> addNote(String ayahKey, String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final list = loadNotes();
    list.insert(0, {
      "ayahKey": ayahKey,
      "text": trimmed,
      "createdAt": DateTime.now().toIso8601String(),
    });

    await _box.put(notesKey, list);
    await syncWahyNoteToCollection(ayahKey, trimmed);
  }

  static Future<void> upsertBookmarkColor(
    String ayahKey,
    String colorId,
  ) async {
    final list = loadBookmarks();
    final now = DateTime.now().toIso8601String();
    final index = list.indexWhere(
      (entry) => (entry["ayahKey"] as String?) == ayahKey,
    );
    final entry = <String, dynamic>{
      "ayahKey": ayahKey,
      "color": colorId,
      "updatedAt": now,
      "createdAt": index == -1 ? now : (list[index]["createdAt"] ?? now),
    };

    if (index == -1) {
      list.insert(0, entry);
    } else {
      list[index] = entry;
    }

    await _box.put(bookmarksKey, list);
  }

  static Future<void> toggleStar(String ayahKey) async {
    final list = loadStarred();
    if (list.contains(ayahKey)) {
      list.remove(ayahKey);
    } else {
      list.insert(0, ayahKey);
    }
    await _box.put(starredKey, list);
  }
}
