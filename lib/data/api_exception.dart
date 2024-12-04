class ApiException implements Exception {
  final int statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() =>
      'ApiException(statusCode: $statusCode, message: $message)';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(401, message);

  @override
  String toString() => 'UnauthorizedException: $message';
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message) : super(403, message);

  @override
  String toString() => 'ForbiddenException: $message';
}

class NotFoundException extends ApiException {
  NotFoundException(String message) : super(404, message);

  @override
  String toString() => 'NotFoundException: $message';
}

class InternalServerError extends ApiException {
  InternalServerError(String message) : super(500, message);

  @override
  String toString() => 'InternalServerError: $message';
}

class NetworkException implements Exception {
  final String message;

  NetworkException(this.message);

  @override
  String toString() => 'NetworkException(message: $message)';
}

class RequestTimeoutException implements Exception {
  @override
  String toString() => 'RequestTimeoutException';
}
