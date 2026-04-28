// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bookmark_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$BookmarkModelImpl _$$BookmarkModelImplFromJson(Map<String, dynamic> json) =>
    _$BookmarkModelImpl(
      id: json['id'] as String,
      ayahKey: json['ayahKey'] as String,
      surahId: (json['surahId'] as num).toInt(),
      ayahNumber: (json['ayahNumber'] as num).toInt(),
      page: (json['page'] as num).toInt(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      note: json['note'] as String? ?? null,
      type: json['type'] as String,
    );

Map<String, dynamic> _$$BookmarkModelImplToJson(_$BookmarkModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'ayahKey': instance.ayahKey,
      'surahId': instance.surahId,
      'ayahNumber': instance.ayahNumber,
      'page': instance.page,
      'createdAt': instance.createdAt.toIso8601String(),
      'note': instance.note,
      'type': instance.type,
    };
