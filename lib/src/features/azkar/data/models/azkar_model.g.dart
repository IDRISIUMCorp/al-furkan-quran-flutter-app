// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'azkar_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AzkarCategoryModelImpl _$$AzkarCategoryModelImplFromJson(
  Map<String, dynamic> json,
) => _$AzkarCategoryModelImpl(
  id: (json['id'] as num).toInt(),
  nameArabic: json['nameArabic'] as String,
  nameEnglish: json['nameEnglish'] as String,
  iconKey: json['iconKey'] as String,
  azkarCount: (json['azkarCount'] as num).toInt(),
);

Map<String, dynamic> _$$AzkarCategoryModelImplToJson(
  _$AzkarCategoryModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'nameArabic': instance.nameArabic,
  'nameEnglish': instance.nameEnglish,
  'iconKey': instance.iconKey,
  'azkarCount': instance.azkarCount,
};

_$AzkarItemModelImpl _$$AzkarItemModelImplFromJson(Map<String, dynamic> json) =>
    _$AzkarItemModelImpl(
      id: (json['id'] as num).toInt(),
      categoryId: (json['categoryId'] as num).toInt(),
      textArabic: json['textArabic'] as String,
      textTransliteration: json['textTransliteration'] as String?,
      textTranslation: json['textTranslation'] as String?,
      count: (json['count'] as num).toInt(),
      reference: json['reference'] as String?,
      type: json['type'] as String,
      audioAsset: json['audioAsset'] as String?,
    );

Map<String, dynamic> _$$AzkarItemModelImplToJson(
  _$AzkarItemModelImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'categoryId': instance.categoryId,
  'textArabic': instance.textArabic,
  'textTransliteration': instance.textTransliteration,
  'textTranslation': instance.textTranslation,
  'count': instance.count,
  'reference': instance.reference,
  'type': instance.type,
  'audioAsset': instance.audioAsset,
};
