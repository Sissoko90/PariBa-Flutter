import 'package:equatable/equatable.dart';

/// Base Failure
abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

/// Server Failure
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

/// Cache Failure
class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

/// Network Failure
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Authentication Failure
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, {super.code});
}

/// Validation Failure
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

/// Not Found Failure
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});
}

/// Unauthorized Failure
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, {super.code});
}

/// Forbidden Failure
class ForbiddenFailure extends Failure {
  const ForbiddenFailure(super.message, {super.code});
}

/// Timeout Failure
class TimeoutFailure extends Failure {
  const TimeoutFailure(super.message, {super.code});
}
