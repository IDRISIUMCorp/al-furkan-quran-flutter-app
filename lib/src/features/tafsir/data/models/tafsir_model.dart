import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/tafsir.dart';

part 'tafsir_model.freezed.dart';
part 'tafsir_model.g.dart';

/// Tafsir Model — Data layer representation with JSON serialization
@freezed
class TafsirModel with _$TafsirModel {
  const TafsirModel._();

  const factory TafsirModel({
    required int id,
    required String nameArabic,
    required String nameEnglish,
    required String authorArabic,
    required String authorEnglish,
    required String languageCode,
    required String type, // TafsirType name
    @Default(false) bool isOfflineAvailable,
  }) = _TafsirModel;

  factory TafsirModel.fromJson(Map<String, dynamic> json) =>
      _$TafsirModelFromJson(json);

  /// Convert to domain entity
  Tafsir toDomain() => Tafsir(
        id: id,
        nameArabic: nameArabic,
        nameEnglish: nameEnglish,
        authorArabic: authorArabic,
        authorEnglish: authorEnglish,
        languageCode: languageCode,
        type: TafsirType.values.firstWhere(
          (e) => e.name == type,
          orElse: () => TafsirType.translation,
        ),
        isOfflineAvailable: isOfflineAvailable,
      );

  /// Create from domain entity
  factory TafsirModel.fromDomain(Tafsir tafsir) => TafsirModel(
        id: tafsir.id,
        nameArabic: tafsir.nameArabic,
        nameEnglish: tafsir.nameEnglish,
        authorArabic: tafsir.authorArabic,
        authorEnglish: tafsir.authorEnglish,
        languageCode: tafsir.languageCode,
        type: tafsir.type.name,
        isOfflineAvailable: tafsir.isOfflineAvailable,
      );
}

/// Tafsir Entry Model — single ayah's tafsir content
@freezed
class TafsirEntryModel with _$TafsirEntryModel {
  const TafsirEntryModel._();

  const factory TafsirEntryModel({
    required String ayahKey,
    required int tafsirId,
    required String text,
    String? footnotes,
  }) = _TafsirEntryModel;

  factory TafsirEntryModel.fromJson(Map<String, dynamic> json) =>
      _$TafsirEntryModelFromJson(json);

  /// Convert to domain entity
  TafsirEntry toDomain() => TafsirEntry(
        ayahKey: ayahKey,
        tafsirId: tafsirId,
        text: text,
        footnotes: footnotes,
      );

  /// Create from domain entity
  factory TafsirEntryModel.fromDomain(TafsirEntry entry) => TafsirEntryModel(
        ayahKey: entry.ayahKey,
        tafsirId: entry.tafsirId,
        text: entry.text,
        footnotes: entry.footnotes,
      );
}
