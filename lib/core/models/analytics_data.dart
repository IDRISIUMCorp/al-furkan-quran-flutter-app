import 'package:cloud_firestore/cloud_firestore.dart';

// ─────────────────────────────────────────────────────────────
// DAILY ANALYTICS
// ─────────────────────────────────────────────────────────────

/// Daily aggregated analytics stored at `/analytics/daily/{YYYY-MM-DD}`.
class DailyAnalytics {
  const DailyAnalytics({
    required this.date,
    this.opens = 0,
    this.uniqueUsers = 0,
    this.newUsers = 0,
    this.sessions = 0,
    this.avgSessionMinutes = 0.0,
    this.totalMinutes = 0,
    this.contentViews = 0,
    this.notifOpens = 0,
    this.topSurahs = const {},
    this.topReaders = const {},
    this.deviceTypes = const {},
    this.osVersions = const {},
  });

  final String date;
  final int opens;
  final int uniqueUsers;
  final int newUsers;
  final int sessions;
  final double avgSessionMinutes;
  final int totalMinutes;
  final int contentViews;
  final int notifOpens;
  final Map<String, int> topSurahs;
  final Map<String, int> topReaders;
  final Map<String, int> deviceTypes;
  final Map<String, int> osVersions;

  factory DailyAnalytics.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return DailyAnalytics(
      date: data['date'] as String? ?? doc.id,
      opens: (data['opens'] as num?)?.toInt() ?? 0,
      uniqueUsers: (data['uniqueUsers'] as num?)?.toInt() ?? 0,
      newUsers: (data['newUsers'] as num?)?.toInt() ?? 0,
      sessions: (data['sessions'] as num?)?.toInt() ?? 0,
      avgSessionMinutes:
          (data['avgSessionMinutes'] as num?)?.toDouble() ?? 0.0,
      totalMinutes: (data['totalMinutes'] as num?)?.toInt() ?? 0,
      contentViews: (data['contentViews'] as num?)?.toInt() ?? 0,
      notifOpens: (data['notifOpens'] as num?)?.toInt() ?? 0,
      topSurahs: _parseIntMap(data['topSurahs']),
      topReaders: _parseIntMap(data['topReaders']),
      deviceTypes: _parseIntMap(data['deviceTypes']),
      osVersions: _parseIntMap(data['osVersions']),
    );
  }

  /// Computed average (recalculated from totalMinutes / sessions).
  double get computedAvgSession =>
      sessions > 0 ? totalMinutes / sessions : 0.0;

  static Map<String, int> _parseIntMap(dynamic value) {
    if (value is! Map) return const {};
    return value.map(
      (key, val) => MapEntry(
        key.toString(),
        (val as num?)?.toInt() ?? 0,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// REALTIME DATA
// ─────────────────────────────────────────────────────────────

/// Realtime active-user data stored at `/analytics/realtime/current`.
class RealtimeAnalytics {
  const RealtimeAnalytics({
    this.activeNow = 0,
    this.activeLast5Min = 0,
    this.activeLast1Hour = 0,
    this.updatedAt,
  });

  final int activeNow;
  final int activeLast5Min;
  final int activeLast1Hour;
  final DateTime? updatedAt;

  factory RealtimeAnalytics.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return RealtimeAnalytics(
      activeNow: (data['activeNow'] as num?)?.toInt() ?? 0,
      activeLast5Min: (data['activeLast5Min'] as num?)?.toInt() ?? 0,
      activeLast1Hour: (data['activeLast1Hour'] as num?)?.toInt() ?? 0,
      updatedAt: _ts(data['updatedAt']),
    );
  }

  /// Alias for dashboard card usage.
  int get last5Min => activeLast5Min;
  int get last1Hour => activeLast1Hour;

  static DateTime? _ts(dynamic v) {
    if (v is Timestamp) return v.toDate();
    return null;
  }
}

// ─────────────────────────────────────────────────────────────
// ANALYTICS DATE RANGE
// ─────────────────────────────────────────────────────────────

/// Convenience enum for the admin dashboard date range picker.
enum AnalyticsDateRange {
  today('اليوم'),
  week('أسبوع'),
  month('شهر'),
  allTime('كل الوقت');

  const AnalyticsDateRange(this.arabicLabel);
  final String arabicLabel;

  /// Returns the start date for querying daily analytics.
  DateTime get startDate {
    final now = DateTime.now();
    return switch (this) {
      AnalyticsDateRange.today => DateTime(now.year, now.month, now.day),
      AnalyticsDateRange.week => now.subtract(const Duration(days: 7)),
      AnalyticsDateRange.month => now.subtract(const Duration(days: 30)),
      AnalyticsDateRange.allTime => DateTime(2024),
    };
  }
}
