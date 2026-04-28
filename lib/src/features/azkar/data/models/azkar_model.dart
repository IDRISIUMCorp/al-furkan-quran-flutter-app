import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/azkar.dart';

part 'azkar_model.freezed.dart';
part 'azkar_model.g.dart';

/// Azkar Category Model — Data layer representation
@freezed
class AzkarCategoryModel with _$AzkarCategoryModel {
  const AzkarCategoryModel._();

  const factory AzkarCategoryModel({
    required int id,
    required String nameArabic,
    required String nameEnglish,
    required String iconKey,
    required int azkarCount,
  }) = _AzkarCategoryModel;

  factory AzkarCategoryModel.fromJson(Map<String, dynamic> json) =>
      _$AzkarCategoryModelFromJson(json);

  AzkarCategory toDomain() => AzkarCategory(
        id: id,
        nameArabic: nameArabic,
        nameEnglish: nameEnglish,
        iconKey: iconKey,
        azkarCount: azkarCount,
      );

  factory AzkarCategoryModel.fromDomain(AzkarCategory c) => AzkarCategoryModel(
        id: c.id,
        nameArabic: c.nameArabic,
        nameEnglish: c.nameEnglish,
        iconKey: c.iconKey,
        azkarCount: c.azkarCount,
      );
}

/// Azkar Item Model — Data layer representation
@freezed
class AzkarItemModel with _$AzkarItemModel {
  const AzkarItemModel._();

  const factory AzkarItemModel({
    required int id,
    required int categoryId,
    required String textArabic,
    String? textTransliteration,
    String? textTranslation,
    required int count,
    String? reference,
    required String type, // AzkarType name
    String? audioAsset,
  }) = _AzkarItemModel;

  factory AzkarItemModel.fromJson(Map<String, dynamic> json) =>
      _$AzkarItemModelFromJson(json);

  AzkarItem toDomain() => AzkarItem(
        id: id,
        categoryId: categoryId,
        textArabic: textArabic,
        textTransliteration: textTransliteration,
        textTranslation: textTranslation,
        count: count,
        reference: reference,
        type: AzkarType.values.firstWhere(
          (e) => e.name == type,
          orElse: () => AzkarType.general,
        ),
        audioAsset: audioAsset,
      );

  factory AzkarItemModel.fromDomain(AzkarItem i) => AzkarItemModel(
        id: i.id,
        categoryId: i.categoryId,
        textArabic: i.textArabic,
        textTransliteration: i.textTransliteration,
        textTranslation: i.textTranslation,
        count: i.count,
        reference: i.reference,
        type: i.type.name,
        audioAsset: i.audioAsset,
      );
}
