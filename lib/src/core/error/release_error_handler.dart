import 'dart:async';
import 'dart:developer';
import 'package:flutter/foundation.dart';

/// معالج الأخطاء في وضع Release
class ReleaseErrorHandler {
  static void initialize() {
    // معالجة الأخطاء في Flutter Framework
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kReleaseMode) {
        // في وضع Release، نسجل الخطأ بدون crash
        log(
          'Flutter Error: ${details.exception}',
          error: details.exception,
          stackTrace: details.stack,
          name: 'FlutterError',
        );
      } else {
        // في وضع Debug، نعرض الخطأ بشكل طبيعي
        FlutterError.presentError(details);
      }
    };

    // معالجة الأخطاء خارج Flutter Framework
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kReleaseMode) {
        log(
          'Platform Error: $error',
          error: error,
          stackTrace: stack,
          name: 'PlatformError',
        );
        return true; // منع الـ crash
      }
      return false; // في Debug mode، نترك الخطأ يظهر
    };
  }

  /// معالج آمن للـ async operations
  static Future<T?> safeAsync<T>(
    Future<T> Function() operation, {
    String? operationName,
    T? fallbackValue,
  }) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      log(
        'Safe Async Error in ${operationName ?? "unknown"}: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'SafeAsync',
      );
      return fallbackValue;
    }
  }

  /// معالج آمن للـ sync operations
  static T? safeSync<T>(
    T Function() operation, {
    String? operationName,
    T? fallbackValue,
  }) {
    try {
      return operation();
    } catch (e, stackTrace) {
      log(
        'Safe Sync Error in ${operationName ?? "unknown"}: $e',
        error: e,
        stackTrace: stackTrace,
        name: 'SafeSync',
      );
      return fallbackValue;
    }
  }
}
