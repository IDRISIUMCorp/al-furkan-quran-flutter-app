import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/hifz.dart';

part 'hifz_model.freezed.dart';
part 'hifz_model.g.dart';

/// Hifz Progress Model — Data layer representation
@freezed
class HifzProgressModel with _$HifzProgressModel {
  const HifzProgressModel._();

  const factory HifzProgressModel({
    required int surahId,
    required int ayahStart,
    required int ayahEnd,
    required int totalAyahs,
    required String lastReviewed, // ISO 8601
    required String mastery, // HifzMasteryLevel name
    required int reviewCount,
    required int correctCount,
    required int mistakeCount,
  }) = _HifzProgressModel;

  factory HifzProgressModel.fromJson(Map<String, dynamic> json) =>
      _$HifzProgressModelFromJson(json);

  HifzProgress toDomain() => HifzProgress(
        surahId: surahId,
        ayahStart: ayahStart,
        ayahEnd: ayahEnd,
        totalAyahs: totalAyahs,
        lastReviewed: DateTime.parse(lastReviewed),
        mastery: HifzMasteryLevel.values.firstWhere(
          (e) => e.name == mastery,
          orElse: () => HifzMasteryLevel.notStarted,
        ),
        reviewCount: reviewCount,
        correctCount: correctCount,
        mistakeCount: mistakeCount,
      );

  factory HifzProgressModel.fromDomain(HifzProgress p) => HifzProgressModel(
        surahId: p.surahId,
        ayahStart: p.ayahStart,
        ayahEnd: p.ayahEnd,
        totalAyahs: p.totalAyahs,
        lastReviewed: p.lastReviewed.toIso8601String(),
        mastery: p.mastery.name,
        reviewCount: p.reviewCount,
        correctCount: p.correctCount,
        mistakeCount: p.mistakeCount,
      );
}

/// Hifz Session Model — Data layer representation
@freezed
class HifzSessionModel with _$HifzSessionModel {
  const HifzSessionModel._();

  const factory HifzSessionModel({
    required int id,
    required int surahId,
    required int ayahStart,
    required int ayahEnd,
    required String date, // ISO 8601
    required int durationSeconds,
    required int mistakes,
    required int hints,
    required String type, // HifzSessionType name
  }) = _HifzSessionModel;

  factory HifzSessionModel.fromJson(Map<String, dynamic> json) =>
      _$HifzSessionModelFromJson(json);

  HifzSession toDomain() => HifzSession(
        id: id,
        surahId: surahId,
        ayahStart: ayahStart,
        ayahEnd: ayahEnd,
        date: DateTime.parse(date),
        durationSeconds: durationSeconds,
        mistakes: mistakes,
        hints: hints,
        type: HifzSessionType.values.firstWhere(
          (e) => e.name == type,
          orElse: () => HifzSessionType.review,
        ),
      );

  factory HifzSessionModel.fromDomain(HifzSession s) => HifzSessionModel(
        id: s.id,
        surahId: s.surahId,
        ayahStart: s.ayahStart,
        ayahEnd: s.ayahEnd,
        date: s.date.toIso8601String(),
        durationSeconds: s.durationSeconds,
        mistakes: s.mistakes,
        hints: s.hints,
        type: s.type.name,
      );
}
