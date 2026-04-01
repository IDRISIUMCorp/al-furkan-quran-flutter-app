import "dart:math" as math;

const double kaabaLatDegrees = 21.422487;
const double kaabaLonDegrees = 39.826206;

enum QiblaAlignment { aligned, close, adjusting }

enum QiblaTurn { left, right, none }

class QiblaGuidance {
  final double heading;
  final double bearing;
  final double signedDifference;
  final double absoluteDifference;
  final QiblaAlignment alignment;
  final QiblaTurn turn;
  final double progress;

  const QiblaGuidance({
    required this.heading,
    required this.bearing,
    required this.signedDifference,
    required this.absoluteDifference,
    required this.alignment,
    required this.turn,
    required this.progress,
  });

  bool get isAligned => alignment == QiblaAlignment.aligned;
  bool get isClose => alignment != QiblaAlignment.adjusting;
}

double normalizeDegrees(double value) {
  return (value % 360 + 360) % 360;
}

double shortestSignedAngleDifference(double fromDegrees, double toDegrees) {
  final normalized = normalizeDegrees(toDegrees - fromDegrees);
  return normalized > 180 ? normalized - 360 : normalized;
}

double smoothHeading({
  required double nextDegrees,
  double? previousDegrees,
  double factor = 0.18,
  double jitterThreshold = 0.6,
}) {
  final normalizedNext = normalizeDegrees(nextDegrees);
  if (previousDegrees == null) return normalizedNext;

  final delta = shortestSignedAngleDifference(previousDegrees, normalizedNext);
  if (delta.abs() <= jitterThreshold) return previousDegrees;

  return normalizeDegrees(previousDegrees + (delta * factor));
}

double calculateQiblaAngle(double userLat, double userLon) {
  if (userLat == kaabaLatDegrees && userLon == kaabaLonDegrees) {
    return -1.0;
  }

  final double userLatRad = userLat * math.pi / 180.0;
  final double userLonRad = userLon * math.pi / 180.0;
  final double kaabaLatRad = kaabaLatDegrees * math.pi / 180.0;
  final double kaabaLonRad = kaabaLonDegrees * math.pi / 180.0;

  final deltaLon = kaabaLonRad - userLonRad;
  final y = math.sin(deltaLon) * math.cos(kaabaLatRad);
  final x =
      math.cos(userLatRad) * math.sin(kaabaLatRad) -
      math.sin(userLatRad) * math.cos(kaabaLatRad) * math.cos(deltaLon);

  final bearing = math.atan2(y, x) * 180.0 / math.pi;
  return normalizeDegrees(bearing);
}

QiblaGuidance resolveQiblaGuidance({
  required double headingDegrees,
  required double qiblaDegrees,
}) {
  final heading = normalizeDegrees(headingDegrees);
  final bearing = normalizeDegrees(qiblaDegrees);
  final signedDifference = shortestSignedAngleDifference(heading, bearing);
  final absoluteDifference = signedDifference.abs();

  final QiblaAlignment alignment;
  if (absoluteDifference <= 4) {
    alignment = QiblaAlignment.aligned;
  } else if (absoluteDifference <= 12) {
    alignment = QiblaAlignment.close;
  } else {
    alignment = QiblaAlignment.adjusting;
  }

  final turn = absoluteDifference <= 1
      ? QiblaTurn.none
      : signedDifference > 0
      ? QiblaTurn.right
      : QiblaTurn.left;

  final progress = (1 - (absoluteDifference / 90)).clamp(0.0, 1.0);

  return QiblaGuidance(
    heading: heading,
    bearing: bearing,
    signedDifference: signedDifference,
    absoluteDifference: absoluteDifference,
    alignment: alignment,
    turn: turn,
    progress: progress,
  );
}
