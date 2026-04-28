import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../constants/app_strings.dart';

/// Al-Furkan API Client — Centralized Dio instance with interceptors
/// All network calls go through this client. ZERO raw Dio instances elsewhere.
class ApiClient {
  ApiClient._();

  static Dio? _instance;

  /// Get the shared Dio instance
  static Dio get dio {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.addAll([
      _LoggingInterceptor(),
      _ErrorMappingInterceptor(),
    ]);

    return dio;
  }

  /// Create a Dio instance for a specific base URL
  static Dio forBaseUrl(String baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'Accept': 'application/json',
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    dio.interceptors.addAll([
      _LoggingInterceptor(),
      _ErrorMappingInterceptor(),
    ]);

    return dio;
  }

  /// Reset the singleton (for testing)
  static void reset() {
    _instance = null;
  }
}

/// Logging interceptor — logs requests/responses in debug mode only
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '→ ${options.method} ${options.uri}',
      );
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '← ${response.statusCode} ${response.requestOptions.uri}',
      );
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint(
        '✗ ${err.type} ${err.requestOptions.uri}: ${err.message}',
      );
    }
    handler.next(err);
  }
}

/// Error mapping interceptor — converts Dio errors to consistent format
class _ErrorMappingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final mapped = _mapError(err);
    handler.next(mapped);
  }

  DioException _mapError(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return DioException(
          requestOptions: err.requestOptions,
          type: err.type,
          message: AppStrings.errorTimeout,
          error: err,
        );
      case DioExceptionType.connectionError:
        return DioException(
          requestOptions: err.requestOptions,
          type: err.type,
          message: AppStrings.errorNetwork,
          error: err,
        );
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == 404) {
          return DioException(
            requestOptions: err.requestOptions,
            type: err.type,
            message: 'Resource not found',
            response: err.response,
            error: err,
          );
        }
        return DioException(
          requestOptions: err.requestOptions,
          type: err.type,
          message: AppStrings.errorServer,
          response: err.response,
          error: err,
        );
      default:
        return DioException(
          requestOptions: err.requestOptions,
          type: err.type,
          message: AppStrings.errorUnknown,
          error: err,
        );
    }
  }
}
