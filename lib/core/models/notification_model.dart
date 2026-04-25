import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a sent notification in the `/notifications` collection.
class NotificationLog {
  const NotificationLog({
    required this.id,
    required this.title,
    required this.body,
    this.imageUrl,
    this.deepLink,
    this.targetAudience = NotificationAudience.all,
    this.topicOrToken = '',
    this.data = const {},
    this.sentAt,
    this.sentBy = '',
    this.stats = const NotificationStats(),
  });

  final String id;
  final String title;
  final String body;
  final String? imageUrl;
  final String? deepLink;
  final NotificationAudience targetAudience;
  final String topicOrToken;
  final Map<String, String> data;
  final DateTime? sentAt;
  final String sentBy;
  final NotificationStats stats;

  /// Alias for convenience in UI code.
  NotificationAudience get audience => targetAudience;

  // ── Factory for creating new logs from FCM sends ────────

  factory NotificationLog.create({
    required String title,
    required String body,
    String imageUrl = '',
    required NotificationAudience audience,
    String topicOrToken = '',
    Map<String, String> data = const {},
    int sentCount = 0,
    int failedCount = 0,
  }) {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    return NotificationLog(
      id: id,
      title: title,
      body: body,
      imageUrl: imageUrl.isNotEmpty ? imageUrl : null,
      targetAudience: audience,
      topicOrToken: topicOrToken,
      data: data,
      stats: NotificationStats(
        sent: sentCount,
        failed: failedCount,
      ),
    );
  }

  // ── Firestore ───────────────────────────────────────────────

  factory NotificationLog.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final d = doc.data()!;
    return NotificationLog(
      id: doc.id,
      title: d['title'] as String? ?? '',
      body: d['body'] as String? ?? '',
      imageUrl: d['imageUrl'] as String?,
      deepLink: d['deepLink'] as String?,
      targetAudience:
          NotificationAudience.fromString(d['targetAudience'] as String?),
      topicOrToken: d['topicOrToken'] as String? ?? '',
      sentAt: _ts(d['sentAt']),
      sentBy: d['sentBy'] as String? ?? '',
      stats: NotificationStats.fromMap(
        d['stats'] as Map<String, dynamic>?,
      ),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'title': title,
        'body': body,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (deepLink != null) 'deepLink': deepLink,
        'targetAudience': targetAudience.name,
        'topicOrToken': topicOrToken,
        'sentAt': FieldValue.serverTimestamp(),
        'sentBy': sentBy,
        'stats': stats.toMap(),
      };

  static DateTime? _ts(dynamic v) {
    if (v is Timestamp) return v.toDate();
    return null;
  }
}

// ─────────────────────────────────────────────────────────────
// NOTIFICATION STATS
// ─────────────────────────────────────────────────────────────

class NotificationStats {
  const NotificationStats({
    this.sent = 0,
    this.failed = 0,
    this.delivered = 0,
    this.opened = 0,
    this.openRate = 0.0,
  });

  final int sent;
  final int failed;
  final int delivered;
  final int opened;
  final double openRate;

  /// Aliases for FCM service usage.
  int get sentCount => sent;
  int get failedCount => failed;

  factory NotificationStats.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const NotificationStats();
    return NotificationStats(
      sent: (map['sent'] as num?)?.toInt() ?? 0,
      failed: (map['failed'] as num?)?.toInt() ?? 0,
      delivered: (map['delivered'] as num?)?.toInt() ?? 0,
      opened: (map['opened'] as num?)?.toInt() ?? 0,
      openRate: (map['openRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() => {
        'sent': sent,
        'failed': failed,
        'delivered': delivered,
        'opened': opened,
        'openRate': openRate,
      };
}

// ─────────────────────────────────────────────────────────────
// AUDIENCE ENUM
// ─────────────────────────────────────────────────────────────

enum NotificationAudience {
  all('الكل'),
  topic('موضوع'),
  individual('فرد'),
  newUsers('مستخدمون جدد'),
  activeUsers('مستخدمون نشطون');

  const NotificationAudience(this.arabicLabel);
  final String arabicLabel;

  static NotificationAudience fromString(String? value) {
    if (value == null) return NotificationAudience.all;
    for (final a in NotificationAudience.values) {
      if (a.name == value) return a;
    }
    return NotificationAudience.all;
  }
}
