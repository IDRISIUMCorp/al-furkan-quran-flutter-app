import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'package:al_furkan/core/models/analytics_data.dart';

/// Firestore repository for the `/analytics` collection.
class AnalyticsRepository {
  AnalyticsRepository({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  static final _dateFmt = DateFormat('yyyy-MM-dd');

  CollectionReference<Map<String, dynamic>> get _dailyCol =>
      _db.collection('analytics').doc('daily').collection('entries');

  DocumentReference<Map<String, dynamic>> get _realtimeDoc =>
      _db.collection('analytics').doc('realtime');

  // ── READ — daily analytics ──────────────────────────────

  /// Fetches daily analytics for a date range.
  Future<List<DailyAnalytics>> fetchDailyRange(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final startStr = _dateFmt.format(start);
      final endStr = _dateFmt.format(end);

      final snap = await _dailyCol
          .where(FieldPath.documentId, isGreaterThanOrEqualTo: startStr)
          .where(FieldPath.documentId, isLessThanOrEqualTo: endStr)
          .orderBy(FieldPath.documentId)
          .get();

      return snap.docs.map(DailyAnalytics.fromFirestore).toList();
    } catch (e, st) {
      log('fetchDailyRange error: $e',
          name: 'AnalyticsRepository', stackTrace: st);
      return [];
    }
  }

  /// Fetches today's analytics.
  Future<DailyAnalytics?> fetchToday() async {
    try {
      final todayStr = _dateFmt.format(DateTime.now());
      final doc = await _dailyCol.doc(todayStr).get();
      if (!doc.exists) return null;
      return DailyAnalytics.fromFirestore(doc);
    } catch (e) {
      log('fetchToday error: $e', name: 'AnalyticsRepository');
      return null;
    }
  }

  // ── READ — realtime ─────────────────────────────────────

  /// Fetches current realtime active users.
  Future<RealtimeAnalytics> fetchRealtime() async {
    try {
      final doc = await _realtimeDoc.get();
      if (!doc.exists) return const RealtimeAnalytics();
      return RealtimeAnalytics.fromFirestore(doc);
    } catch (e) {
      log('fetchRealtime error: $e', name: 'AnalyticsRepository');
      return const RealtimeAnalytics();
    }
  }

  /// Streams realtime active users (live dashboard).
  Stream<RealtimeAnalytics> watchRealtime() {
    return _realtimeDoc.snapshots().map((snap) {
      if (!snap.exists) return const RealtimeAnalytics();
      return RealtimeAnalytics.fromFirestore(snap);
    });
  }

  // ── WRITE — increment counters ──────────────────────────

  /// Increments a daily counter (atomic, safe for concurrent writes).
  Future<void> incrementDailyCounter(String field, {int delta = 1}) async {
    final todayStr = _dateFmt.format(DateTime.now());
    await _dailyCol.doc(todayStr).set({
      'date': todayStr,
      field: FieldValue.increment(delta),
    }, SetOptions(merge: true));
  }

  /// Increments daily content views.
  Future<void> trackContentView() =>
      incrementDailyCounter('contentViews');

  /// Increments daily app opens.
  Future<void> trackAppOpen() =>
      incrementDailyCounter('opens');

  /// Increments daily notification opens.
  Future<void> trackNotifOpen() =>
      incrementDailyCounter('notifOpens');

  /// Records a surah view in the daily top surahs map.
  Future<void> trackSurahView(String surahName) async {
    final todayStr = _dateFmt.format(DateTime.now());
    await _dailyCol.doc(todayStr).set({
      'date': todayStr,
      'topSurahs.$surahName': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  /// Records a device type in the daily breakdown.
  Future<void> trackDeviceType(String deviceModel) async {
    final todayStr = _dateFmt.format(DateTime.now());
    await _dailyCol.doc(todayStr).set({
      'date': todayStr,
      'deviceTypes.$deviceModel': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  /// Updates realtime active-users heartbeat.
  Future<void> heartbeat() async {
    await _realtimeDoc.set({
      'activeNow': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
