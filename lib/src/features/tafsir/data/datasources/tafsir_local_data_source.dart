import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tafsir_model.dart';

/// Tafsir Local Data Source — Hive + SharedPreferences for tafsir data
class TafsirLocalDataSource {
  final Box _cacheBox;
  final SharedPreferences _prefs;

  TafsirLocalDataSource({required Box cacheBox, required SharedPreferences prefs})
      : _cacheBox = cacheBox,
        _prefs = prefs;

  static const String _keyTafsirs = 'tafsirs_data';
  static const String _keySelectedTafsir = 'selected_tafsir_id';

  /// Get cached tafsirs list
  List<TafsirModel> getCachedTafsirs() {
    final raw = _cacheBox.get(_keyTafsirs) as String?;
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => TafsirModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Cache tafsirs list
  Future<void> cacheTafsirs(List<TafsirModel> tafsirs) async {
    await _cacheBox.put(
      _keyTafsirs,
      jsonEncode(tafsirs.map((t) => t.toJson()).toList()),
    );
  }

  /// Get selected tafsir ID
  int getSelectedTafsirId() {
    return _prefs.getInt(_keySelectedTafsir) ?? 1; // Default: first tafsir
  }

  /// Save selected tafsir ID
  Future<void> saveSelectedTafsirId(int id) async {
    await _prefs.setInt(_keySelectedTafsir, id);
  }

  /// Get tafsir entry for a specific ayah from local storage
  TafsirEntryModel? getTafsirEntry({required int tafsirId, required String ayahKey}) {
    final raw = _cacheBox.get('tafsir_${tafsirId}_$ayahKey') as String?;
    if (raw == null) return null;
    return TafsirEntryModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  /// Cache a tafsir entry
  Future<void> cacheTafsirEntry(TafsirEntryModel entry) async {
    await _cacheBox.put(
      'tafsir_${entry.tafsirId}_${entry.ayahKey}',
      jsonEncode(entry.toJson()),
    );
  }
}
