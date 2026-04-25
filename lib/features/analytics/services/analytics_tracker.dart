import 'dart:async';
import 'dart:developer';

import 'package:device_info_plus/device_info_plus.dart';

import 'package:al_furkan/core/repositories/analytics_repository.dart';

/// Singleton service that silently tracks user activity
/// and sends periodic heartbeats to Firestore.
class AnalyticsTracker {
  AnalyticsTracker._({AnalyticsRepository? repository})
      : _repository = repository ?? AnalyticsRepository();

  static AnalyticsTracker? _instance;
  static AnalyticsTracker get instance =>
      _instance ??= AnalyticsTracker._();

  final AnalyticsRepository _repository;
  Timer? _heartbeatTimer;
  DateTime? _sessionStart;

  /// Initializes tracking: records app open, device info, starts heartbeat.
  Future<void> init() async {
    try {
      // Track app open.
      await _repository.trackAppOpen();

      // Track device info.
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      final model = '${androidInfo.brand} ${androidInfo.model}';
      await _repository.trackDeviceType(model);

      // Start session timer.
      _sessionStart = DateTime.now();

      // Heartbeat every 30 seconds.
      _heartbeatTimer?.cancel();
      _heartbeatTimer = Timer.periodic(
        const Duration(seconds: 30),
        (_) => _repository.heartbeat(),
      );

      // Initial heartbeat.
      await _repository.heartbeat();

      log('AnalyticsTracker initialized', name: 'AnalyticsTracker');
    } catch (e) {
      log('AnalyticsTracker init error: $e', name: 'AnalyticsTracker');
    }
  }

  /// Tracks a content view.
  void trackContentView() => _repository.trackContentView();

  /// Tracks a surah view.
  void trackSurahView(String surahName) =>
      _repository.trackSurahView(surahName);

  /// Tracks a notification open.
  void trackNotifOpen() => _repository.trackNotifOpen();

  /// Call when app is paused/closed to record session duration.
  Future<void> endSession() async {
    _heartbeatTimer?.cancel();
    if (_sessionStart != null) {
      final minutes = DateTime.now().difference(_sessionStart!).inMinutes;
      if (minutes > 0) {
        await _repository.incrementDailyCounter('totalMinutes', delta: minutes);
        await _repository.incrementDailyCounter('sessions');
      }
    }
  }

  /// Cleanup.
  void dispose() {
    _heartbeatTimer?.cancel();
    _instance = null;
  }
}
