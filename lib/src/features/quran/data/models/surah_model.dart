import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/entities.dart';

part 'surah_model.freezed.dart';
part 'surah_model.g.dart';

/// Surah Data Model — freezed + json_serializable for data layer
@freezed
class SurahModel with _$SurahModel {
  const SurahModel._();

  const factory SurahModel({
    required int id,
    required String nameArabic,
    required String nameEnglish,
    required String nameTransliteration,
    required int totalAyahs,
    required int totalPages,
    required int startPage,
    required String revelationType,
    @Default(0) int rukuCount,
    @Default(0) int manzilOrder,
    @Default(0) int sajdaCount,
    @Default('') String sajdaType,
  }) = _SurahModel;

  factory SurahModel.fromJson(Map<String, dynamic> json) =>
      _$SurahModelFromJson(json);

  /// Convert data model to domain entity
  Surah toDomain() => Surah(
        id: id,
        nameArabic: nameArabic,
        nameEnglish: nameEnglish,
        nameTransliteration: nameTransliteration,
        totalAyahs: totalAyahs,
        totalPages: totalPages,
        startPage: startPage,
        revelationType: revelationType == 'Meccan'
            ? RevelationType.meccan
            : RevelationType.medinan,
        rukuCount: rukuCount,
        manzilOrder: manzilOrder,
        sajdaCount: sajdaCount,
        sajdaType: sajdaType == 'obligatory'
            ? SajdaType.obligatory
            : sajdaType == 'recommended'
                ? SajdaType.recommended
                : null,
      );

  /// Convert domain entity to data model
  static SurahModel fromDomain(Surah surah) => SurahModel(
        id: surah.id,
        nameArabic: surah.nameArabic,
        nameEnglish: surah.nameEnglish,
        nameTransliteration: surah.nameTransliteration,
        totalAyahs: surah.totalAyahs,
        totalPages: surah.totalPages,
        startPage: surah.startPage,
        revelationType: surah.revelationType == RevelationType.meccan
            ? 'Meccan'
            : 'Medinan',
        rukuCount: surah.rukuCount,
        manzilOrder: surah.manzilOrder,
        sajdaCount: surah.sajdaCount,
        sajdaType: surah.sajdaType?.name ?? '',
      );
}
