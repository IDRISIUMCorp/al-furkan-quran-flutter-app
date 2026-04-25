import 'package:flutter/foundation.dart';
import 'package:qcf_quran/qcf_quran.dart';

/// Tracks reading progress across sessions.
///
/// This is a pure-logic class with no storage dependency.
/// Use [save] and [restore] callbacks to integrate with your
/// preferred storage backend (SharedPreferences, Hive, etc.).
///
/// Example:
/// ```dart
/// final progress = QcfReadingProgress(
///   save: (data) => prefs.setString('progress', jsonEncode(data)),
///   restore: () => jsonDecode(prefs.getString('progress') ?? '{}'),
/// );
/// await progress.init();
/// progress.recordPage(42);
/// ```
class QcfReadingProgress {
  /// Called whenever progress data changes.
  /// Receives a JSON-serializable map.
  final Future<void> Function(Map<String, dynamic>)? save;

  /// Called once during [init] to restore previous state.
  /// Should return a JSON map or null.
  final Future<Map<String, dynamic>?> Function()? restore;

  int _lastPage = 1;
  Set<int> _readPages = {};
  int _streak = 0;
  DateTime? _lastReadDate;

  QcfReadingProgress({this.save, this.restore});

  /// The last page the user read (1..604).
  int get lastPage => _lastPage;

  /// Total number of unique pages read.
  int get pagesRead => _readPages.length;

  /// Reading streak in consecutive days.
  int get streak => _streak;

  /// Overall completion percentage (0.0 – 100.0).
  double get completionPercentage =>
      (_readPages.length / totalPagesCount * 100);

  /// Whether the user has completed the entire Quran.
  bool get isComplete => _readPages.length >= totalPagesCount;

  /// Initialize from storage. Must be called before use.
  Future<void> init() async {
    final data = await restore?.call();
    if (data != null) {
      _lastPage = data['lastPage'] as int? ?? 1;
      _streak = data['streak'] as int? ?? 0;
      final lastDateStr = data['lastReadDate'] as String?;
      if (lastDateStr != null) {
        _lastReadDate = DateTime.tryParse(lastDateStr);
      }
      final pages = data['readPages'] as List?;
      if (pages != null) {
        _readPages = pages.cast<int>().toSet();
      }
    }
  }

  /// Record that the user has read a page.
  Future<void> recordPage(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > totalPagesCount) return;

    _lastPage = pageNumber;
    _readPages.add(pageNumber);

    final now = _today();
    if (_lastReadDate == null) {
      _streak = 1;
    } else if (_lastReadDate != now) {
      final diff = now.difference(_lastReadDate!).inDays;
      if (diff == 1) {
        _streak++;
      } else if (diff > 1) {
        _streak = 1;
      }
    }
    _lastReadDate = now;

    await save?.call(toJson());
  }

  /// Get the page number for a given completion percentage.
  int pageAtPercentage(double percentage) {
    final target = (percentage / 100 * totalPagesCount).round();
    return target.clamp(1, totalPagesCount);
  }

  /// Reset all progress data.
  Future<void> reset() async {
    _lastPage = 1;
    _readPages.clear();
    _streak = 0;
    _lastReadDate = null;
    await save?.call(toJson());
  }

  /// Export progress as a map (for backup/sharing/storage).
  Map<String, dynamic> toJson() => {
        'lastPage': _lastPage,
        'pagesRead': _readPages.length,
        'streak': _streak,
        'completionPercentage': completionPercentage,
        'isComplete': isComplete,
        'readPages': _readPages.toList()..sort(),
        'lastReadDate': _lastReadDate?.toIso8601String(),
      };

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

/// A ChangeNotifier version of [QcfReadingProgress] for use with
/// Provider/Riverpod/Bloc patterns.
class QcfReadingProgressNotifier extends ChangeNotifier {
  QcfReadingProgress _progress;

  QcfReadingProgressNotifier({
    Future<void> Function(Map<String, dynamic>)? save,
    Future<Map<String, dynamic>?> Function()? restore,
  }) : _progress = QcfReadingProgress(save: save, restore: restore);

  int get lastPage => _progress.lastPage;
  int get pagesRead => _progress.pagesRead;
  int get streak => _progress.streak;
  double get completionPercentage => _progress.completionPercentage;
  bool get isComplete => _progress.isComplete;

  /// Initialize from storage.
  Future<void> init() async {
    await _progress.init();
    notifyListeners();
  }

  /// Record a page read and notify listeners.
  Future<void> recordPage(int pageNumber) async {
    await _progress.recordPage(pageNumber);
    notifyListeners();
  }

  /// Reset all progress and notify listeners.
  Future<void> reset() async {
    await _progress.reset();
    notifyListeners();
  }

  /// Export progress as JSON map.
  Map<String, dynamic> toJson() => _progress.toJson();
}
