import 'package:equatable/equatable.dart';

/// Base failure class for the application.
/// All domain-level errors extend this sealed hierarchy.
abstract class Failure extends Equatable {
  const Failure();
}

/// Thrown when a network-level issue occurs (no internet, invalid key, etc.).
class NetworkFailure extends Failure {
  const NetworkFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Thrown when the remote server responds with an error status code.
class ServerFailure extends Failure {
  const ServerFailure(this.message, this.statusCode);

  final String message;
  final int statusCode;

  @override
  List<Object?> get props => [message, statusCode];
}

/// Thrown when reading from or writing to the local cache (Hive) fails.
class CacheFailure extends Failure {
  const CacheFailure();

  @override
  List<Object?> get props => [];
}

/// Thrown when the API quota is exceeded (HTTP 402 / 429).
class QuotaExceededFailure extends Failure {
  const QuotaExceededFailure();

  @override
  List<Object?> get props => [];
}

/// Thrown when the request times out (connection or receive timeout).
class TimeoutFailure extends Failure {
  const TimeoutFailure();

  @override
  List<Object?> get props => [];
}
