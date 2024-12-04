class AppException implements Exception {
  final _message;
  final _prefix;

  AppException(this._message, this._prefix);

  @override
  String toString() {
    return 'AppException{_message: $_message, _prefix: $_prefix}';
  }
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String? message]) : super(message, "unauthorized");
}

class InternetException extends AppException {
  InternetException([String? message]) : super(message, "no internet");
}

class RequestTimeOut extends AppException {
  RequestTimeOut([String? message]) : super(message, "TimeOut");
}

class ServerException extends AppException {
  ServerException([String? message]) : super(message, "Server Error occur");
}
