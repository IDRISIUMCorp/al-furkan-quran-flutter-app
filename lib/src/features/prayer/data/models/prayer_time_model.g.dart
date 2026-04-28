// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prayer_time_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PrayerTimeModelImpl _$$PrayerTimeModelImplFromJson(
  Map<String, dynamic> json,
) => _$PrayerTimeModelImpl(
  name: json['name'] as String,
  time: json['time'] as String,
  type: json['type'] as String,
  isCurrent: json['isCurrent'] as bool? ?? false,
);

Map<String, dynamic> _$$PrayerTimeModelImplToJson(
  _$PrayerTimeModelImpl instance,
) => <String, dynamic>{
  'name': instance.name,
  'time': instance.time,
  'type': instance.type,
  'isCurrent': instance.isCurrent,
};

_$DailyPrayerScheduleModelImpl _$$DailyPrayerScheduleModelImplFromJson(
  Map<String, dynamic> json,
) => _$DailyPrayerScheduleModelImpl(
  date: json['date'] as String,
  hijriDate: json['hijriDate'] as String,
  hijriMonth: json['hijriMonth'] as String,
  hijriYear: (json['hijriYear'] as num).toInt(),
  prayers: (json['prayers'] as List<dynamic>)
      .map((e) => PrayerTimeModel.fromJson(e as Map<String, dynamic>))
      .toList(),
  location: json['location'] as String,
  latitude: (json['latitude'] as num).toDouble(),
  longitude: (json['longitude'] as num).toDouble(),
  calculationMethod: json['calculationMethod'] as String,
);

Map<String, dynamic> _$$DailyPrayerScheduleModelImplToJson(
  _$DailyPrayerScheduleModelImpl instance,
) => <String, dynamic>{
  'date': instance.date,
  'hijriDate': instance.hijriDate,
  'hijriMonth': instance.hijriMonth,
  'hijriYear': instance.hijriYear,
  'prayers': instance.prayers,
  'location': instance.location,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'calculationMethod': instance.calculationMethod,
};
