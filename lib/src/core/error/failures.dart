import 'package:freezed_annotation/freezed_annotation.dart';

part 'failures.freezed.dart';

/// Al-Furkan Failure Types — Sealed class pattern
/// Every async operation returns Either<Failure, T>
/// ZERO raw exceptions exposed to domain/presentation layers.
@freezed
sealed class Failure with _$Failure {
  // ── Network Failures ──
  const factory Failure.network({
    required String message,
    int? statusCode,
  }) = NetworkFailure;

  // ── Server Failures ──
  const factory Failure.server({
    required String message,
    int? statusCode,
  }) = ServerFailure;

  // ── Timeout Failures ──
  const factory Failure.timeout({
    String? message,
  }) = TimeoutFailure;

  // ── Cache Failures ──
  const factory Failure.cache({
    required String message,
  }) = CacheFailure;

  // ── Data Integrity Failures ──
  const factory Failure.dataIntegrity({
    required String message,
    required String resourceKey,
    String? expectedHash,
    String? actualHash,
  }) = DataIntegrityFailure;

  // ── Not Found Failures ──
  const factory Failure.notFound({
    required String message,
  }) = NotFoundFailure;

  // ── Permission Failures ──
  const factory Failure.permission({
    required String message,
  }) = PermissionFailure;

  // ── Validation Failures ──
  const factory Failure.validation({
    required String message,
  }) = ValidationFailure;

  // ── Unknown Failures ──
  const factory Failure.unknown({
    required String message,
    Object? originalError,
  }) = UnknownFailure;
}
