import "package:adhan_dart/adhan_dart.dart";
import "package:al_furkan/src/screen/prayer_time/models/calculation_method_enum.dart";
import "package:al_furkan/src/screen/location_handler/model/lat_lon.dart";
import "package:al_furkan/src/screen/location_handler/model/location_data_qibla_data_state.dart";
import "package:al_furkan/src/screen/qibla/qibla_guidance.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:geolocator/geolocator.dart";
import "package:hive_ce_flutter/hive_flutter.dart";
import "package:shared_preferences/shared_preferences.dart";

class LocationQiblaPrayerDataCubit extends Cubit<LocationQiblaPrayerDataState> {
  LocationQiblaPrayerDataCubit({
    required LocationQiblaPrayerDataState initState,
  }) : super(initState);

  Future<void> getLocation() async {
    emit(state.copyWith(isGettingLocation: true));
    try {
      final Position position = await Geolocator.getCurrentPosition();
      await saveLocationData(
        LatLon(latitude: position.latitude, longitude: position.longitude),
        save: true,
      );
      emit(state.copyWith(isGettingLocation: false));
    } catch (e) {
      emit(state.copyWith(isGettingLocation: false));
    }
  }

  Future<void> alignWithDatabase() async {
    emit(await getSavedState());
  }

  Future<void> saveLocationData(LatLon latLon, {bool save = true}) async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (save) {
      await sharedPreferences.setString("user_location", latLon.toJson());
    }
    emit(
      state.copyWith(
        latLon: latLon,
        kaabaAngle: calculateQiblaAngle(latLon.latitude, latLon.longitude),
      ),
    );
  }

  Future<void> saveCalculationMethod(
    CalculationParameters calculationMethod, {
    bool save = true,
  }) async {
    if (save) {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString(
        "selected_calculation_method",
        calculationMethod.method.name,
      );
    }
    emit(state.copyWith(calculationMethod: calculationMethod));
  }

  Future<void> saveMadhab(Madhab madhab, {bool save = true}) async {
    if (save) {
      final SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      sharedPreferences.setString("selected_madhab", madhab.name);
    }
    emit(state.copyWith(madhab: madhab));
  }

  void changePrayerTimeDownloading(bool value) {
    emit(state.copyWith(isPrayerTimeDownloading: value));
  }

  static Future<LocationQiblaPrayerDataState> getSavedState() async {
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    String? jsonLocation = sharedPreferences.getString("user_location");
    if (jsonLocation == null) {
      jsonLocation = Hive.box("user").get("user_location", defaultValue: null);
      if (jsonLocation != null) {
        await sharedPreferences.setString("user_location", jsonLocation);
      }
    }

    if (jsonLocation == null) {
      return const LocationQiblaPrayerDataState();
    }

    final latLong = LatLon.fromJson(jsonLocation);
    final calculationMethodJson = sharedPreferences.getString(
      "selected_calculation_method",
    );
    final calculationMethod = calculationMethodJson != null
        ? getCalculationParameters(
            CalculationMethodEnum.values.firstWhere(
              (element) => element.name == calculationMethodJson,
            ),
          )
        : getCalculationParameters(CalculationMethodEnum.egyptian);

    final madhabJson = sharedPreferences.getString("selected_madhab");
    final madhab = madhabJson != null
        ? Madhab.values.firstWhere((element) => element.name == madhabJson)
        : Madhab.shafi;

    return LocationQiblaPrayerDataState(
      latLon: latLong,
      kaabaAngle: calculateQiblaAngle(latLong.latitude, latLong.longitude),
      calculationMethod: calculationMethod,
      madhab: madhab,
    );
  }
}
