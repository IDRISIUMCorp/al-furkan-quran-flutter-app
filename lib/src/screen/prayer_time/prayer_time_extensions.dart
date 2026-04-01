import "package:adhan_dart/adhan_dart.dart" hide Prayer;
import "package:al_quran_v3/src/screen/prayer_time/models/prayer_enum.dart";

extension PrayerTimesExtensions on PrayerTimes {
  DateTime get dhuha => sunrise.add(const Duration(minutes: 20));

  DateTime get noon => dhuhr;

  DateTime get sunset => maghrib;

  DateTime get tahajjud {
    final fajrTomorrow = fajr.isAfter(maghrib)
        ? fajr
        : fajr.add(const Duration(days: 1));
    final nightDuration = fajrTomorrow.difference(maghrib);
    final seconds = (nightDuration.inSeconds * (2 / 3)).round();
    return maghrib.add(Duration(seconds: seconds));
  }

  DateTime? timeForCustomPrayer(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return fajr;
      case Prayer.sunrise:
        return sunrise;
      case Prayer.dhuhr:
        return dhuhr;
      case Prayer.asr:
        return asr;
      case Prayer.maghrib:
        return maghrib;
      case Prayer.isha:
        return isha;
      case Prayer.dhuha:
        return dhuha;
      case Prayer.noon:
        return noon;
      case Prayer.sunset:
        return sunset;
      case Prayer.tahajjud:
        return tahajjud;
      case Prayer.none:
        return null;
    }
  }

  bool isInsideForbiddenTime(DateTime time) {
    if (time.isAfter(sunrise) &&
        time.isBefore(sunrise.add(const Duration(minutes: 15)))) {
      return true;
    }

    if (time.isAfter(dhuhr.subtract(const Duration(minutes: 10))) &&
        time.isBefore(dhuhr)) {
      return true;
    }

    if (time.isAfter(maghrib.subtract(const Duration(minutes: 15))) &&
        time.isBefore(maghrib)) {
      return true;
    }

    return false;
  }

  DateTime nextPrayerDateTime({required DateTime now}) {
    if (now.isBefore(fajr)) return fajr;
    if (now.isBefore(sunrise)) return sunrise;
    if (now.isBefore(dhuhr)) return dhuhr;
    if (now.isBefore(asr)) return asr;
    if (now.isBefore(maghrib)) return maghrib;
    if (now.isBefore(isha)) return isha;
    return fajr.add(const Duration(days: 1));
  }

  DateTime currentPrayerDateTime({required DateTime now}) {
    if (now.isBefore(fajr)) return isha.subtract(const Duration(days: 1));
    if (now.isBefore(sunrise)) return fajr;
    if (now.isBefore(dhuhr)) return sunrise;
    if (now.isBefore(asr)) return dhuhr;
    if (now.isBefore(maghrib)) return asr;
    if (now.isBefore(isha)) return maghrib;
    return isha;
  }

  double percentageOfTimeLeftUntilNextPrayer({required DateTime now}) {
    final nextTime = nextPrayerDateTime(now: now);
    final currentTime = currentPrayerDateTime(now: now);
    final totalDuration = nextTime.difference(currentTime);
    final elapsed = now.difference(currentTime);

    if (totalDuration.inSeconds <= 0) return 0.0;

    final percentage = elapsed.inSeconds / totalDuration.inSeconds;
    return percentage.clamp(0.0, 1.0);
  }

  Duration timeUntilNextPrayer({required DateTime now}) {
    return nextPrayerDateTime(now: now).difference(now);
  }

  Prayer nextPrayerExtension({required DateTime date}) {
    if (date.isBefore(fajr)) return Prayer.fajr;
    if (date.isBefore(sunrise)) return Prayer.sunrise;
    if (date.isBefore(dhuhr)) return Prayer.dhuhr;
    if (date.isBefore(asr)) return Prayer.asr;
    if (date.isBefore(maghrib)) return Prayer.maghrib;
    if (date.isBefore(isha)) return Prayer.isha;
    return Prayer.fajr;
  }

  Prayer currentPrayerExtension({required DateTime date}) {
    if (date.isBefore(fajr)) return Prayer.isha;
    if (date.isBefore(sunrise)) return Prayer.fajr;
    if (date.isBefore(dhuhr)) return Prayer.sunrise;
    if (date.isBefore(asr)) return Prayer.dhuhr;
    if (date.isBefore(maghrib)) return Prayer.asr;
    if (date.isBefore(isha)) return Prayer.maghrib;
    return Prayer.isha;
  }
}
