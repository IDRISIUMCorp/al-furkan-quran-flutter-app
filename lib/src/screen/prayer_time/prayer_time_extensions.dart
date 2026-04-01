import "package:adhan_dart/adhan_dart.dart" hide Prayer;
import "package:al_quran_v3/src/screen/prayer_time/models/prayer_enum.dart";

extension PrayerTimesExtensions on PrayerTimes {
  DateTime _toLocalTime(DateTime value) =>
      value.isUtc ? value.toLocal() : value;

  DateTime get fajrLocal => _toLocalTime(fajr);

  DateTime get sunriseLocal => _toLocalTime(sunrise);

  DateTime get dhuhrLocal => _toLocalTime(dhuhr);

  DateTime get asrLocal => _toLocalTime(asr);

  DateTime get maghribLocal => _toLocalTime(maghrib);

  DateTime get ishaLocal => _toLocalTime(isha);

  DateTime get ishaBeforeLocal => _toLocalTime(ishaBefore);

  DateTime get fajrAfterLocal => _toLocalTime(fajrAfter);

  DateTime get dhuha => sunriseLocal.add(const Duration(minutes: 20));

  DateTime get noon => dhuhrLocal;

  DateTime get sunset => maghribLocal;

  DateTime get tahajjud => _toLocalTime(SunnahTimes(this).lastThirdOfTheNight);

  DateTime? timeForCustomPrayer(Prayer prayer) {
    switch (prayer) {
      case Prayer.fajr:
        return fajrLocal;
      case Prayer.sunrise:
        return sunriseLocal;
      case Prayer.dhuhr:
        return dhuhrLocal;
      case Prayer.asr:
        return asrLocal;
      case Prayer.maghrib:
        return maghribLocal;
      case Prayer.isha:
        return ishaLocal;
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
    final localTime = time.isUtc ? time.toLocal() : time;
    if (localTime.isAfter(sunriseLocal) &&
        localTime.isBefore(sunriseLocal.add(const Duration(minutes: 15)))) {
      return true;
    }

    if (localTime.isAfter(dhuhrLocal.subtract(const Duration(minutes: 10))) &&
        localTime.isBefore(dhuhrLocal)) {
      return true;
    }

    if (localTime.isAfter(maghribLocal.subtract(const Duration(minutes: 15))) &&
        localTime.isBefore(maghribLocal)) {
      return true;
    }

    return false;
  }

  DateTime nextPrayerDateTime({required DateTime now}) {
    final localNow = now.isUtc ? now.toLocal() : now;
    if (localNow.isBefore(fajrLocal)) return fajrLocal;
    if (localNow.isBefore(sunriseLocal)) return sunriseLocal;
    if (localNow.isBefore(dhuhrLocal)) return dhuhrLocal;
    if (localNow.isBefore(asrLocal)) return asrLocal;
    if (localNow.isBefore(maghribLocal)) return maghribLocal;
    if (localNow.isBefore(ishaLocal)) return ishaLocal;
    return fajrAfterLocal;
  }

  DateTime currentPrayerDateTime({required DateTime now}) {
    final localNow = now.isUtc ? now.toLocal() : now;
    if (localNow.isBefore(fajrLocal)) return ishaBeforeLocal;
    if (localNow.isBefore(sunriseLocal)) return fajrLocal;
    if (localNow.isBefore(dhuhrLocal)) return sunriseLocal;
    if (localNow.isBefore(asrLocal)) return dhuhrLocal;
    if (localNow.isBefore(maghribLocal)) return asrLocal;
    if (localNow.isBefore(ishaLocal)) return maghribLocal;
    return ishaLocal;
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
    final localDate = date.isUtc ? date.toLocal() : date;
    if (localDate.isBefore(fajrLocal)) return Prayer.fajr;
    if (localDate.isBefore(sunriseLocal)) return Prayer.sunrise;
    if (localDate.isBefore(dhuhrLocal)) return Prayer.dhuhr;
    if (localDate.isBefore(asrLocal)) return Prayer.asr;
    if (localDate.isBefore(maghribLocal)) return Prayer.maghrib;
    if (localDate.isBefore(ishaLocal)) return Prayer.isha;
    return Prayer.fajr;
  }

  Prayer currentPrayerExtension({required DateTime date}) {
    final localDate = date.isUtc ? date.toLocal() : date;
    if (localDate.isBefore(fajrLocal)) return Prayer.isha;
    if (localDate.isBefore(sunriseLocal)) return Prayer.fajr;
    if (localDate.isBefore(dhuhrLocal)) return Prayer.sunrise;
    if (localDate.isBefore(asrLocal)) return Prayer.dhuhr;
    if (localDate.isBefore(maghribLocal)) return Prayer.asr;
    if (localDate.isBefore(ishaLocal)) return Prayer.maghrib;
    return Prayer.isha;
  }
}
