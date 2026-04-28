import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/prayer_time.dart';

part 'prayer_time_model.freezed.dart';
part 'prayer_time_model.g.dart';

/// Prayer Time Model — Data layer representation with JSON serialization
@freezed
class PrayerTimeModel with _$PrayerTimeModel {
  const PrayerTimeModel._();

  const factory PrayerTimeModel({
    required String name,
    required String time, // ISO 8601 string
    required String type, // PrayerType name
    @Default(false) bool isCurrent,
  }) = _PrayerTimeModel;

  factory PrayerTimeModel.fromJson(Map<String, dynamic> json) =>
      _$PrayerTimeModelFromJson(json);

  /// Convert to domain entity
  PrayerTime toDomain() => PrayerTime(
        name: name,
        time: DateTime.parse(time),
        isCurrent: isCurrent,
        type: PrayerType.values.firstWhere(
          (e) => e.name == type,
          orElse: () => PrayerType.fajr,
        ),
      );

  /// Create from domain entity
  factory PrayerTimeModel.fromDomain(PrayerTime prayer) => PrayerTimeModel(
        name: prayer.name,
        time: prayer.time.toIso8601String(),
        type: prayer.type.name,
        isCurrent: prayer.isCurrent,
      );
}

/// Daily Prayer Schedule Model — Data layer representation
@freezed
class DailyPrayerScheduleModel with _$DailyPrayerScheduleModel {
  const DailyPrayerScheduleModel._();

  const factory DailyPrayerScheduleModel({
    required String date, // ISO 8601
    required String hijriDate,
    required String hijriMonth,
    required int hijriYear,
    required List<PrayerTimeModel> prayers,
    required String location,
    required double latitude,
    required double longitude,
    required String calculationMethod,
  }) = _DailyPrayerScheduleModel;

  factory DailyPrayerScheduleModel.fromJson(Map<String, dynamic> json) =>
      _$DailyPrayerScheduleModelFromJson(json);

  /// Convert to domain entity
  DailyPrayerSchedule toDomain() => DailyPrayerSchedule(
        date: DateTime.parse(date),
        hijriDate: hijriDate,
        hijriMonth: hijriMonth,
        hijriYear: hijriYear,
        prayers: prayers.map((p) => p.toDomain()).toList(),
        location: location,
        latitude: latitude,
        longitude: longitude,
        calculationMethod: calculationMethod,
      );

  /// Create from domain entity
  factory DailyPrayerScheduleModel.fromDomain(DailyPrayerSchedule schedule) =>
      DailyPrayerScheduleModel(
        date: schedule.date.toIso8601String(),
        hijriDate: schedule.hijriDate,
        hijriMonth: schedule.hijriMonth,
        hijriYear: schedule.hijriYear,
        prayers: schedule.prayers
            .map((p) => PrayerTimeModel.fromDomain(p))
            .toList(),
        location: schedule.location,
        latitude: schedule.latitude,
        longitude: schedule.longitude,
        calculationMethod: schedule.calculationMethod,
      );
}
