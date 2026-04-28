import 'package:shared_preferences/shared_preferences.dart';

/// Qibla Local Data Source — SharedPreferences for location persistence
class QiblaLocalDataSource {
  final SharedPreferences _prefs;

  QiblaLocalDataSource({required SharedPreferences prefs}) : _prefs = prefs;

  static const String _keyLatitude = 'qibla_latitude';
  static const String _keyLongitude = 'qibla_longitude';

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

  /// Check if device compass is available
  /// Actual check uses FlutterCompass plugin — this returns cached state
  bool isCompassAvailable() {
    return _prefs.getBool('qibla_compass_available') ?? true;
  }

  /// Save compass availability
  Future<void> saveCompassAvailability(bool available) async {
    await _prefs.setBool('qibla_compass_available', available);
  }
}
