import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';

import '../error/exceptions.dart';
import '../error/failures.dart';

/// Al-Furkan Error Handler — Converts exceptions to Either<Failure, T>
/// Centralized error mapping so repositories never write try/catch twice.
class ErrorHandler {
  ErrorHandler._();

  /// Execute an async operation and return Either<Failure, T>
  /// Every repository method should use this instead of raw try/catch.
  static Future<Either<Failure, T>> guard<T>(
    Future<T> Function() operation,
  ) async {
    try {
      final result = await operation();
      return Right(result);
    } on NetworkException catch (e) {
      return Left(Failure.network(
        message: e.message,
      ));
    } on TimeoutException catch (e) {
      return Left(Failure.timeout(message: e.message));
    } on ServerException catch (e) {
      return Left(Failure.server(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } on CacheException catch (e) {
      return Left(Failure.cache(message: e.message));
    } on DataIntegrityException catch (e) {
      return Left(Failure.dataIntegrity(
        message: e.message,
        resourceKey: e.resourceKey,
        expectedHash: e.expectedHash,
        actualHash: e.actualHash,
      ));
    } on NotFoundException catch (e) {
      return Left(Failure.notFound(message: e.message));
    } on PermissionException catch (e) {
      return Left(Failure.permission(message: e.message));
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message));
    } on DioException catch (e) {
      return Left(_mapDioError(e));
    } catch (e) {
      return Left(Failure.unknown(
        message: e.toString(),
        originalError: e,
      ));
    }
  }

  /// Execute a sync operation and return Either<Failure, T>
  static Either<Failure, T> guardSync<T>(T Function() operation) {
    try {
      final result = operation();
      return Right(result);
    } on CacheException catch (e) {
      return Left(Failure.cache(message: e.message));
    } on DataIntegrityException catch (e) {
      return Left(Failure.dataIntegrity(
        message: e.message,
        resourceKey: e.resourceKey,
        expectedHash: e.expectedHash,
        actualHash: e.actualHash,
      ));
    } on ValidationException catch (e) {
      return Left(Failure.validation(message: e.message));
    } catch (e) {
      return Left(Failure.unknown(
        message: e.toString(),
        originalError: e,
      ));
    }
  }

  /// Map DioException to Failure
  static Failure _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Failure.timeout(message: e.message ?? 'Request timed out');
      case DioExceptionType.connectionError:
        return Failure.network(message: e.message ?? 'No internet connection');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode == 404) {
          return Failure.notFound(message: 'Resource not found');
        }
        return Failure.server(
          message: e.message ?? 'Server error',
          statusCode: statusCode,
        );
      case DioExceptionType.cancel:
        return Failure.network(message: 'Request was cancelled');
      default:
        return Failure.unknown(
          message: e.message ?? 'Unknown network error',
          originalError: e,
        );
    }
  }
}
