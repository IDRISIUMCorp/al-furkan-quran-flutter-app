// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'surah_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SurahModelImpl _$$SurahModelImplFromJson(Map<String, dynamic> json) =>
    _$SurahModelImpl(
      id: (json['id'] as num).toInt(),
      nameArabic: json['nameArabic'] as String,
      nameEnglish: json['nameEnglish'] as String,
      nameTransliteration: json['nameTransliteration'] as String,
      totalAyahs: (json['totalAyahs'] as num).toInt(),
      totalPages: (json['totalPages'] as num).toInt(),
      startPage: (json['startPage'] as num).toInt(),
      revelationType: json['revelationType'] as String,
      rukuCount: (json['rukuCount'] as num?)?.toInt() ?? 0,
      manzilOrder: (json['manzilOrder'] as num?)?.toInt() ?? 0,
      sajdaCount: (json['sajdaCount'] as num?)?.toInt() ?? 0,
      sajdaType: json['sajdaType'] as String? ?? '',
    );

Map<String, dynamic> _$$SurahModelImplToJson(_$SurahModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameArabic': instance.nameArabic,
      'nameEnglish': instance.nameEnglish,
      'nameTransliteration': instance.nameTransliteration,
      'totalAyahs': instance.totalAyahs,
      'totalPages': instance.totalPages,
      'startPage': instance.startPage,
      'revelationType': instance.revelationType,
      'rukuCount': instance.rukuCount,
      'manzilOrder': instance.manzilOrder,
      'sajdaCount': instance.sajdaCount,
      'sajdaType': instance.sajdaType,
    };
