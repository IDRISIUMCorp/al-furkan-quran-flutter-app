import "package:hive_ce_flutter/hive_flutter.dart";
import "package:shared_preferences/shared_preferences.dart";

class AppStorage {
  const AppStorage({
    required this.preferences,
    required this.userBox,
    required this.pinnedBox,
    required this.notesBox,
  });

  final SharedPreferences preferences;
  final Box<dynamic> userBox;
  final Box<dynamic> pinnedBox;
  final Box<dynamic> notesBox;
}
