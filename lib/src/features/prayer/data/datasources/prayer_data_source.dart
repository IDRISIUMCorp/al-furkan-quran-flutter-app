import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_client.dart';
import '../models/prayer_time_model.dart';

/// Prayer Remote Data Source — Aladhan API integration
class PrayerRemoteDataSource {
  PrayerRemoteDataSource();

  static const String _baseUrl = 'https://api.aladhan.com/v1';

  /// Fetch prayer times from Aladhan API for a specific date and location
  Future<DailyPrayerScheduleModel> getPrayerTimes({
    required DateTime date,
    required double latitude,
    required double longitude,
    required String method,
  }) async {
    final dateStr =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    final response = await ApiClient.dio.get(
      '$_baseUrl/timings/$dateStr',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'method': method,
      },
    );

    final data = response.data['data'];
    final timings = data['timings'] as Map<String, dynamic>;
    final hijri = data['date']['hijri'] as Map<String, dynamic>;
    final meta = data['meta'] as Map<String, dynamic>;

    final prayers = <PrayerTimeModel>[];
    final prayerOrder = ['Fajr', 'Sunrise', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    final typeMap = {
      'Fajr': 'fajr',
      'Sunrise': 'sunrise',
      'Dhuhr': 'dhuhr',
      'Asr': 'asr',
      'Maghrib': 'maghrib',
      'Isha': 'isha',
    };

    for (final name in prayerOrder) {
      final timeStr = timings[name] as String;
      // Aladhan returns times like "05:30 (EET)" — extract time only
      final cleanTime = timeStr.split(' ').first;
      final fullDateStr = '$dateStr $cleanTime:00';

      prayers.add(PrayerTimeModel(
        name: name,
        time: DateTime.parse(fullDateStr).toIso8601String(),
        type: typeMap[name]!,
      ));
    }

    return DailyPrayerScheduleModel(
      date: date.toIso8601String(),
      hijriDate: hijri['date'] as String? ?? '',
      hijriMonth: (hijri['month'] as Map<String, dynamic>?)?['en'] as String? ?? '',
      hijriYear: int.tryParse(hijri['year'] as String? ?? '0') ?? 0,
      prayers: prayers,
      location: meta['timezone'] as String? ?? '',
      latitude: latitude,
      longitude: longitude,
      calculationMethod: method,
    );
  }
}

/// Prayer Local Data Source — Hive + SharedPreferences for caching and preferences
class PrayerLocalDataSource {
  final Box _cacheBox;
  final SharedPreferences _prefs;

  PrayerLocalDataSource({
    required Box cacheBox,
    required SharedPreferences prefs,
  })  : _cacheBox = cacheBox,
        _prefs = prefs;

  static const String _keyPrayerCache = 'prayer_schedule_cache';
  static const String _keyCalcMethod = 'prayer_calculation_method';
  static const String _keyLatitude = 'prayer_latitude';
  static const String _keyLongitude = 'prayer_longitude';

  /// Get cached prayer schedule for today
  DailyPrayerScheduleModel? getCachedPrayerSchedule() {
    final raw = _cacheBox.get(_keyPrayerCache) as String?;
    if (raw == null) return null;
    return DailyPrayerScheduleModel.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  /// Cache prayer schedule
  Future<void> cachePrayerSchedule(DailyPrayerScheduleModel schedule) async {
    await _cacheBox.put(
      _keyPrayerCache,
      jsonEncode(schedule.toJson()),
    );
  }

  /// Get calculation method preference
  String getCalculationMethod() {
    return _prefs.getString(_keyCalcMethod) ?? '4'; // Default: Umm Al-Qura
  }

  /// Save calculation method preference
  Future<void> saveCalculationMethod(String method) async {
    await _prefs.setString(_keyCalcMethod, method);
  }

  /// Get saved location
  ({double latitude, double longitude})? getSavedLocation() {
    final lat = _prefs.getDouble(_keyLatitude);
    final lng = _prefs.getDouble(_keyLongitude);
    if (lat == null || lng == null) return null;
    return (latitude: lat, longitude: lng);
  }

  /// Save location
  Future<void> saveLocation({required double latitude, required double longitude}) async {
    await _prefs.setDouble(_keyLatitude, latitude);
    await _prefs.setDouble(_keyLongitude, longitude);
  }
}
