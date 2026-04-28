// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reciter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ReciterModelImpl _$$ReciterModelImplFromJson(Map<String, dynamic> json) =>
    _$ReciterModelImpl(
      id: (json['id'] as num).toInt(),
      nameArabic: json['nameArabic'] as String,
      nameEnglish: json['nameEnglish'] as String,
      serverUrl: json['serverUrl'] as String,
      style: json['style'] as String,
      isOfflineAvailable: json['isOfflineAvailable'] as bool? ?? false,
      downloadedSurahs: (json['downloadedSurahs'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ReciterModelImplToJson(_$ReciterModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameArabic': instance.nameArabic,
      'nameEnglish': instance.nameEnglish,
      'serverUrl': instance.serverUrl,
      'style': instance.style,
      'isOfflineAvailable': instance.isOfflineAvailable,
      'downloadedSurahs': instance.downloadedSurahs,
    };
