/// Prayer Time Entity — Pure Dart, ZERO Flutter imports
class PrayerTime {
  final String name;
  final DateTime time;
  final bool isCurrent;
  final PrayerType type;

  const PrayerTime({
    required this.name,
    required this.time,
    this.isCurrent = false,
    required this.type,
  });
}

enum PrayerType {
  fajr,
  sunrise,
  dhuhr,
  asr,
  maghrib,
  isha,
}

/// Daily Prayer Schedule Entity
class DailyPrayerSchedule {
  final DateTime date;
  final String hijriDate;
  final String hijriMonth;
  final int hijriYear;
  final List<PrayerTime> prayers;
  final String location;
  final double latitude;
  final double longitude;
  final String calculationMethod;

  const DailyPrayerSchedule({
    required this.date,
    required this.hijriDate,
    required this.hijriMonth,
    required this.hijriYear,
    required this.prayers,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.calculationMethod,
  });

  /// Get the next upcoming prayer
  PrayerTime? get nextPrayer {
    final now = DateTime.now();
    for (final prayer in prayers) {
      if (prayer.time.isAfter(now)) return prayer;
    }
    return null;
  }

  /// Get the current or most recent prayer
  PrayerTime? get currentPrayer {
    final now = DateTime.now();
    PrayerTime? current;
    for (final prayer in prayers) {
      if (!prayer.time.isAfter(now)) {
        current = prayer;
      }
    }
    return current;
  }
}
