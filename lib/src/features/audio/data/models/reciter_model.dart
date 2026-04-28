import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/reciter.dart';

part 'reciter_model.freezed.dart';
part 'reciter_model.g.dart';

/// Reciter Model — Data layer representation with JSON serialization
@freezed
class ReciterModel with _$ReciterModel {
  const ReciterModel._();

  const factory ReciterModel({
    required int id,
    required String nameArabic,
    required String nameEnglish,
    required String serverUrl,
    required String style, // ReciterStyle name
    @Default(false) bool isOfflineAvailable,
    @Default(0) int downloadedSurahs,
  }) = _ReciterModel;

  factory ReciterModel.fromJson(Map<String, dynamic> json) =>
      _$ReciterModelFromJson(json);

  /// Convert to domain entity
  Reciter toDomain() => Reciter(
        id: id,
        nameArabic: nameArabic,
        nameEnglish: nameEnglish,
        serverUrl: serverUrl,
        style: ReciterStyle.values.firstWhere(
          (e) => e.name == style,
          orElse: () => ReciterStyle.murattal,
        ),
        isOfflineAvailable: isOfflineAvailable,
        downloadedSurahs: downloadedSurahs,
      );

  /// Create from domain entity
  factory ReciterModel.fromDomain(Reciter reciter) => ReciterModel(
        id: reciter.id,
        nameArabic: reciter.nameArabic,
        nameEnglish: reciter.nameEnglish,
        serverUrl: reciter.serverUrl,
        style: reciter.style.name,
        isOfflineAvailable: reciter.isOfflineAvailable,
        downloadedSurahs: reciter.downloadedSurahs,
      );
}
