import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../error/failures.dart';
import '../constants/app_constants.dart';

/// Singleton [Dio] factory with interceptors pre-configured.
///
/// Call [DioClient.create()] once during app initialisation (inside
/// `injection_container.dart`) and register the returned [Dio] instance
/// with GetIt.
class DioClient {
  DioClient._();

  static Dio create() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // ── Debug logging ────────────────────────────────────────────────────
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
          error: true,
        ),
      );
    }

    // ── Error mapping interceptor ─────────────────────────────────────────
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException err, ErrorInterceptorHandler handler) {
          // We just pass through — the failure mapping is available
          // via [DioClient.mapException] for use in data-source layers.
          handler.next(err);
        },
      ),
    );

    return dio;
  }

  /// Maps a [DioException] to the appropriate [Failure] subtype.
  /// Call this inside repository / data-source catch blocks.
  static Failure mapException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const TimeoutFailure();

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode ?? 0;
        return switch (statusCode) {
          401 => const NetworkFailure('Invalid API key'),
          402 || 429 => const QuotaExceededFailure(),
          503 => const ServerFailure('Service unavailable', 503),
          _ => ServerFailure(
              err.response?.statusMessage ?? 'Unknown server error',
              statusCode,
            ),
        };

      case DioExceptionType.connectionError:
        return const NetworkFailure('No internet connection');

      default:
        return const NetworkFailure('An unexpected error occurred');
    }
  }
}
