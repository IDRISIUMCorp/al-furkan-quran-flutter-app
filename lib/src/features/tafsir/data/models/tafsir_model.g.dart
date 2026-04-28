// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tafsir_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TafsirModelImpl _$$TafsirModelImplFromJson(Map<String, dynamic> json) =>
    _$TafsirModelImpl(
      id: (json['id'] as num).toInt(),
      nameArabic: json['nameArabic'] as String,
      nameEnglish: json['nameEnglish'] as String,
      authorArabic: json['authorArabic'] as String,
      authorEnglish: json['authorEnglish'] as String,
      languageCode: json['languageCode'] as String,
      type: json['type'] as String,
      isOfflineAvailable: json['isOfflineAvailable'] as bool? ?? false,
    );

Map<String, dynamic> _$$TafsirModelImplToJson(_$TafsirModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nameArabic': instance.nameArabic,
      'nameEnglish': instance.nameEnglish,
      'authorArabic': instance.authorArabic,
      'authorEnglish': instance.authorEnglish,
      'languageCode': instance.languageCode,
      'type': instance.type,
      'isOfflineAvailable': instance.isOfflineAvailable,
    };

_$TafsirEntryModelImpl _$$TafsirEntryModelImplFromJson(
  Map<String, dynamic> json,
) => _$TafsirEntryModelImpl(
  ayahKey: json['ayahKey'] as String,
  tafsirId: (json['tafsirId'] as num).toInt(),
  text: json['text'] as String,
  footnotes: json['footnotes'] as String?,
);

Map<String, dynamic> _$$TafsirEntryModelImplToJson(
  _$TafsirEntryModelImpl instance,
) => <String, dynamic>{
  'ayahKey': instance.ayahKey,
  'tafsirId': instance.tafsirId,
  'text': instance.text,
  'footnotes': instance.footnotes,
};
