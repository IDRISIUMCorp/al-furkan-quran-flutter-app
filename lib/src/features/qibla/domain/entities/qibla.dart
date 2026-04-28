import 'dart:math' as math;

/// Qibla Entity — Pure Dart, ZERO Flutter imports
/// dart:math is Dart SDK core, not Flutter — allowed in domain layer
class QiblaInfo {
  final double latitude;
  final double longitude;
  final double qiblaBearing; // Degrees from North clockwise
  final String locationName;
  final bool isCompassAvailable;

  const QiblaInfo({
    required this.latitude,
    required this.longitude,
    required this.qiblaBearing,
    required this.locationName,
    this.isCompassAvailable = true,
  });

  /// Kaaba coordinates for bearing calculation
  static const double kaabaLatitude = 21.4225;
  static const double kaabaLongitude = 39.8262;

  /// Calculate Qibla bearing from any point on Earth
  static double calculateBearing(double lat, double lng) {
    final latR = lat * _degToRad;
    final lngR = lng * _degToRad;
    final kaabaLatR = kaabaLatitude * _degToRad;
    final kaabaLngR = kaabaLongitude * _degToRad;

    final dLng = kaabaLngR - lngR;
    final y = math.sin(dLng);
    final x = math.cos(latR) * math.tan(kaabaLatR) - math.sin(latR) * math.cos(dLng);
    final bearing = math.atan2(y, x);

    return (bearing * _radToDeg + 360) % 360;
  }

  static const double _degToRad = math.pi / 180;
  static const double _radToDeg = 180 / math.pi;
}
