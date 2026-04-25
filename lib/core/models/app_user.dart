import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a tracked user in `/app_users/{userId}`.
class AppUser {
  const AppUser({
    required this.uid,
    this.fcmToken = '',
    this.platform = 'android',
    this.appVersion = '',
    this.deviceModel = '',
    this.osVersion = '',
    this.firstOpen,
    this.lastOpen,
    this.totalSessions = 0,
    this.totalMinutes = 0,
    this.notificationsEnabled = true,
    this.favoriteReader = '',
    this.lastReadSurah = 1,
    this.lastReadAyah = 1,
  });

  final String uid;
  final String fcmToken;
  final String platform;
  final String appVersion;
  final String deviceModel;
  final String osVersion;
  final DateTime? firstOpen;
  final DateTime? lastOpen;
  final int totalSessions;
  final int totalMinutes;
  final bool notificationsEnabled;
  final String favoriteReader;
  final int lastReadSurah;
  final int lastReadAyah;

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return AppUser(
      uid: doc.id,
      fcmToken: d['fcmToken'] as String? ?? '',
      platform: d['platform'] as String? ?? 'android',
      appVersion: d['appVersion'] as String? ?? '',
      deviceModel: d['deviceModel'] as String? ?? '',
      osVersion: d['osVersion'] as String? ?? '',
      firstOpen: _ts(d['firstOpen']),
      lastOpen: _ts(d['lastOpen']),
      totalSessions: (d['totalSessions'] as num?)?.toInt() ?? 0,
      totalMinutes: (d['totalMinutes'] as num?)?.toInt() ?? 0,
      notificationsEnabled: d['notificationsEnabled'] as bool? ?? true,
      favoriteReader: d['favoriteReader'] as String? ?? '',
      lastReadSurah: (d['lastReadSurah'] as num?)?.toInt() ?? 1,
      lastReadAyah: (d['lastReadAyah'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toRegistrationMap() => {
    'uid': uid, 'fcmToken': fcmToken, 'platform': platform,
    'appVersion': appVersion, 'deviceModel': deviceModel,
    'osVersion': osVersion, 'firstOpen': FieldValue.serverTimestamp(),
    'lastOpen': FieldValue.serverTimestamp(), 'totalSessions': 0,
    'totalMinutes': 0, 'notificationsEnabled': notificationsEnabled,
  };

  Map<String, dynamic> toSessionUpdateMap() => {
    'fcmToken': fcmToken, 'appVersion': appVersion,
    'deviceModel': deviceModel, 'osVersion': osVersion,
    'lastOpen': FieldValue.serverTimestamp(),
    'totalSessions': FieldValue.increment(1),
  };

  bool get isRecentlyActive =>
      lastOpen != null && DateTime.now().difference(lastOpen!).inDays <= 7;

  bool get isNewUser =>
      firstOpen == null || DateTime.now().difference(firstOpen!).inHours <= 24;

  static DateTime? _ts(dynamic v) =>
      v is Timestamp ? v.toDate() : null;
}
