/// Base Exception
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Server Exception
class ServerException extends AppException {
  ServerException(super.message, {super.code});
}

/// Cache Exception
class CacheException extends AppException {
  CacheException(super.message, {super.code});
}

/// Network Exception
class NetworkException extends AppException {
  NetworkException(super.message, {super.code});
}

/// Authentication Exception
class AuthenticationException extends AppException {
  AuthenticationException(super.message, {super.code});
}

/// Validation Exception
class ValidationException extends AppException {
  ValidationException(super.message, {super.code});
}

/// Not Found Exception
class NotFoundException extends AppException {
  NotFoundException(super.message, {super.code});
}

/// Unauthorized Exception
class UnauthorizedException extends AppException {
  UnauthorizedException(super.message, {super.code});
}

/// Forbidden Exception
class ForbiddenException extends AppException {
  ForbiddenException(super.message, {super.code});
}

/// Timeout Exception
class TimeoutException extends AppException {
  TimeoutException(super.message, {super.code});
}
