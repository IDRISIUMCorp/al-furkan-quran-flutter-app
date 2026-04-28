// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hifz_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$HifzProgressModelImpl _$$HifzProgressModelImplFromJson(
  Map<String, dynamic> json,
) => _$HifzProgressModelImpl(
  surahId: (json['surahId'] as num).toInt(),
  ayahStart: (json['ayahStart'] as num).toInt(),
  ayahEnd: (json['ayahEnd'] as num).toInt(),
  totalAyahs: (json['totalAyahs'] as num).toInt(),
  lastReviewed: json['lastReviewed'] as String,
  mastery: json['mastery'] as String,
  reviewCount: (json['reviewCount'] as num).toInt(),
  correctCount: (json['correctCount'] as num).toInt(),
  mistakeCount: (json['mistakeCount'] as num).toInt(),
);

Map<String, dynamic> _$$HifzProgressModelImplToJson(
  _$HifzProgressModelImpl instance,
) => <String, dynamic>{
  'surahId': instance.surahId,
  'ayahStart': instance.ayahStart,
  'ayahEnd': instance.ayahEnd,
  'totalAyahs': instance.totalAyahs,
  'lastReviewed': instance.lastReviewed,
  'mastery': instance.mastery,
  'reviewCount': instance.reviewCount,
  'correctCount': instance.correctCount,
  'mistakeCount': instance.mistakeCount,
};

_$HifzSessionModelImpl _$$HifzSessionModelImplFromJson(
  Map<String, dynamic> json,
) => _$HifzSessionModelImpl(
  id: (json['id'] as num).toInt(),
  surahId: (json['surahId'] as num).toInt(),
  ayahStart: (json['ayahStart'] as num).toInt(),
  ayahEnd: (json['ayahEnd'] as num).toInt(),
  date: json['date'] as String,
  durationSeconds: (json['durationSeconds'] as num).toInt(),
  mistakes: (json['mistakes'] as num).toInt(),
  hints: (json['hints'] as num).toInt(),
  type: json['type'] as String,
);

Map<String, dynamic> _$$HifzSessionModelImplToJson(
  _$HifzSessionModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'surahId': instance.surahId,
  'ayahStart': instance.ayahStart,
  'ayahEnd': instance.ayahEnd,
  'date': instance.date,
  'durationSeconds': instance.durationSeconds,
  'mistakes': instance.mistakes,
  'hints': instance.hints,
  'type': instance.type,
};
