import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/hifz_model.dart';

/// Hifz Local Data Source — Hive-based persistence for memorization tracking
class HifzLocalDataSource {
  final Box _notesBox;

  HifzLocalDataSource({required Box notesBox}) : _notesBox = notesBox;

  static const String _keyProgress = 'hifz_progress';
  static const String _keySessions = 'hifz_sessions';

  /// Get all hifz progress entries
  List<HifzProgressModel> getAllProgress() {
    final raw = _notesBox.get(_keyProgress) as String?;
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => HifzProgressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Save all hifz progress
  Future<void> saveAllProgress(List<HifzProgressModel> progress) async {
    await _notesBox.put(
      _keyProgress,
      jsonEncode(progress.map((p) => p.toJson()).toList()),
    );
  }

  /// Get recent sessions
  List<HifzSessionModel> getRecentSessions({int limit = 10}) {
    final raw = _notesBox.get(_keySessions) as String?;
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    final sessions = list
        .map((e) => HifzSessionModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return sessions.take(limit).toList();
  }

  /// Save sessions
  Future<void> saveSessions(List<HifzSessionModel> sessions) async {
    await _notesBox.put(
      _keySessions,
      jsonEncode(sessions.map((s) => s.toJson()).toList()),
    );
  }
}
