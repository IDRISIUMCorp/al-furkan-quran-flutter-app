/// Al-Furkan Custom Exceptions — Internal to Data layer only
/// Domain/Presentation layers use Failure types, never these.
class AppException implements Exception {
  final String message;
  final int? statusCode;
  final Object? originalError;

  const AppException({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message';
}

class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.statusCode,
    super.originalError,
  });
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.originalError,
  });
}

class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Request timed out',
    super.originalError,
  });
}

class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.originalError,
  });
}

class DataIntegrityException extends AppException {
  final String resourceKey;
  final String? expectedHash;
  final String? actualHash;

  const DataIntegrityException({
    required super.message,
    required this.resourceKey,
    this.expectedHash,
    this.actualHash,
    super.originalError,
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.originalError,
  });
}

class PermissionException extends AppException {
  const PermissionException({
    required super.message,
    super.originalError,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    required super.message,
    super.originalError,
  });
}
