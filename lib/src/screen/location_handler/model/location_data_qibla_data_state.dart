import "package:flutter/foundation.dart";
import "package:adhan_dart/adhan_dart.dart";
import "package:al_furkan/src/screen/location_handler/model/lat_lon.dart";

@immutable
class LocationQiblaPrayerDataState {
  final LatLon? latLon;
  final double? kaabaAngle;
  final CalculationParameters? calculationMethod;
  final bool isPrayerTimeDownloading;
  final bool isGettingLocation;
  final Madhab? madhab;

  const LocationQiblaPrayerDataState({
    this.latLon,
    this.kaabaAngle,
    this.calculationMethod,
    this.isPrayerTimeDownloading = false,
    this.isGettingLocation = false,
    this.madhab,
  });

  LocationQiblaPrayerDataState copyWith({
    LatLon? latLon,
    double? kaabaAngle,
    CalculationParameters? calculationMethod,
    bool? isPrayerTimeDownloading,
    bool? isGettingLocation,
    Madhab? madhab,
  }) {
    return LocationQiblaPrayerDataState(
      latLon: latLon ?? this.latLon,
      kaabaAngle: kaabaAngle ?? this.kaabaAngle,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      isPrayerTimeDownloading:
          isPrayerTimeDownloading ?? this.isPrayerTimeDownloading,
      isGettingLocation: isGettingLocation ?? this.isGettingLocation,
      madhab: madhab ?? this.madhab,
    );
  }
}
